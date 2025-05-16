import 'package:zadachok/api/endpoints_config_parse.dart';

class ApiEndpoints {
  static final String _baseUrl = EndpointsConfigParse.baseUrl;
  static final String _registerPath = EndpointsConfigParse.registerPath;
  static final String _loginPath = EndpointsConfigParse.loginPath;
  static final String _recoverPasswordPath = EndpointsConfigParse.recoverPasswordPath;

  // Task endpoints
  static final String _taskCreatePath = EndpointsConfigParse.taskCreatePath;
  static final String _taskUpdatePath = EndpointsConfigParse.taskUpdatePath;
  static final String _taskGetPath = EndpointsConfigParse.taskGetPath;
  static final String _taskDeletePath = EndpointsConfigParse.taskDeletePath;

  // Shop endpoints
  static final String _shopProductCreatePath = EndpointsConfigParse.shopProductCreatePath;
  static final String _shopProductBuyPath = EndpointsConfigParse.shopProductBuyPath;
  static final String _shopProductUpdatePath = EndpointsConfigParse.shopProductUpdatePath;
  static final String _shopGetPath = EndpointsConfigParse.shopGetPath;
  static final String _shopProductGetPath = EndpointsConfigParse.shopProductGetPath;
  static final String _shopProductDeletePath = EndpointsConfigParse.shopProductDeletePath;

  // Lobby endpoints
  static final String _lobbyCreatePath = EndpointsConfigParse.lobbyCreatePath;
  static final String _lobbyRemoveUserPath = EndpointsConfigParse.lobbyRemoveUserPath;
  static final String _lobbyAddUserPath = EndpointsConfigParse.lobbyAddUserPath;
  static final String _lobbyGetPath = EndpointsConfigParse.lobbyGetPath;
  static final String _lobbyDeletePath = EndpointsConfigParse.lobbyDeletePath;



  static String get baseUrl => _baseUrl;

  // Auth endpoints
  static String get registerUrl => _baseUrl + _registerPath;
  static String get loginUrl => _baseUrl + _loginPath;
  static String get recoverPasswordUrl => _baseUrl + _recoverPasswordPath;

  // Task endpoints
  static String get taskCreateUrl => _baseUrl + _taskCreatePath;
  static String get taskUpdateUrl => _baseUrl + _taskUpdatePath;
  static String get taskGetUrl => _baseUrl + _taskGetPath;
  static String get taskDeleteUrl => _baseUrl + _taskDeletePath;

  // Shop endpoints
  static String get shopProductCreateUrl => _baseUrl + _shopProductCreatePath;
  static String get shopProductBuyUrl => _baseUrl + _shopProductBuyPath;
  static String get shopProductUpdateUrl => _baseUrl + _shopProductUpdatePath;
  static String get shopGetUrl => _baseUrl + _shopGetPath;
  static String get shopProductGetUrl => _baseUrl + _shopProductGetPath;
  static String get shopProductDeleteUrl => _baseUrl + _shopProductDeletePath;

  // Lobby endpoints
  static String get lobbyCreateUrl => _baseUrl + _lobbyCreatePath;
  static String get lobbyRemoveUserUrl => _baseUrl + _lobbyRemoveUserPath;
  static String get lobbyAddUserUrl => _baseUrl + _lobbyAddUserPath;
  static String get lobbyGetUrl => _baseUrl + _lobbyGetPath;
  static String get lobbyDeleteUrl => _baseUrl + _lobbyDeletePath;
}