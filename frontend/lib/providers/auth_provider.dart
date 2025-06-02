import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zadachok/models/lobby/lobby_model.dart';
import 'package:zadachok/providers/shop_provider.dart';
import 'package:zadachok/providers/task_provider.dart';
import '../api/api_client.dart';
import '../models/user/user_model.dart';
import '../services/notification_service.dart';
import 'group_provider.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _token;
  LobbyModel? _lobby;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isAuthorized => _token != null;
  bool get isAdmin => _user?.role.isAdmin ?? false;

  final GroupProvider groupProvider;
  final apiClient = ApiClient();

  AuthProvider({required this.groupProvider});

  Future<void> setAuthData({
    required UserModel user,
    required String token,
  }) async {
    _user = user;
    _token = token;

    debugPrint('DEBUG[AuthProvider] setAuthData: user.id=${user.id}, token=$token');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', jsonEncode(user.toJson()));

    groupProvider.setCurrentUser(user);
    NotificationService().setAuthToken(token);
    notifyListeners();
  }

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userJson = prefs.getString('user');

    debugPrint('DEBUG[AuthProvider] checkAuth: token=$_token');
    debugPrint('DEBUG[AuthProvider] checkAuth: raw user json=$userJson');

    if (_token == null || userJson == null) {
      debugPrint('DEBUG[AuthProvider] checkAuth: No auth data found. Clearing...');
      await _clearAuthData();
      return;
    }

    try {
      _user = UserModel.fromJson(jsonDecode(userJson));
      debugPrint('DEBUG[AuthProvider] checkAuth: parsed user.id=${_user?.id}');
      groupProvider.setCurrentUser(_user!);
      notifyListeners();
    } catch (e) {
      debugPrint('Auth data parsing error: $e');
      await _clearAuthData();
    }
  }

  Future<void> logout() async {
    debugPrint('DEBUG[AuthProvider] logout: Clearing user data');
    await _clearAuthData();
    await groupProvider.resetGroup();
    notifyListeners();
  }

  Future<void> login(UserModel user, String token) async {
    try {
      debugPrint('DEBUG[AuthProvider] login: user.id=${user.id}');
      await setAuthData(user: user, token: token);

      await groupProvider.loadGroupData();
      if (groupProvider.isInGroup) {
        await groupProvider.refreshGroupData();
      }
    } catch (e) {
      debugPrint('Ошибка при обновлении данных группы после входа: $e');
      rethrow;
    }
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');

    debugPrint('DEBUG[AuthProvider] _clearAuthData: Auth data cleared');

    _user = null;
    _token = null;
  }

  Future<void> refreshUserData() async {
    if (_user == null) return;

    try {
      debugPrint('DEBUG[AuthProvider] refreshUserData: fetching user by id=${_user!.id}');
      final updatedUser = await apiClient.getUserById(
        UserModel(id: _user!.id, name: '', email: '', login: ''),
      );
      _user = updatedUser;

      debugPrint('DEBUG[AuthProvider] refreshUserData: updated user.id=${_user!.id}');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(_user!.toJson()));
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка при обновлении данных пользователя: $e');
      rethrow;
    }
  }

  Future<void> updateUserPhoto(String base64Image) async {
    if (_user != null) {
      try {
        debugPrint('DEBUG[AuthProvider] updateUserPhoto: user.id=${_user!.id}');
        final updatedUser = _user!.copyWith(photoBytes: base64Image);
        await apiClient.updateUserProfile(updatedUser);

        _user = updatedUser;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(_user!.toJson()));

        notifyListeners();
      } catch (e) {
        debugPrint('Ошибка обновления фото: $e');
        rethrow;
      }
    }
  }

  Future<void> updateUserProfile(UserModel updatedUser) async {
    apiClient.setAuthToken(_token!);

    try {
      debugPrint('DEBUG[AuthProvider] updateUserProfile: user.id=${updatedUser.id}');
      final responseUser = await apiClient.updateUserProfile(updatedUser);
      await setAuthData(
        user: responseUser,
        token: _token!,
      );
    } catch (e) {
      debugPrint('Ошибка обновления профиля: $e');
      rethrow;
    }
  }

  Future<void> refreshAll(GroupProvider groupProvider, TaskProvider taskProvider, ShopProvider shopProvider) async {
    try {
      apiClient.setAuthToken(_token!);
      debugPrint('DEBUG[AuthProvider] refreshAll: Starting refresh for user.id=${_user?.id}');
      await refreshUserData();

      groupProvider.setAuthProvider(this);
      groupProvider.setCurrentUser(_user!);

      debugPrint('DEBUG[AuthProvider] refreshAll: calling getLobbyByUserId(${_user!.id})');
      final lobby = await apiClient.getLobbyByUserId(_user!.id);

      if (lobby != null) {
        debugPrint('DEBUG[AuthProvider] refreshAll: lobby found with id=${lobby.id}, shopId=${lobby.shopId}');
        await groupProvider.setCurrentLobby(lobby);

        taskProvider.setAuthProvider(this);
        taskProvider.setUser(_user!);
        taskProvider.setLobbyId(lobby.id);
        await taskProvider.refreshTasks();
        await groupProvider.refreshGroupData();
        shopProvider.setCurrentShop(lobby.shopId);
        await shopProvider.refreshProducts();
      } else {
        debugPrint('DEBUG[AuthProvider] refreshAll: No lobby found for user.id=${_user!.id}');
        await groupProvider.resetGroup();
        taskProvider.resetFilters();
        shopProvider.clearProducts();
      }
    } catch (e) {
      debugPrint('Ошибка при полном обновлении данных: $e');
      rethrow;
    }
  }
}
