import 'package:zadachok/api/endpoints_config_parse.dart';

class ApiEndpoints {
  static String get baseUrl => EndpointsConfigParse.baseUrl;
  static String get registerUrl => EndpointsConfigParse.baseUrl + EndpointsConfigParse.registerPath;
  static String get loginUrl => EndpointsConfigParse.baseUrl + EndpointsConfigParse.loginPath;
  static String get recoverPasswordUrl => EndpointsConfigParse.baseUrl + EndpointsConfigParse.recoverPasswordPath;
  static String get tasksUrl => EndpointsConfigParse.baseUrl + EndpointsConfigParse.tasksPath;

}