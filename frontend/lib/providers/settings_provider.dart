import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _notificationsEnabled = true;

  String? _userName;
  // String? _userSurname;
  DateTime? _userBirthDate;
  String? _avatarBytes; // Храним как base64 строку

  String? get avatarBytes => _avatarBytes;
  String? get userName => _userName;
  DateTime? get userBirthDate => _userBirthDate;

  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _avatarBytes = prefs.getString('avatar');
    notifyListeners();
  }

  Future<void> update<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is bool) await prefs.setBool(key, value);
    if (value is String) await prefs.setString(key, value);

    switch (key) {
      case 'notificationsEnabled':
        _notificationsEnabled = value as bool;
        break;
      case 'userName':
        _userName = value as String;
        break;
      // case 'userSurname':
      //   _userSurname = value as String;
      //   break;
      case 'birthDate':
        _userBirthDate = value as DateTime?;
        break;
      case 'avatarPath':
        _avatarBytes = File(value as String) as String?;
        break;
    }

    notifyListeners();
  }

  Future<void> updateUserData({
    String? name,
    String? birthDate,
    String? avatarBytes, // Принимаем base64 строку
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (avatarBytes != null) {
      _avatarBytes = avatarBytes;
      await prefs.setString('avatar', avatarBytes);
    }

    notifyListeners();
  }


}