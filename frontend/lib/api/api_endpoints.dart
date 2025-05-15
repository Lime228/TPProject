import 'package:zadachok/api/endpoints_config_parse.dart';

class ApiEndpoints {
  static final String _baseUrl = EndpointsConfigParse.baseUrl;
  static final String _registerPath = EndpointsConfigParse.registerPath;
  static final String _loginPath = EndpointsConfigParse.loginPath;

  static final String _recoverPasswordPath = EndpointsConfigParse.recoverPasswordPath;

  static final String _tasksPath = EndpointsConfigParse.tasksPath;



  static String get baseUrl => _baseUrl;
  static String get registerUrl => _baseUrl + _registerPath;
  static String get loginUrl => _baseUrl + _loginPath;

  static String get recoverPasswordUrl => _baseUrl + _recoverPasswordPath;

  static String get tasksUrl => _baseUrl + _tasksPath;

}