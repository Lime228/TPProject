import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zadachok/models/lobby/lobby_model.dart';
import 'package:zadachok/providers/shop_provider.dart';
import 'package:zadachok/providers/task_provider.dart';
import '../api/api_client.dart';
import '../models/user/user_model.dart';
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

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', jsonEncode(user.toJson()));

    groupProvider.setCurrentUser(user);
    notifyListeners();
  }

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userJson = prefs.getString('user');

    if (_token == null || userJson == null) {
      await _clearAuthData();
      return;
    }

    try {
      _user = UserModel.fromJson(jsonDecode(userJson));
      groupProvider.setCurrentUser(_user!);
      notifyListeners();
    } catch (e) {
      debugPrint('Auth data parsing error: $e');
      await _clearAuthData();
    }
  }

  Future<void> logout() async {
    await _clearAuthData();
    await groupProvider.resetGroup();
    notifyListeners();
  }

  Future<void> login(UserModel user, String token) async {
    try {
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

    _user = null;
    _token = null;
  }

  Future<void> refreshUserData() async {
    if (_user == null) return;

    try {
      final updatedUser = await apiClient.getUserById(UserModel(id: _user!.id, name: '', email: '', login: ''));
      _user = updatedUser;


      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(_user!.toJson()));
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка при обновлении данных пользователя: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile(UserModel updatedUser) async {
    apiClient.setAuthToken(_token!);

    try {
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
      await refreshUserData();

      groupProvider.setAuthProvider(this);
      groupProvider.setCurrentUser(_user!);

      final lobby = await apiClient.getLobbyByUserId(_user!.id);
      if (lobby != null) {
        await groupProvider.setCurrentLobby(lobby);

        taskProvider.setAuthProvider(this);
        taskProvider.setUser(_user!);
        taskProvider.setLobbyId(lobby.id);
        await taskProvider.refreshTasks();
        shopProvider.setCurrentShop(lobby.shopId);
        await shopProvider.refreshProducts();
      } else {
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
