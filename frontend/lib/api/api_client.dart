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

  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client();

  @override
  Future<UserModel> register(UserModel request) async {

    if (request.login.isEmpty || request.password.isEmpty) {
      throw Exception('Все поля обязательны для заполнения');
    }

    if (request.password.length < 6) {
      throw Exception('Пароль должен содержать минимум 6 символов');
    }

    final url = Uri.parse(ApiEndpoints.registerUrl);

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.registerRequest()),
      ).timeout(const Duration(seconds: 10));


      return _handleUserResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  @override
  Future<UserModel> login(UserModel request) async {
    final url = Uri.parse(ApiEndpoints.loginUrl);
   //TODO
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.loginRequest()),
      ).timeout(const Duration(seconds: 10));

      return _handleUserResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: $e');
    }
  }


  @override
  //TODO
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


  @override
  Future<TaskModel> createTask(TaskModel request, int lId) async {
    if (request.name.isEmpty) {
      throw Exception('Название задачи не может быть пустым');
    }

    if (request.endPoint.isEmpty) {
      throw Exception('Дедлайн должен быть указан');
    }

    final url = Uri.parse(ApiEndpoints.taskCreateUrl);

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.createRequest(lId)),
      ).timeout(const Duration(seconds: 10));

      return _handleTaskResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  @override
  Future<TaskModel> completeTask(TaskModel task, UserModel user) async {
    if (task.id <= 0) {
      throw Exception('ID задачи не может быть меньше 1');
    }

    final url = Uri.parse(ApiEndpoints.taskUpdateUrl);
    if (user.isAdmin) {
      task.state = 2;
    } else {
      task.state = 1;
    }

    try {
      final response = await _client.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.updateRequest()),
      ).timeout(const Duration(seconds: 10));

      return _handleTaskResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  @override
  Future<LobbyModel> createLobby(LobbyModel request) async {
    final url = Uri.parse(ApiEndpoints.lobbyCreateUrl);
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.createRequest()),
      ).timeout(const Duration(seconds: 10));

      return _handleLobbyResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  @override
  Future<ProductModel> createShopItem(ProductModel request) async {
    final url = Uri.parse(ApiEndpoints.shopProductCreateUrl);

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.createRequest()),
      ).timeout(const Duration(seconds: 10));

      return _handleProductResponse(response);
    } catch (e) {
      throw Exception('Error creating shop item: ${e.toString()}');
    }
  }

  @override
  //TODO
  Future<List<ProductModel>> getShopItems() async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/shop/items');

    try {
      final response = await _client.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ProductModel.fromResponse(json)).toList();
      } else {
        throw Exception('Failed to load shop items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting shop items: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> updateShopItem(ProductModel request) async {
    final url = Uri.parse(ApiEndpoints.shopProductUpdateUrl);

    try {
      final response = await _client.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return ProductModel.fromResponse(json.decode(response.body));
      } else {
        throw Exception('Failed to update item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating shop item: ${e.toString()}');
    }
  }

  @override
  //TODO
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
  //TODO
  Future<UserModel> updateUserProfile(UserModel user) async {
    // Валидация (как в mock)
    if (user.name.isEmpty || user.email.isEmpty) {
      throw Exception('Имя и email обязательны');
    }

    final url = Uri.parse('OGO ZABYLI ENDPOINT');

    try {
      final response = await _client.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(user.toJson()),
      ).timeout(const Duration(seconds: 10));

      return _handleUserResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка сети: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: ${e.toString()}');
    }
  }

  @override
  //TODO
  Future<WalletModel> updateWallet(WalletModel request) {
    // TODO: implement updateWallet
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTask(TaskModel task) async {
    if (task.id <=0) {
      throw Exception('ID задачи не может быть меньше 1');
    }

    final url = Uri.parse(ApiEndpoints.taskDeleteUrl);

    try {
      final response = await _client.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.deleteRequest()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Ошибка при удалении задачи: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    if (task.id <= 0) {
      throw Exception('ID задачи не может быть пустым');
    }

    final url = Uri.parse(ApiEndpoints.taskUpdateUrl);

    try {
      final response = await _client.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.updateRequest()),
      ).timeout(const Duration(seconds: 10));

      return _handleTaskResponse(response);
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

  UserModel _handleUserResponse(http.Response response) {
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

  TaskModel _handleTaskResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return TaskModel.fromResponse(json.decode(response.body));
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

  LobbyModel _handleLobbyResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return LobbyModel.fromResponse(json.decode(response.body));
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

  ProductModel _handleProductResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return ProductModel.fromResponse(json.decode(response.body));
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
  Future<List<TaskModel>> getUserTasks(LobbyModel lobby, UserModel user) async {
    try {
      if (lobby.taskId.isEmpty) {
        return [];
      }

      final List<TaskModel> userTasks = [];

      for (final taskId in lobby.taskId) {
        final taskUrl = Uri.parse('${ApiEndpoints.taskGetUrl}/$taskId');
        final taskResponse = await _client.get(taskUrl)
            .timeout(const Duration(seconds: 10));

        if (taskResponse.statusCode == 200) {
          final taskJson = json.decode(taskResponse.body);
          final task = TaskModel.fromResponse(taskJson);

          if ((task.customerId == null ||
              task.customerId == user.id) &&
              lobby.customerId.contains(user.id)) {
            userTasks.add(task);
          }
        } else {
          throw Exception('Ошибка при получении задачи $taskId: ${taskResponse.statusCode}');
        }
      }

      return userTasks;
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка при получении задач: ${e.toString()}');
    }
  }

}