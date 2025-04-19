import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zadachok/models/lobby/lobby_request.dart';
import 'package:zadachok/models/lobby/lobby_response.dart';
import 'package:zadachok/models/shop/product/product_request.dart';
import 'package:zadachok/models/shop/product/product_response.dart';
import 'package:zadachok/models/task/task_request.dart';
import 'package:zadachok/models/task/task_response.dart';
import 'package:zadachok/models/user/user_update_request.dart';
import 'package:zadachok/models/wallet/wallet_request.dart';
import 'package:zadachok/models/wallet/wallet_response.dart';
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



  @override
  Future<void> recoverPassword({required String email,required String login}) async {
    final url = Uri.parse(ApiEndpoints.recoverPasswordUrl);

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'login': login,
        }),
      ).timeout(const Duration(seconds: 10));

      _handlePasswordRecoveryResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: $e');
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

  @override
  Future<TaskResponse> completeTask(String taskId) {
    // TODO: implement completeTask
    throw UnimplementedError();
  }

  @override
  Future<LobbyResponse> createLobby(LobbyRequest request) {
    // TODO: implement createLobby
    throw UnimplementedError();
  }

  @override
  Future<ProductResponse> createShopItem(ProductRequest request) {
    // TODO: implement createShopItem
    throw UnimplementedError();
  }

  @override
  Future<TaskResponse> createTask(TaskRequest request) {
    // TODO: implement createTask
    throw UnimplementedError();
  }

  @override
  Future<List<TaskResponse>> getUserTasks(String userId) {
    // TODO: implement getUserTasks
    throw UnimplementedError();
  }

  @override
  Future<UserResponse> updateUserProfile(UserUpdateRequest request) {
    // TODO: implement updateUserProfile
    throw UnimplementedError();
  }

  @override
  Future<WalletResponse> updateWallet(WalletRequest request) {
    // TODO: implement updateWallet
    throw UnimplementedError();
  }
}