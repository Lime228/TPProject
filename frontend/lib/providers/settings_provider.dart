import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {

  bool notificationsEnabled = true;
  bool darkTheme = false;
  double volume = 0.5;
  bool backgroundMusic = false;
  bool interfaceAnimations = true;
  bool experimentalFeatures = false;
  bool autoUpdates = true;
  bool locationAccess = false;


  String? _userName;
  String? _userSurname;
  File? _avatarImage;

  String? get userName => _userName;
  String? get userSurname => _userSurname;
  File? get avatarImage => _avatarImage;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();


    notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    darkTheme = prefs.getBool('darkTheme') ?? false;
    volume = prefs.getDouble('volume') ?? 0.5;
    backgroundMusic = prefs.getBool('backgroundMusic') ?? false;
    interfaceAnimations = prefs.getBool('interfaceAnimations') ?? true;
    experimentalFeatures = prefs.getBool('experimentalFeatures') ?? false;
    autoUpdates = prefs.getBool('autoUpdates') ?? true;
    locationAccess = prefs.getBool('locationAccess') ?? false;


    _userName = prefs.getString('userName');
    _userSurname = prefs.getString('userSurname');
    final avatarPath = prefs.getString('avatarPath');
    if (avatarPath != null) {
      _avatarImage = File(avatarPath);
    }

    notifyListeners();
  }

  Future<void> update<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is bool) await prefs.setBool(key, value);
    if (value is double) await prefs.setDouble(key, value);
    if (value is String) await prefs.setString(key, value);

    switch (key) {

      case 'notificationsEnabled':
        notificationsEnabled = value as bool;
        break;
      case 'volume':
        volume = value as double;
        break;
      case 'darkTheme':
        darkTheme = value as bool;
        break;
      case 'backgroundMusic':
        backgroundMusic = value as bool;
        break;
      case 'interfaceAnimations':
        interfaceAnimations = value as bool;
        break;
      case 'experimentalFeatures':
        experimentalFeatures = value as bool;
        break;
      case 'autoUpdates':
        autoUpdates = value as bool;
        break;
      case 'locationAccess':
        locationAccess = value as bool;
        break;

      case 'userName':
        _userName = value as String;
        break;
      case 'userSurname':
        _userSurname = value as String;
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

    if (avatar != null) {
      _avatarImage = avatar;
      await prefs.setString('avatarPath', avatar.path);
    }

    notifyListeners();
  }
}