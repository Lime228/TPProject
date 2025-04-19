import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthorized = false;

  bool get isAuthorized => _isAuthorized;

  Future<void> login() async {
    _isAuthorized = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthorized', true);
    notifyListeners();
  }

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthorized = prefs.getBool('isAuthorized') ?? false;
    notifyListeners();
  }

  Future<void> logout() async {
    _isAuthorized = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthorized', false);
    notifyListeners();
  }
}