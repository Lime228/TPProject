import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user/user_model.dart';
import 'group_provider.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _token;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isAuthorized => _token != null;
  bool get isAdmin => _user?.role.isAdmin ?? false;

  final GroupProvider groupProvider;

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

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');

    _user = null;
    _token = null;
  }
}
