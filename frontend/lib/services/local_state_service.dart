import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user/user_model.dart';
import '../models/lobby/lobby_model.dart';

class LocalStateService {
  static const String _authTokenKey = 'auth_token';
  static const String _userKey = 'user';
  static const String _lobbyKey = 'lobby';
  static const String _membersKey = 'members';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth methods
  Future<void> saveAuthState(UserModel user, String token) async {
    await _prefs.setString(_authTokenKey, token);
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<Map<String, dynamic>?> getAuthState() async {
    final token = _prefs.getString(_authTokenKey);
    final userJson = _prefs.getString(_userKey);

    if (token == null || userJson == null) return null;

    try {
      return {
        'token': token,
        'user': UserModel.fromJson(jsonDecode(userJson)),
      };
    } catch (e) {
      await clearAuthState();
      return null;
    }
  }

  Future<void> clearAuthState() async {
    await _prefs.remove(_authTokenKey);
    await _prefs.remove(_userKey);
  }

  // Group methods
  Future<void> saveGroupState(LobbyModel lobby, List<UserModel> members) async {
    await _prefs.setString(_lobbyKey, jsonEncode(lobby.toJson()));
    final membersJson = members.map((m) => jsonEncode(m.toJson())).toList();
    await _prefs.setStringList(_membersKey, membersJson);
  }

  Future<Map<String, dynamic>?> getGroupState() async {
    final lobbyJson = _prefs.getString(_lobbyKey);
    final membersJsonList = _prefs.getStringList(_membersKey);

    if (lobbyJson == null || membersJsonList == null) return null;

    try {
      final lobby = LobbyModel.fromJson(jsonDecode(lobbyJson));
      final members = membersJsonList
          .map((json) => UserModel.fromJson(jsonDecode(json)))
          .toList();

      return {
        'lobby': lobby,
        'members': members,
      };
    } catch (e) {
      await clearGroupState();
      return null;
    }
  }

  Future<void> clearGroupState() async {
    await _prefs.remove(_lobbyKey);
    await _prefs.remove(_membersKey);
  }

  Future<void> clearAll() async {
    await clearAuthState();
    await clearGroupState();
  }
} 