import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_interface.dart';
import 'api_endpoints.dart';
import '../models/user/register_request.dart';
import '../models/user/user_response.dart';

class ApiClient implements ApiInterface {
  final http.Client _client;
  final String _baseUrl;

  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiEndpoints.baseUrl;

  @override
  Future<UserResponse> register(RegisterRequest request) async {
    final url = Uri.parse(ApiEndpoints.registerUrl);

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  @override
  Future<UserResponse> login(String username, String password) async {
    final url = Uri.parse(ApiEndpoints.loginUrl);

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'login': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  UserResponse _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return UserResponse.fromJson(json.decode(response.body));
      case 400:
        throw Exception('Неверный запрос: ${response.body}');
      case 401:
        throw Exception('Ошибка авторизации');
      case 500:
        throw Exception('Ошибка сервера: ${response.body}');
      default:
        throw Exception('Ошибка: ${response.statusCode}');
    }
  }

  void dispose() {
    _client.close();
  }
}