import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/register_request.dart';
import '../models/user_response.dart';
import 'api_endpoints.dart';

class ApiClient {
  final http.Client _client;
  final String _baseUrl;

  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiEndpoints.baseUrl;

  Future<UserResponse> register(RegisterRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return UserResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Ошибка регистрации: ${response.body}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}