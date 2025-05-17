import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zadachok/models/lobby/lobby_model.dart';
import '../api/api_client.dart';
import 'auth_provider.dart';

class GroupProvider with ChangeNotifier {
  AuthProvider? authProvider;

  GroupProvider({required this.authProvider});

  String? _groupCode;
  String? _groupName;
  List<GroupMember> _members = [];
  GroupMember? _currentUser;
  LobbyModel? _lobby;

  String? get groupCode => _groupCode;
  String? get groupName => _groupName;
  List<GroupMember> get members => _members;
  GroupMember? get currentUser => _currentUser;
  int get lobbyId => _lobby?.id ?? 0;

  bool get isAuthenticated => _currentUser != null;
  bool get isInGroup => _groupCode != null;
  bool get isOwner => _currentUser?.role == GroupRole.owner;

  int getCurrentUserId() {
    if (authProvider == null || authProvider!.user == null) {
      debugPrint('AuthProvider or user is null');
      throw Exception('Пользователь не авторизован');
    }

    final userId = authProvider!.user!.id;
    debugPrint('Current user ID: $userId');

    if (userId == 0) {
      throw Exception('Неверный ID пользователя (0)');
    }

    return userId;
  }


  void setCurrentUser(String userName, {bool isAdmin = false}) {
    _currentUser = GroupMember(
      name: userName,
      role: isAdmin ? GroupRole.owner : GroupRole.member,
    );

    if (_groupCode != null && !_members.any((m) => m.name == userName)) {
      _members.add(_currentUser!);
      saveGroupData();
    }

    notifyListeners();
  }


  Future<void> createGroup() async {
    try {
      if (authProvider == null || authProvider!.token == null) {
        throw Exception('Пользователь не авторизован');
      }

      final apiClient = ApiClient();
      apiClient.setAuthToken(authProvider!.token!);

      final currentUserId = getCurrentUserId();
      if (currentUserId == 0) {
        throw Exception('Неверный ID пользователя');
      }

      _lobby = await apiClient.createLobby(currentUserId);

      if (_lobby?.code == null) {
        throw Exception('Сервер не вернул код лобби');
      }

      _groupCode = _lobby!.code!;
      _groupName = "Группа $_groupCode";
      _members = [_currentUser!];

      await saveGroupData();
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка при создании лобби: $e');
      rethrow;
    }
  }


  Future<bool> joinGroup(String code) async {
    final apiClient = ApiClient();
    if (code.isEmpty) return false;

    try {
      final currentUserId = getCurrentUserId();
      final updatedLobby = await apiClient.lobbyAddUser(code, currentUserId);

      _lobby = updatedLobby;
      _groupCode = updatedLobby.code!;
      _groupName = "Группа ${updatedLobby.code}";

      if (!_members.any((m) => m.name == _currentUser!.name)) {
        _members.add(_currentUser!);
      }

      await saveGroupData();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка присоединения к группе: $e');
      return false;
    }
  }



  Future <void> leaveGroup() async {
    if (_currentUser != null) {
      _members.removeWhere((m) => m.name == _currentUser!.name);
      if (_members.isEmpty) {
        _groupCode = null;
        _groupName = null;
        clearGroupData();
      } else {
        saveGroupData();
      }
      notifyListeners();
    }
  }

  void updateGroupName(String newName) {
    _groupName = newName;
    notifyListeners();
  }

  Future<void> disbandGroup() async {
    _members.clear();
    _groupCode = null;
    _groupName = null;
    await clearGroupData();
    notifyListeners();
  }

  Future<void> resetGroup() async {
    _groupCode = null;
    _groupName = null;
    _members = [];
    await clearGroupData();
    notifyListeners();
  }

  Future<void> clearUserFromGroup() async {
    if (_currentUser != null) {
      _members.removeWhere((m) => m.name == _currentUser!.name);
      await saveGroupData();
      notifyListeners();
    }
  }




  void removeMember(String name) {
    if (!isOwner) return;

    _members.removeWhere((member) => member.name == name);
    notifyListeners();
  }

  List<String> get memberNames => _members.map((e) => e.name).toList();
  int get memberCount => _members.length;


  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  Future<void> saveGroupData() async {
    if (_groupCode == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('members',
        _members.map((m) => jsonEncode(m.toJson())).toList());

  }

  Future<void> loadGroupData() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('group_code');

    if (code == null) return;

    try {

      final apiClient = ApiClient();
      _lobby = await apiClient.getLobby(code);

      _groupCode = code;
      _groupName = prefs.getString('group_name');


      final membersJson = prefs.getStringList('members') ?? [];
      _members = membersJson.map((json) {
        final data = jsonDecode(json);
        return GroupMember(
          name: data['name'],
          role: data['role'].contains('owner') ? GroupRole.owner : GroupRole.member,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка загрузки группы: $e');
      await clearGroupData();
    }
  }

  Future<void> clearGroupData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('group_code');
    await prefs.remove('group_name');
    await prefs.remove('members');
  }

}



class GroupMember {
  final String name;
  final GroupRole role;

  GroupMember({required this.name, required this.role});

  Map<String, dynamic> toJson() => {
    'name': name,
    'role': role.toString(),
  };

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      name: json['name'],
      role: json['role'].contains('owner') ? GroupRole.owner : GroupRole.member,
    );
  }
}

enum GroupRole {
  owner,
  member,
}
