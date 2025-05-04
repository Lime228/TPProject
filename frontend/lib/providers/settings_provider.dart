import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool notificationsEnabled = true;

  String? _userName;
  String? _userSurname;
  String? _birthDate;
  File? _avatarImage;

  String? get userName => _userName;
  String? get userSurname => _userSurname;
  String? get birthDate => _birthDate;
  File? get avatarImage => _avatarImage;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _userName = prefs.getString('userName');
    _userSurname = prefs.getString('userSurname');
    _birthDate = prefs.getString('birthDate');
    final avatarPath = prefs.getString('avatarPath');
    if (avatarPath != null && File(avatarPath).existsSync()) {
      _avatarImage = File(avatarPath);
    }

    notifyListeners();
  }

  Future<void> update<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is bool) await prefs.setBool(key, value);
    if (value is String) await prefs.setString(key, value);

    switch (key) {
      case 'notificationsEnabled':
        notificationsEnabled = value as bool;
        break;
      case 'userName':
        _userName = value as String;
        break;
      case 'userSurname':
        _userSurname = value as String;
        break;
      case 'birthDate':
        _birthDate = value as String;
        break;
      case 'avatarPath':
        _avatarImage = File(value as String);
        break;
    }

    notifyListeners();
  }

  Future<void> updateUserData({
    String? name,
    String? surname,
    String? birthDate,
    File? avatar,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (name != null) {
      _userName = name;
      await prefs.setString('userName', name);
    }

    if (surname != null) {
      _userSurname = surname;
      await prefs.setString('userSurname', surname);
    }

    if (birthDate != null) {
      _birthDate = birthDate;
      await prefs.setString('birthDate', birthDate);
    }

    if (avatar != null) {
      _avatarImage = avatar;
      await prefs.setString('avatarPath', avatar.path);
    }

    notifyListeners();
  }
}