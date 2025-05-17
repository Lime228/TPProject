import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/mock_api_client.dart';
import '../models/user/user_model.dart';
import 'group_provider.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isAdmin = false;
  String? _token;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isAuthorized => _token != null && _token!.isNotEmpty;
  bool get isAdmin => _isAdmin;

  bool get isAuthenticated => _user != null;

  final GroupProvider groupProvider;

  AuthProvider({required this.groupProvider});

  Future<void> setUserAndToken({
    required UserModel user,
    required String token
  }) async {
    debugPrint('Setting user with ID: ${user.id}');
    _user = user;
    _token = token;
    _isAdmin = user.isAdmin;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setBool('isAdmin', _isAdmin);
    await prefs.setString('user', jsonEncode(user.toJson()));

    groupProvider.setCurrentUser(user.name, isAdmin: user.isAdmin);
    notifyListeners();
  }



  Future<void> checkAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');

      final String? userJson = prefs.getString('user');
      if (userJson != null && _token != null) {
        try {
          final userMap = jsonDecode(userJson) as Map<String, dynamic>;
          _user = UserModel.fromResponse(userMap);
          _isAdmin = prefs.getBool('isAdmin') ?? false;

          groupProvider.setCurrentUser(_user!.name, isAdmin: _isAdmin);
        } catch (e) {
          debugPrint('Ошибка парсинга userJson: $e');
          await logout();
        }
      } else {
        await logout();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка при проверке авторизации: $e');
      await logout();
    }
  }


  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    await prefs.remove('isAdmin');


    await groupProvider.resetGroup();

    _user = null;
    _token = null;
    _isAdmin = false;

    notifyListeners();
  }
}