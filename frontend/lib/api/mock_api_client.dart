import 'dart:async';
import 'package:flutter/cupertino.dart';
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
        isAdmin: true
    );
  }

  @override
  @override
  Future<UserModel> login(UserModel request) async {

    String username = request.login;
    String password = request.password;
    print("Login attempt with username: $username, password: $password");


    await Future.delayed(Duration(seconds: 2));


    if (username == 'admin' && password == 'admin') {
      return UserModel(
        id: 999,
        name: 'Admin User',
        email: 'admin@example.com',
        birthdayDate: DateTime(1980, 1, 1),
        login: 'admin',
        isAdmin: true, // Администратор
      );
    }
    else {
      throw Exception('Invalid credentials');
    }
  }

  Future<Map<String, dynamic>> checkGroupMembership(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));


    return {
      'isMember': false,
      'isAdmin': false,
      'groupCode': null,
      'groupName': null
    };
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
  Future<TaskModel> completeTask(TaskModel task, UserModel user) async {
    await Future.delayed(const Duration(seconds: 1));

    if (task.id<=0) {
      throw Exception('ID задачи не может быть пустым');
    }

    return TaskModel(
      id: task.id,
      name: 'Завершенная задача',
      reward: 100,
      description: '',
      startPoint: 'Начальная точка',
      endPoint: 'Конечная точка',
      customerId: 1,
      state: 1,
    );
  }

  @override
  Future<LobbyModel> createLobby(LobbyModel request) async {
    await Future.delayed(const Duration(seconds: 1));



    return LobbyModel(
      id: DateTime.now().millisecondsSinceEpoch,
      taskId: request.taskId,
      shopId: request.shopId,
      customerId: request.customerId,
    );
  }



  @override
  Future<TaskModel> createTask(TaskModel request, int id) async {
    debugPrint('Создаем задачу: ${request.toJson()}');

    await Future.delayed(const Duration(seconds: 1));

    if (request.name.isEmpty) {
      throw Exception('Название задачи не может быть пустым');
    }

    if (request.endPoint.isEmpty) {
      throw Exception('Дедлайн должен быть указан');
    }

    return TaskModel(
      id: DateTime.now().millisecondsSinceEpoch,
      name: request.name,
      description: request.description,
      startPoint: DateTime.now().toIso8601String(),
      endPoint: request.endPoint,
      reward: request.reward,
      customerId: request.customerId,
      state: 1,
    );
  }

  @override
  Future<List<TaskModel>> getUserTasks(LobbyModel lobby, UserModel user) async {
    await Future.delayed(const Duration(seconds: 1));

    if (user.id <= 0) {
      throw Exception('ID пользователя не может быть пустым');
    }

    return [
      TaskModel(
        id: 1,
        name: 'Тестовая задача 1',
        reward: 50,
        description: 'Описание тестовой задачи',
        startPoint: 'Точка A',
        endPoint: 'Точка B',
        customerId: (user.id),
        state: 0,
      ),
      TaskModel(
        id: 2,
        name: 'Тестовая задача 2',
        reward: 75,
        description: 'Описание второй задачи',
        startPoint: 'Точка C',
        endPoint: 'Точка D',
        customerId: (user.id),
        state: 1,
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
  Future<void> deleteTask(TaskModel task) async {
    debugPrint('Удаление задачи ID: $task');
    await Future.delayed(const Duration(milliseconds: 500));

    if (task.id <= 0) {
      throw Exception('ID задачи не может быть пустым');
    }

  }

  @override
  Future<TaskModel> updateTask(TaskModel task) {
    // TODO: implement updateTask
    throw UnimplementedError();
  }

  @override
  Future<List<ProductModel>> getShopItems() async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Future<ProductModel> createShopItem(ProductModel request) async {
    await Future.delayed(const Duration(seconds: 1));
    return request;
  }

  @override
  Future<ProductModel> updateShopItem(ProductModel request) async {
    await Future.delayed(const Duration(seconds: 1));
    return request;
  }

  @override
  Future<void> deleteShopItem(String itemId) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}