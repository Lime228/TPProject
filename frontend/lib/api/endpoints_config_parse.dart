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
  static String get updateCustomerPath => _config["api"]["endpoints"]["updateCustomer"];
  static String get getCustomerPath => _config["api"]["endpoints"]["getCustomer"];

  static String get taskCreatePath => _config["api"]["endpoints"]["taskCreate"];
  static String get taskUpdatePath => _config["api"]["endpoints"]["taskUpdate"];
  static String get taskGetPath => _config["api"]["endpoints"]["taskGet"];
  static String get taskDeletePath => _config["api"]["endpoints"]["taskDelete"];

  static String get shopProductCreatePath => _config["api"]["endpoints"]["shopProductCreate"];
  static String get shopProductBuyPath => _config["api"]["endpoints"]["shopProductBuy"];
  static String get shopProductUpdatePath => _config["api"]["endpoints"]["shopProductUpdate"];
  static String get shopGetPath => _config["api"]["endpoints"]["shopGet"];
  static String get shopProductGetPath => _config["api"]["endpoints"]["shopProductGet"];
  static String get shopProductDeletePath => _config["api"]["endpoints"]["shopProductDelete"];

  static String get lobbyCreatePath => _config["api"]["endpoints"]["lobbyCreate"];
  static String get lobbyRemoveUserPath => _config["api"]["endpoints"]["lobbyRemoveUser"];
  static String get lobbyAddUserPath => _config["api"]["endpoints"]["lobbyAddUser"];
  static String get lobbyGetPath => _config["api"]["endpoints"]["lobbyGet"];
  static String get lobbyDeletePath => _config["api"]["endpoints"]["lobbyDelete"];


}