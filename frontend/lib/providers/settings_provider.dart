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
    notifyListeners();
  }

  Future<void> update<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is double) await prefs.setDouble(key, value);

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
    }

    notifyListeners();
  }

}
