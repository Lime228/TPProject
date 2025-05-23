import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zadachok/models/lobby/lobby_model.dart';
import 'package:zadachok/models/user/user_model.dart';
import '../api/api_client.dart';
import 'auth_provider.dart';

class GroupProvider with ChangeNotifier {
  AuthProvider? authProvider;
  LobbyModel? _lobby;
  List<UserModel> _members = [];
  UserModel? _currentUser;

  final client = ApiClient();

  GroupProvider({required this.authProvider});

  // Геттеры
  String? get groupCode => _lobby?.code;
  String? get groupName => _lobby != null ? "Группа ${_lobby!.code}" : null;
  List<UserModel> get members => _members;
  UserModel? get currentUser => _currentUser;
  int get lobbyId => _lobby?.id ?? 0;
  bool get isAuthenticated => _currentUser != null;
  bool get isInGroup => _lobby != null;
  bool get isOwner => _currentUser?.role.isAdmin ?? false;

  // Установка текущего пользователя (вызывается извне)
  void setCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }
  Future<void> setCurrentLobby(LobbyModel lobby) async {
    try {
      // Проверяем, что пользователь есть в лобби
      if (!lobby.customerId.contains(_currentUser?.id)) {
        throw Exception('Пользователь не состоит в этом лобби');
      }

      _lobby = lobby;

      // Загружаем участников лобби

      // Сохраняем в SharedPreferences
      await _saveGroupData();

      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка установки лобби: $e');
      rethrow;
    }
  }

  void setAuthProvider(AuthProvider provider) {
    authProvider = provider;
    notifyListeners();
  }

  Future<void> forceRefresh() async {
    await refreshGroupData();
    notifyListeners();
  }

  // Основные методы
  Future<void> createGroup() async {
    try {
      final userId = _validateCurrentUser();
      final apiClient = _getAuthenticatedClient();

      _lobby = await apiClient.createLobby(userId);
      await refreshGroupData();
    } catch (e) {
      debugPrint('Ошибка создания группы: $e');
      rethrow;
    }
  }

  Future<bool> joinGroup(String code) async {
    try {
      final userId = _validateCurrentUser();
      final apiClient = _getAuthenticatedClient();

      await apiClient.lobbyAddUser(code, userId);
      await refreshGroupData();
      return true;
    } catch (e) {
      debugPrint('Ошибка присоединения к группе: $e');
      return false;
    }
  }

  Future<void> leaveGroup() async {
    if (_currentUser == null || _lobby == null) return;

    try {
      final apiClient = _getAuthenticatedClient();
      await apiClient.lobbyRemoveUser(_lobby!.id, _currentUser!.id);
      await refreshGroupData();

      if (_members.isEmpty) {
        await _clearGroupData();
      }
    } catch (e) {
      debugPrint('Ошибка выхода из группы: $e');
    }
  }

  Future<void> disbandGroup() async {
    if (_lobby == null) return;

    try {
      final client = _getAuthenticatedClient();
      await client.deleteLobby(_lobby!.id);
      await _clearGroupData();
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка распускания группы: $e');
      rethrow;
    }
  }


  // Внутренние методы
  Future<void> refreshGroupData() async {
    if (_currentUser == null) return;

    final apiClient = _getAuthenticatedClient();
    try {
      // Используем новый метод getLobbyByUserId вместо getLobby
      _lobby = await apiClient.getLobbyByUserId(_currentUser!.id);

      if (_lobby != null) {
        _members = await Future.wait(
            _lobby!.customerId.map((id) =>
                apiClient.getUserById(UserModel(id: id, name: '', email: '', login: ''))
            )
        );
      }

      await _saveGroupData();
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка обновления данных группы: $e');
      // Если ошибка, возможно пользователь не в группе
      _lobby = null;
      _members = [];
      await _saveGroupData();
      notifyListeners();
    }
  }



  Future<void> loadGroupData() async {
    final prefs = await SharedPreferences.getInstance();
    final lobbyJson = prefs.getString('lobby');
    final membersJson = prefs.getStringList('members') ?? [];

    if (lobbyJson != null) {
      _lobby = LobbyModel.fromJson(jsonDecode(lobbyJson));
      _members = membersJson.map((json) => UserModel.fromJson(jsonDecode(json))).toList();
      notifyListeners();
    }
  }

  Future<void> resetGroup() async {
    await _clearGroupData();
  }

  // Валидация и вспомогательные методы
  int _validateCurrentUser() {
    if (_currentUser == null) {
      // Попробуем получить пользователя из AuthProvider, если он есть
      if (authProvider?.user != null) {
        _currentUser = authProvider!.user;
      } else {
        throw Exception('Текущий пользователь не установлен');
      }
    }
    return _currentUser!.id;
  }

  ApiClient _getAuthenticatedClient() {
    if (authProvider?.token == null) throw Exception('Токен отсутствует');
    client.setAuthToken(authProvider!.token!);
    return client;
  }


  Future<void> _saveGroupData() async {
    if (_lobby == null) return;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('lobby', jsonEncode(_lobby!.toJson()));
    await prefs.setStringList(
        'members',
        _members.map((m) => jsonEncode(m.toJson())).toList()
    );
  }

  Future<void> _clearGroupData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lobby');
    await prefs.remove('members');
    _lobby = null;
    _members = [];
    notifyListeners();
  }
}
