class ApiEndpoints {
  static const String _baseUrl = "https://zadachok.ru:8090";
  static const String _registerPath = "/api/auth/register";
  static const String _loginPath = "/api/auth/login";

  static const String _recoverPasswordPath = "/api/auth/recover-password";

  static const String _tasksPath = "/api/tasks";

  static String get baseUrl => _baseUrl;
  static String get registerUrl => _baseUrl + _registerPath;
  static String get loginUrl => _baseUrl + _loginPath;

  static String get recoverPasswordUrl => _baseUrl + _recoverPasswordPath;

  static String get tasksUrl => _baseUrl + _tasksPath;

}