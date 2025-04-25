import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/mock_api_client.dart';
import '../models/user/user_model.dart';
import 'group_provider.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isAuthorized = false;
  bool _isAdmin = false;

  UserModel? get user => _user;
  bool get isAuthorized => _isAuthorized;
  bool get isAdmin => _isAdmin;

  bool get isAuthenticated => _user != null;

  final GroupProvider groupProvider;

  AuthProvider({required this.groupProvider});

  Future<void> login(String username, String password) async {
    try {
      // Используем напрямую MockApiClient вместо apiClient
      final user = await MockApiClient().login(username, password);

      _user = user;
      _isAuthorized = true;
      _isAdmin = user.isAdmin;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthorized', true);
      await prefs.setBool('isAdmin', _isAdmin);
      await prefs.setString('user', jsonEncode(user.toJson()));

      // Устанавливаем пользователя без автоматического создания группы
      groupProvider.setCurrentUser(user.name, isAdmin: user.isAdmin);

      notifyListeners();
    } catch (e) {
      throw Exception('Ошибка авторизации: ${e.toString()}');
    }
  }

  Future<void> checkAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthorized = prefs.getBool('isAuthorized') ?? false;
      _isAdmin = prefs.getBool('isAdmin') ?? false;

      String? userJson = prefs.getString('user');
      if (userJson != null) {
        try {
          final userMap = jsonDecode(userJson) as Map<String, dynamic>;
          _user = UserModel.fromResponse(userMap);
          groupProvider.setCurrentUser(_user!.name, isAdmin: _isAdmin);
        } catch (e) {
          debugPrint('Ошибка парсинга userJson: $e');
          await logout(); // сброс при ошибке
        }
      }


      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка при чтении SharedPreferences: $e');
      _isAuthorized = false;
      _isAdmin = false;
      _user = null;
      notifyListeners();
    }
  }


  Future<void> setUser(UserModel user) async {
    _user = user;
    _isAuthorized = true;
    _isAdmin = user.isAdmin;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthorized', true);
    await prefs.setBool('isAdmin', _isAdmin);
    await prefs.setString('user', jsonEncode(user.toJson()));

    // Устанавливаем текущего пользователя в группе
    groupProvider.setCurrentUser(user.name, isAdmin: user.isAdmin);

    notifyListeners();
  }

  Future<void> logout() async {
    await groupProvider.saveGroupData();

    _isAuthorized = false;
    _isAdmin = false;
    _user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthorized', false);
    await prefs.setBool('isAdmin', false);
    await prefs.remove('user');

    notifyListeners();
  }
}