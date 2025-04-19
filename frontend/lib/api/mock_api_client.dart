import 'dart:async';
import 'package:zadachok/models/user/user_model.dart';
import '../models/lobby/lobby_model.dart';
import '../models/shop/product/product_model.dart';
import '../models/task/task_model.dart';
import '../models/wallet/wallet_model.dart';
import 'api_interface.dart';

class MockApiClient implements ApiInterface {
  const MockApiClient();

  @override
  Future<UserModel> register(UserModel request) async {
    await Future.delayed(const Duration(seconds: 1));

    if (request.login.isEmpty || request.password.isEmpty) {
      throw Exception('Все поля обязательны для заполнения');
    }

    if (request.password.length < 6) {
      throw Exception('Пароль должен содержать минимум 6 символов');
    }

    return UserModel(
        id: DateTime.now().millisecondsSinceEpoch,
        name: 'razdva',
        email: request.email,
        birthdayDate: DateTime.parse('1969-07-20 20:18:04Z'),
        login: request.login,
        isAdmin: false
    );
  }

  @override
  Future<UserModel> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (username != 'test' || password != 'test123') {
      throw Exception('Неверные учетные данные');
    }

    return UserModel(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        birthdayDate: DateTime.parse('1990-01-01'),
        login: username,
        isAdmin: false
    );
  }

  @override
  Future<void> recoverPassword({required String email, required String login}) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email.isEmpty || login.isEmpty) {
      throw Exception('Пожалуйста, заполните все поля');
    }

    if (!email.contains('@')) {
      throw Exception('Некорректный email');
    }
  }

  @override
  Future<TaskModel> completeTask(String taskId) async {
    await Future.delayed(const Duration(seconds: 1));

    if (taskId.isEmpty) {
      throw Exception('ID задачи не может быть пустым');
    }

    return TaskModel(
      id: int.parse(taskId),
      name: 'Завершенная задача',
      reward: 100.0,
      description: 'Описание завершенной задачи',
      startPoint: 'Начальная точка',
      endPoint: 'Конечная точка',
      customerId: 1,
      state: 'Completed',
    );
  }

  @override
  Future<LobbyModel> createLobby(LobbyModel request) async {
    await Future.delayed(const Duration(seconds: 1));

    if (request.taskId <= 0 || request.shopId <= 0 || request.customerId <= 0) {
      throw Exception('Неверные параметры лобби');
    }

    return LobbyModel(
      id: DateTime.now().millisecondsSinceEpoch,
      taskId: request.taskId,
      shopId: request.shopId,
      customerId: request.customerId,
    );
  }

  @override
  Future<ProductModel> createShopItem(ProductModel request) async {
    await Future.delayed(const Duration(seconds: 1));

    if (request.name.isEmpty || request.price <= 0) {
      throw Exception('Название и цена обязательны');
    }

    return ProductModel(
      id: DateTime.now().millisecondsSinceEpoch,
      name: request.name,
      description: request.description,
      photo: request.photo,
      state: 'Available',
      price: request.price,
      customerId: request.customerId,
    );
  }

  @override
  Future<TaskModel> createTask(TaskModel request) async {
    await Future.delayed(const Duration(seconds: 1));

    if (request.name.isEmpty || request.reward <= 0) {
      throw Exception('Название и награда обязательны');
    }

    return TaskModel(
      id: DateTime.now().millisecondsSinceEpoch,
      name: request.name,
      reward: request.reward,
      description: request.description,
      startPoint: request.startPoint,
      endPoint: request.endPoint,
      customerId: request.customerId,
      state: 'Pending',
    );
  }

  @override
  Future<List<TaskModel>> getUserTasks(String userId) async {
    await Future.delayed(const Duration(seconds: 1));

    if (userId.isEmpty) {
      throw Exception('ID пользователя не может быть пустым');
    }

    return [
      TaskModel(
        id: 1,
        name: 'Тестовая задача 1',
        reward: 50.0,
        description: 'Описание тестовой задачи',
        startPoint: 'Точка A',
        endPoint: 'Точка B',
        customerId: int.parse(userId),
        state: 'In Progress',
      ),
      TaskModel(
        id: 2,
        name: 'Тестовая задача 2',
        reward: 75.0,
        description: 'Описание второй задачи',
        startPoint: 'Точка C',
        endPoint: 'Точка D',
        customerId: int.parse(userId),
        state: 'Pending',
      ),
    ];
  }

  @override
  Future<UserModel> updateUserProfile(UserModel request) async {
    await Future.delayed(const Duration(seconds: 1));

    if (request.name.isEmpty || request.email.isEmpty) {
      throw Exception('Имя и email обязательны');
    }

    return UserModel(
      id: 0,
      name: request.name,
      email: request.email,
      birthdayDate: request.birthdayDate,
      login: request.login,
      isAdmin: false,
    );
  }

  @override
  Future<WalletModel> updateWallet(WalletModel request) async {
    await Future.delayed(const Duration(seconds: 1));

    if (request.customerId <= 0 || request.balance < 0) {
      throw Exception('Неверные параметры кошелька');
    }

    return WalletModel(
      id: DateTime.now().millisecondsSinceEpoch,
      customerId: request.customerId,
      lobbyId: request.lobbyId,
      balance: request.balance,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
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