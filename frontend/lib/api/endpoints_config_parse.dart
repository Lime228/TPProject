import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class EndpointsConfigParse {
  static late Map<String, dynamic> _config;

  static Future<void> load() async {
    final configString = await rootBundle.loadString('assets/config.json');
    _config = jsonDecode(configString) as Map<String, dynamic>;
  }

  static String get baseUrl => _config["api"]["baseUrl"];
  static String get registerPath => _config["api"]["endpoints"]["register"];
  static String get loginPath => _config["api"]["endpoints"]["login"];
  static String get recoverPasswordPath => _config["api"]["endpoints"]["recoverPassword"];
  static String get tasksPath => _config["api"]["endpoints"]["tasks"];
}