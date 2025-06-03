import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:zadachok/models/lobby/lobby_model.dart';
import '../models/shop/product/product_model.dart';
import '../models/shop/shop_model.dart';
import '../models/task/task_model.dart';
import '../models/user/user_model.dart';
import '../models/wallet/wallet_model.dart';
import 'api_interface.dart';
import 'api_endpoints.dart';

class ApiClient implements ApiInterface {
  final http.Client _client;
  String? _authToken;
  static const Duration requestTimeout = Duration(minutes: 1);

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  String? getAuthToken() => _authToken;


  void setAuthToken(String token) {
    _authToken = token;
  }


  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
    };

    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }



  @override // работает проверяли
  Future<UserModel> register(UserModel request) async {
    final registerUrl = Uri.parse(ApiEndpoints.registerUrl);
    try {
      if (request.login.isEmpty || request.password!.isEmpty) {
        throw Exception('Все поля обязательны для заполнения');
      }
      if (request.password!.length < 6) {
        throw Exception('Пароль должен содержать минимум 6 символов');
      }

      final registerResponse = await _client.post(
        registerUrl,
        headers: _getHeaders(includeAuth: false),
        body: json.encode(request.toRegisterRequest()),
      ).timeout(requestTimeout);

      if (registerResponse.statusCode != 201) {
        throw Exception('Ошибка регистрации: ${registerResponse.statusCode}');
      }

      final registerData = json.decode(registerResponse.body);
      final token = registerData['token'] as String;
      _authToken = token;


      final userDataUrl = Uri.parse('${ApiEndpoints.baseUrl}/api/auth/login/${request.login}');
      final userResponse = await _client.get(
        userDataUrl,
        headers: _getHeaders(),
      ).timeout(requestTimeout);


      return _handleUserResponse(userResponse);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  @override // работает проверяли
  Future<UserModel> login(UserModel request) async {
    final loginUrl = Uri.parse(ApiEndpoints.loginUrl);
    try {
      final loginResponse = await _client.post(
        loginUrl,
        headers: _getHeaders(includeAuth: false),
        body: json.encode(request.toLoginRequest()),
      ).timeout(requestTimeout);

      if (loginResponse.statusCode != 200) {
        throw Exception('Ошибка авторизации: ${loginResponse.statusCode}');
      }

      final loginData = json.decode(loginResponse.body);


      final token = loginData['token'] as String?;
      if (token == null) {
        throw Exception('Токен не получен от сервера');
      }
      _authToken = token;

      //блок ниже можно заменить getbylogin но чето стремно пока надо подумать
      final userDataUrl = Uri.parse('${ApiEndpoints.loginUrl}/${request.login}');

      final userResponse = await _client.get(
        userDataUrl,
        headers: {'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_authToken'},
      ).timeout(requestTimeout);

      if (userResponse.statusCode != 200) {
        throw Exception('Ошибка получения данных пользователя: ${userResponse.statusCode}');
      }

      return _handleUserResponse(userResponse);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Ошибка формата данных: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  @override
  Future<bool> restorePassword(UserModel request) async {
    final restoreUrl = Uri.parse('${ApiEndpoints.baseUrl}/api/auth/restore');
    try {
      final response = await _client.post(
        restoreUrl,
        headers: _getHeaders(includeAuth: false),
        body: json.encode(request.toRestoreRequest()),
      ).timeout(requestTimeout);

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        debugPrint(responseBody['message']);
        return true;
      } else {
        final errorMessage = responseBody['message'] ?? 'Неизвестная ошибка';
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Ошибка формата данных: ${e.message}');
    }
  }
  Future<bool> resetPassword(UserModel request, String code, String password) async {
    final resetUrl = Uri.parse('${ApiEndpoints.baseUrl}/api/auth/reset-password');
    try {
      final response = await _client.post(
        resetUrl,
        headers: _getHeaders(includeAuth: false),
        body: json.encode(request.toResetRequest(code, password)),
      ).timeout(requestTimeout);

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        debugPrint(responseBody['message']);
        return true;
      } else if (response.statusCode == 400) {
        final errorMessage = responseBody['message'] ?? 'Неверный или просроченный код';
        throw Exception(errorMessage);
      } else {
        final errorMessage = responseBody['message'] ?? 'Неизвестная ошибка (${response.statusCode})';
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Ошибка формата данных: ${e.message}');
    }
  }

  @override // в теории работает
  Future<UserModel> updateUserProfile(UserModel user) async {
    if (user.name.isEmpty || user.email.isEmpty) {
      throw Exception('Имя и email обязательны');
    }

    final url = Uri.parse('${ApiEndpoints.baseUrl}/api/auth/update'); // напомните добавить эндпоинт по человечески

    try {
      final response = await _client.put(
        url,
        headers: _getHeaders(),
        body: json.encode(user.toUpdateRequest()),
      ).timeout(requestTimeout);

      return _handleUserResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка сети: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: ${e.toString()}');
    }
  }

  // Future<UserModel> deleteUserProfile(UserModel user) async {  } ЕЩЕ НЕТУ РЕАЛИЗАЦИИ С БЭКА

  // в теории работает
  Future<UserModel> getUserById(UserModel request) async {
    final getURL = Uri.parse('${ApiEndpoints.baseUrl}/api/auth/${request.id}'); // напомните перестать хардкодить эндпоинты
    try {

      final userResponse = await _client.get(
        getURL,
        headers: {'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_authToken'},
      ).timeout(requestTimeout);

      if (userResponse.statusCode != 200) {
        throw Exception('Ошибка получения данных пользователя: ${userResponse.statusCode}');
      }

      return _handleUserResponse(userResponse);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Ошибка формата данных: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  // в теории работает
  Future<UserModel> getUserByLogin(UserModel request) async {
    final userDataUrl = Uri.parse('${ApiEndpoints.loginUrl}/${request.login}');
    try {
      final userResponse = await _client.get(
        userDataUrl,
        headers: {'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_authToken'},
      ).timeout(requestTimeout);

      if (userResponse.statusCode != 200) {
        throw Exception('Ошибка получения данных пользователя: ${userResponse.statusCode}');
      }

      return _handleUserResponse(userResponse);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Ошибка формата данных: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  @override // еще не существует
  Future<void> recoverPassword({required String email, required String login}) async {
    final url = Uri.parse(ApiEndpoints.recoverPasswordUrl);

    try {
      final response = await _client.post(
        url,
        headers: _getHeaders(),
        body: json.encode({
          'email': email,
          'login': login,
        }),
      ).timeout(requestTimeout);

      _handlePasswordRecoveryResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: $e');
    }
  }




  @override // в теории работает
  Future<LobbyModel> lobbyAddUser(String code, int userId) async {
    final url = Uri.parse(ApiEndpoints.lobbyAddUserUrl);
    LobbyModel lobby = new LobbyModel(taskId: [0], shopId: 0, customerId: [0], code: code);
    try {
      final response = await _client.patch(
        url,
        headers: _getHeaders(),
        body: json.encode(lobby.addRequest(userId)),
      ).timeout(requestTimeout);

      return _handleLobbyResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка добавления пользователя: $e');
    }
  }

  @override // вроде проверяли, работает (не уверен)
  Future<LobbyModel> createLobby(int creatorID) async {
    final url = Uri.parse(ApiEndpoints.lobbyCreateUrl);
    try {
      final headers = _getHeaders();
      debugPrint('Headers for createLobby: $headers');

      LobbyModel lobbyModel = LobbyModel(
        taskId: [],
        shopId: 0,
        customerId: [],
      );

      final response = await _client.post(
        url,
        headers: headers,
        body: json.encode(lobbyModel.createRequest(creatorID)),
      ).timeout(requestTimeout);

      return _handleLobbyResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  @override // в теории работает
  Future<LobbyModel> lobbyRemoveUser(int lobbyId, int userId) async {
    final url = Uri.parse(ApiEndpoints.lobbyRemoveUserUrl);
    LobbyModel lobby = new LobbyModel(taskId: [0], shopId: 0, customerId: [0], id: lobbyId);
    try {
      final response = await _client.patch(
        url,
        headers: _getHeaders(),
        body: json.encode(lobby.removeRequest(userId)),
      ).timeout(requestTimeout);

      return _handleLobbyResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка добавления пользователя: $e');
    }
  }

  @override // в теории работает
  Future<LobbyModel> getLobby(int lobbyID) async {
    final url = Uri.parse('${ApiEndpoints.lobbyGetUrl}/${lobbyID}');
    try {
      final response = await _client.get(
        url,
        headers: _getHeaders(),
      ).timeout(requestTimeout);

      return _handleLobbyResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  @override // в теории работает
  Future<LobbyModel> getLobbyByUserId(int userID) async {
    final url = Uri.parse('${ApiEndpoints.lobbyGetUrl}/customer/${userID}');
    try {
      final response = await _client.get(
        url,
        headers: _getHeaders(),
      ).timeout(requestTimeout);

      return _handleLobbyResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  @override // в теории работает
  Future<LobbyModel> deleteLobby(int lobbyId) async {
    final url = Uri.parse(ApiEndpoints.lobbyDeleteUrl);
    LobbyModel lobby = new LobbyModel(id: lobbyId, taskId: [0], shopId: 0, customerId: [0]);
    try {
      final response = await _client.delete(
        url,
        headers: _getHeaders(),
        body: json.encode(lobby.deleteRequest()),
      ).timeout(requestTimeout);

      return _handleLobbyResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка добавления пользователя: $e');
    }
  }



  @override // в теории работает
  Future<ProductModel> createShopItem(ShopModel shop, ProductModel product) async {
    final url = Uri.parse(ApiEndpoints.shopProductCreateUrl);
    debugPrint(product.id.toString());
    debugPrint(shop.id.toString());
    debugPrint(product.name);
    debugPrint(product.description);
    debugPrint(product.isAvailable.toString());
    debugPrint(product.price.toString());
    debugPrint(product.link);
    debugPrint(product.customerId.toString());

    try {
      final response = await _client.post(
        url,
        headers: _getHeaders(),
        body: json.encode(shop.createProductRequest(product)),
      ).timeout(requestTimeout);

      return _handleProductResponse(response);
    } catch (e) {
      throw Exception('Error creating shop product: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> buyShopItem(int shopId, int productId, int customerId) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/api/shop/product/buy');

    try {
      final response = await _client.post(
        url,
        headers: _getHeaders(),
        body: json.encode({
          'shopId': shopId,
          'productId': productId,
          'customerId': customerId,
        }),
      ).timeout(requestTimeout);

      return _handleProductResponse(response);
    } catch (e) {
      throw Exception('Ошибка резервирования товара: $e');
    }
  }

  //а нужен ли гет для магазина?

  @override // в теории должно работать
  Future<List<ProductModel>> getShopProducts(int shopID) async {
    final url = Uri.parse('${ApiEndpoints.shopGetUrl}/${shopID}');

    try {
      final response = await _client.get(
        url,
        headers: _getHeaders(),
      );
      ShopModel shop = new ShopModel.fromResponse(json.decode(response.body));

      List<ProductModel> products = [];
      for (int productId in shop.productIds) {
        final productUrl = Uri.parse('${ApiEndpoints.shopProductGetUrl}/${productId}');
        final productResponse = await _client.get(
          productUrl,
          headers: _getHeaders(),
        );
        products.add(_handleProductResponse(productResponse));
      }
      return products;
    } catch (e) {
      throw Exception('Failed to load products: ${e.toString()}');
    }
  }



  @override
  Future<void> deleteShopItem(int shopId, int productId) async {
    if (shopId <= 0 || productId <= 0) {
      throw Exception('ID магазина и товара не могут быть пустыми');
    }

    final url = Uri.parse(ApiEndpoints.shopProductDeleteUrl);

    try {
      final response = await _client.delete(
        url,
        headers: _getHeaders(),
        body: json.encode({
          'shopid': shopId,
          'productid': productId
        }),
      ).timeout(requestTimeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Ошибка при удалении товара: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  @override
  Future<ProductModel> updateShopItem(ProductModel product) async {
    final url = Uri.parse(ApiEndpoints.shopProductUpdateUrl);

    try {
      final response = await _client.patch(
        url,
        headers: _getHeaders(),
        body: json.encode({
          'productid': product.id, // Убедимся, что ID передается
          'name': product.name,
          'description': product.description,
          'photo': product.photoBytes,
          'state': product.isAvailable,
          'price': product.price,
          'link': product.link,
        }),
      ).timeout(requestTimeout);

      return _handleProductResponse(response);
    } catch (e) {
      throw Exception('Ошибка обновления товара: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> generateNotification(int taskId) async {
    final url = Uri.parse('${ApiEndpoints.notificationCreateUrl}/$taskId');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Bearer $_authToken'},
      ).timeout(requestTimeout);

      if (response.statusCode != 200 && response.statusCode != 202) {
        throw Exception('Ошибка генерации уведомления: ${response.statusCode}');
      }

      return json.decode(utf8.decode(response.bodyBytes));
    } catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getNotificationStatus(String notificationId) async {
    final url = Uri.parse('${ApiEndpoints.notificationGetUrl}/$notificationId');
    try {
      final response = await _client.get(
        url,
        headers: {'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Bearer $_authToken'},
      ).timeout(requestTimeout);

      if (response.statusCode != 200 && response.statusCode != 202) {
        throw Exception('Ошибка получения статуса уведомления: ${response.statusCode}');
      }

      return json.decode(utf8.decode(response.bodyBytes));
    } catch (e) {
      throw Exception('Ошибка: $e');
    }
  }



  @override
  Future<void> deleteTask(TaskModel task) async {
    if (task.id <= 0) {
      throw Exception('ID задачи не может быть меньше 1');
    }

    final url = Uri.parse(ApiEndpoints.taskDeleteUrl);

    try {
      final response = await _client.delete(
        url,
        headers: _getHeaders(),
        body: json.encode(task.deleteRequest()),
      ).timeout(requestTimeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Ошибка при удалении задачи: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  @override // в теории работает
  Future<TaskModel> updateTask(TaskModel task) async {
    if (task.id <= 0) {
      throw Exception('ID задачи не может быть пустым');
    }

    final url = Uri.parse(ApiEndpoints.taskUpdateUrl);

    try {
      final response = await _client.patch(
        url,
        headers: _getHeaders(),
        body: json.encode(task.updateRequest()),
      ).timeout(requestTimeout);

      return _handleTaskResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  @override // ОБЯЗАНО РАБОТАТЬ, В ПРОТИВНОМ СЛУЧАЕ Я БРЕЮСЬ НАЛЫСО
  Future<List<TaskModel>> getUserTasks(LobbyModel lobby, UserModel user) async {
    try {
      if (lobby.taskId.isEmpty) {
        return [];
      }

      final List<TaskModel> userTasks = [];

      for (final taskId in lobby.taskId) {
        final taskUrl = Uri.parse('${ApiEndpoints.taskGetUrl}/$taskId');
        final taskResponse = await _client.get(
          taskUrl,
          headers: _getHeaders(),
        ).timeout(requestTimeout);

        if (taskResponse.statusCode == 200) {
          final task = _handleTaskResponse(taskResponse);
          userTasks.add(task);
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

  @override // в теории работает
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
        headers: _getHeaders(),
        body: json.encode(request.createRequest(lId)),
      ).timeout(requestTimeout);

      return _handleTaskResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  @override // в теории работает
  @override
  Future<TaskModel> completeTask(TaskModel task, UserModel user) async {
    if (task.id <= 0) {
      throw Exception('ID задачи не может быть меньше 1');
    }

    final newState = user.role.isAdmin ? 2 : 1;

    final updatedTask = task.copyWith(state: newState);

    final url = Uri.parse(ApiEndpoints.taskUpdateUrl);
    try {
      final response = await _client.patch(
        url,
        headers: _getHeaders(),
        body: json.encode(updatedTask.updateRequest()),
      ).timeout(requestTimeout);

      return _handleTaskResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Ошибка подключения: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Ошибка: $e');
    }
  }

  @override
  Future<WalletModel> updateWallet(WalletModel request) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/api/shop/wallet/${request.customerId}');
    try {
      final response = await _client.get(
        url,
        headers: _getHeaders(),
      ).timeout(requestTimeout);

      return _handleWalletResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Connection error: ${e.message}');
    } on Exception catch (e) {
      throw Exception('Error: $e');
    }
  }

  WalletModel _handleWalletResponse(http.Response response) {
    final responseData = json.decode(utf8.decode(response.bodyBytes));

    switch (response.statusCode) {
      case 200:
      case 201:
        return WalletModel.fromJson(responseData);
      case 400:
        throw Exception('Invalid request: ${utf8.decode(response.bodyBytes)}');
      case 401:
        throw Exception('Authorization error');
      case 500:
        throw Exception('Server error: ${utf8.decode(response.bodyBytes)}');
      default:
        throw Exception('Error: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    _client.close();
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
    final responseData = json.decode(utf8.decode(response.bodyBytes));
    debugPrint('User response data: $responseData');

    switch (response.statusCode) {
      case 200:
      case 201:
        return UserModel.fromResponse(responseData);
      case 400:
        throw Exception('Неверный запрос: ${utf8.decode(response.bodyBytes)}');
      case 401:
        throw Exception('Ошибка авторизации');
      case 500:
        throw Exception('Ошибка сервера: ${utf8.decode(response.bodyBytes)}');
      default:
        throw Exception('Ошибка: ${response.statusCode}');
    }
  }

  TaskModel _handleTaskResponse(http.Response response) {
    final responseData = json.decode(utf8.decode(response.bodyBytes));

    switch (response.statusCode) {
      case 200:
      case 201:
        return TaskModel.fromResponse(responseData);
      case 400:
        throw Exception('Неверный запрос: ${utf8.decode(response.bodyBytes)}');
      case 401:
        throw Exception('Ошибка авторизации');
      case 500:
        throw Exception('Ошибка сервера: ${utf8.decode(response.bodyBytes)}');
      default:
        throw Exception('Ошибка: ${response.statusCode}');
    }
  }

  LobbyModel _handleLobbyResponse(http.Response response) {
    final responseData = json.decode(utf8.decode(response.bodyBytes));

    switch (response.statusCode) {
      case 200:
      case 201:
        return LobbyModel.fromResponse(responseData);
      case 400:
        throw Exception('Неверный запрос: ${utf8.decode(response.bodyBytes)}');
      case 401:
        throw Exception('Ошибка авторизации');
      case 500:
        throw Exception('Ошибка сервера: ${utf8.decode(response.bodyBytes)}');
      default:
        throw Exception('Ошибка: ${response.statusCode}');
    }
  }

  ProductModel _handleProductResponse(http.Response response) {
    final responseData = json.decode(utf8.decode(response.bodyBytes));

    switch (response.statusCode) {
      case 200:
      case 201:
        return ProductModel.fromJson(responseData);
      case 400:
        throw Exception('Неверный запрос: ${utf8.decode(response.bodyBytes)}');
      case 401:
        throw Exception('Ошибка авторизации');
      case 500:
        throw Exception('Ошибка сервера: ${utf8.decode(response.bodyBytes)}');
      default:
        throw Exception('Ошибка: ${response.statusCode}');
    }
  }



}