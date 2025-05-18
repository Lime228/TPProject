import 'dart:convert';
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

  // Геттеры
  String? get groupCode => _lobby?.code;
  String? get groupName => _lobby != null ? "Группа ${_lobby!.code}" : null;
  List<UserModel> get members => _members;
  UserModel? get currentUser => _currentUser;
  int get lobbyId => _lobby?.id ?? 0;
  bool get isAuthenticated => _currentUser != null;
  bool get isInGroup => _lobby != null;
  bool get isOwner => _currentUser?.role.isAdmin ?? false;

  GroupProvider({required this.authProvider});

  // Установка текущего пользователя
  void setCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  // Создание группы
  Future<void> createGroup() async {
    try {
      final currentUserId = _validateUser();
      final apiClient = _getAuthenticatedClient();

      _lobby = await apiClient.createLobby(currentUserId);
      if (_lobby?.code == null) throw Exception('Не удалось создать лобби');
      UserModel user =await apiClient.getUserById( new UserModel(name: 'name', email: 'email', login: 'login', id:_lobby!.customerId[0]));
      _members = [user];
      await _saveGroupData();
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка создания группы: $e');
      rethrow;
    }
  }

  // Присоединение к группе
  Future<bool> joinGroup(String code) async {
    try {
      final currentUserId = _validateUser();
      final apiClient = _getAuthenticatedClient();//ТУТ ТАКИЕ ЖЕ ТРАБЛЫ КАК И В CREATEGROUP;

      await apiClient.lobbyAddUser(code, currentUserId);
      await _loadLobbyById(currentUserId);

      if (!_members.any((m) => m.id == _currentUser!.id)) {
        _members.add(_currentUser!);
      }

      await _saveGroupData();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка присоединения к группе: $e');
      return false;
    }
  }

  // Загрузка данных лобби
  Future<void> _loadLobbyById(int userId) async {
    final apiClient = _getAuthenticatedClient();
    _lobby = await apiClient.getLobby(userId);
    if (_lobby == null) throw Exception('Лобби не найдено');
  }

  // Выход из группы
  Future<void> leaveGroup() async {
    if (_currentUser == null || _lobby == null) return;

    try {
      final apiClient = _getAuthenticatedClient();
      await apiClient.lobbyRemoveUser(_lobby!.id, _currentUser!.id);

      _members.removeWhere((m) => m.id == _currentUser!.id);
      if (_members.isEmpty) {
        await _clearGroupData();
      } else {
        await _saveGroupData();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка выхода из группы: $e');
    }
  }

  // Сохранение данных
  Future<void> _saveGroupData() async {
    if (_lobby == null) return;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('lobby', jsonEncode(_lobby!.toJson()));
    await prefs.setStringList('members',
        _members.map((m) => jsonEncode(m.toJson())).toList());
  }

  // Загрузка данных
  Future<void> loadGroupData() async {
    final prefs = await SharedPreferences.getInstance();
    final lobbyJson = prefs.getString('lobby');
    final membersJson = prefs.getStringList('members') ?? [];

    if (lobbyJson == null) return;

    try {
      _lobby = LobbyModel.fromJson(jsonDecode(lobbyJson));
      _members = membersJson.map((json) => UserModel.fromJson(jsonDecode(json))).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка загрузки группы: $e');
      await _clearGroupData();
    }
  }

  Future<void> resetGroup() async {
    _clearGroupData();
  }

  ApiClient getAuthenticatedClient() {
    if (authProvider?.token == null) throw Exception('Токен отсутствует');
    final client = ApiClient();
    client.setAuthToken(authProvider!.token!);
    return client;
  }

  void setMembers(List<UserModel> members) {
    _members = members;
    notifyListeners();
  }

  // Очистка данных
  Future<void> _clearGroupData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lobby');
    await prefs.remove('members');
    _lobby = null;
    _members = [];
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


  // Валидация пользователя
  int _validateUser() {
    if (authProvider?.user == null) throw Exception('Пользователь не авторизован');
    if (authProvider!.user!.id == 0) throw Exception('Неверный ID пользователя');
    return authProvider!.user!.id;
  }

  // Получение авторизованного клиента
  ApiClient _getAuthenticatedClient() {
    if (authProvider?.token == null) throw Exception('Токен отсутствует');
    final client = ApiClient();
    client.setAuthToken(authProvider!.token!);
    return client;
  }
}
