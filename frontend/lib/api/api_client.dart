import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zadachok/models/lobby/lobby_model.dart';
import '../models/shop/product/product_model.dart';
import '../models/task/task_model.dart';
import '../models/user/user_model.dart';
import '../models/wallet/wallet_model.dart';
import 'api_interface.dart';
import 'api_endpoints.dart';

class ApiClient implements ApiInterface {
  final http.Client _client;
  final String _baseUrl;

  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiEndpoints.baseUrl;

  @override
  Future<UserModel> register(UserModel request) async {
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
  Future<UserModel> login(String username, String password) async {
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
    _client.close();
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
  Future<ProductModel> createShopItem(ProductModel request) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/shop/items');

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return ProductModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating shop item: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductModel>> getShopItems() async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/shop/items');

    try {
      final response = await _client.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load shop items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting shop items: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> updateShopItem(ProductModel request) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/shop/items/${request.id}');

    try {
      final response = await _client.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return ProductModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating shop item: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteShopItem(String itemId) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/shop/items/$itemId');

    try {
      final response = await _client.delete(url).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting shop item: ${e.toString()}');
    }
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
  Future<WalletModel> updateWallet(WalletModel request) {
    // TODO: implement updateWallet
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTask(String taskId) {
    // TODO: implement deleteTask
    throw UnimplementedError();
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) {
    // TODO: implement updateTask
    throw UnimplementedError();
  }
}