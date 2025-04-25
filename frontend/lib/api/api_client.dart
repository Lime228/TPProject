import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:zadachok/models/lobby/lobby_model.dart';
import '../models/shop/product/product_model.dart';
import '../models/task/task_model.dart';
import '../models/user/user_model.dart';
import '../models/wallet/wallet_model.dart';
import 'api_interface.dart';
import 'api_endpoints.dart';

class ApiClient implements ApiInterface {
  // Изменено: теперь клиент создается при каждом запросе
  http.Client get _client => http.Client();
  final String _baseUrl;

  ApiClient({String? baseUrl}) : _baseUrl = baseUrl ?? ApiEndpoints.baseUrl;

  @override
  Future<UserModel> register(UserModel request) async {
    final client = _client; // Получаем новый клиент
    try {
      final url = Uri.parse(ApiEndpoints.registerUrl);
      debugPrint('Register request to: $url');
      debugPrint('Request body: ${request.toJson()}');

      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      debugPrint('Register response: ${response.statusCode} ${response.body}');
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      debugPrint('Register client error: ${e.message}');
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      debugPrint('Register error: $e');
      throw Exception('Ошибка регистрации: $e');
    } finally {
      client.close(); // Закрываем клиент после использования
    }
  }

  @override
  Future<UserModel> login(String username, String password) async {
    final client = _client;
    try {
      final url = Uri.parse(ApiEndpoints.loginUrl);
      debugPrint('Login request to: $url');

      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'login': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      debugPrint('Login response: ${response.statusCode}');
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      debugPrint('Login client error: ${e.message}');
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      debugPrint('Login error: $e');
      throw Exception('Ошибка входа: $e');
    } finally {
      client.close();
    }
  }

  @override
  Future<void> recoverPassword({required String email, required String login}) async {
    final client = _client;
    try {
      final url = Uri.parse(ApiEndpoints.recoverPasswordUrl);
      debugPrint('Recover password request to: $url');

      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'login': login,
        }),
      ).timeout(const Duration(seconds: 10));

      debugPrint('Recover password response: ${response.statusCode}');
      _handlePasswordRecoveryResponse(response);
    } on http.ClientException catch (e) {
      debugPrint('Recover password client error: ${e.message}');
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      debugPrint('Recover password error: $e');
      throw Exception('Ошибка восстановления пароля: $e');
    } finally {
      client.close();
    }
  }

  void _handlePasswordRecoveryResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return;
      case 400:
        throw Exception('Неверный запрос: ${response.body}');
      case 404:
        throw Exception('Пользователь не найден');
      case 500:
        throw Exception('Ошибка сервера: ${response.body}');
      default:
        throw Exception('Ошибка: ${response.statusCode}');
    }
  }

  UserModel _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return UserModel.fromResponse(json.decode(response.body));
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

  @override
  void dispose() {
  }

  @override
  Future<TaskModel> completeTask(String taskId) {
    // TODO: implement completeTask
    throw UnimplementedError();
  }

  @override
  Future<LobbyModel> createLobby(LobbyModel request) {
    // TODO: implement createLobby
    throw UnimplementedError();
  }

  @override
  Future<ProductModel> createShopItem(ProductModel request) {
    // TODO: implement createShopItem
    throw UnimplementedError();
  }

  @override
  Future<TaskModel> createTask(TaskModel request) {
    // TODO: implement createTask
    throw UnimplementedError();
  }

  @override
  Future<List<TaskModel>> getUserTasks(String userId) {
    // TODO: implement getUserTasks
    throw UnimplementedError();
  }

  @override
  Future<UserModel> updateUserProfile(UserModel request) {
    // TODO: implement updateUserProfile
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTask(String taskId) {
    // TODO: implement deleteTask
    throw UnimplementedError();
  }

  @override
  Future<WalletModel> updateWallet(WalletModel request) {
    // TODO: implement updateWallet
    throw UnimplementedError();
  }
}