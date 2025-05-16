import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zadachok/models/lobby/lobby_model.dart';
import '../api/api_client.dart';

class GroupProvider with ChangeNotifier {
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


  Future<void> createGroup(String name) async {
    if (name.isEmpty || name.length < 3) throw Exception('Название слишком короткое');

    _groupName = name;
    _groupCode = _generateRandomCode();
    _members = [_currentUser!];

    try {
      final apiClient = ApiClient();
      final lobbyRequest = LobbyModel(
        taskId: [],
        shopId: 0,
        customerId: [2], //ID
      );

      _lobby = await apiClient.createLobby(lobbyRequest);


      await saveGroupData();
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка при создании лобби: $e');
      rethrow;
    }
  }


  Future<bool> joinGroup(String code) async {
    if (code == _groupCode && _currentUser != null) {
      if (!_members.any((m) => m.name == _currentUser!.name)) {
        _members.add(_currentUser!);


        if (_lobby != null) {
          _lobby!.customerId.add(getCurrentUserId());
        }

        await saveGroupData();
        notifyListeners();
      }
      return true;
    }
    return false;
  }


  int getCurrentUserId() {
    return _currentUser?.name.hashCode ?? 0;
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



    _groupCode = code;
    _groupName = prefs.getString('group_name');

    final membersJson = prefs.getStringList('members') ?? [];
    try {
      _members = membersJson.map((json) {
        final data = jsonDecode(json);
        return GroupMember(
          name: data['name'],
          role: data['role'].contains('owner') ? GroupRole.owner : GroupRole.member,
        );
      }).toList();
    } catch (e) {
      debugPrint('Ошибка загрузки участников группы: $e');
      _members = [];
    }

    notifyListeners();
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
