import 'dart:async';
import 'package:zadachok/models/lobby/lobby_request.dart';

import 'package:zadachok/models/lobby/lobby_response.dart';

import 'package:zadachok/models/shop/product/product_request.dart';

import 'package:zadachok/models/shop/product/product_response.dart';

import 'package:zadachok/models/task/task_request.dart';

import 'package:zadachok/models/task/task_response.dart';

import 'package:zadachok/models/user/user_update_request.dart';

import 'package:zadachok/models/wallet/wallet_request.dart';

import 'package:zadachok/models/wallet/wallet_response.dart';

import '../models/user/register_request.dart';
import '../models/user/user_response.dart';
import 'api_interface.dart';

class MockApiClient implements ApiInterface {
  const MockApiClient();

  @override
  Future<UserResponse> register(RegisterRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    if (request.login.isEmpty || request.password.isEmpty) {
      throw Exception('Все поля обязательны для заполнения');
    }

    if (request.password.length < 6) {
      throw Exception('Пароль должен содержать минимум 6 символов');
    }

    return UserResponse(
        id: DateTime.now().millisecondsSinceEpoch,
        name: 'razdva',
        email: request.email,
        birthdayDate: DateTime.parse('1969-07-20 20:18:04Z'),
        login: request.login,
        isAdmin: false
    );
  }

  @override
  Future<UserResponse> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (username != 'test' || password != 'test123') {
      throw Exception('Неверные учетные данные');
    }

    return UserResponse(
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
  Future<TaskResponse> completeTask(String taskId) async {
    await Future.delayed(const Duration(seconds: 1));

    if (taskId.isEmpty) {
      throw Exception('ID задачи не может быть пустым');
    }

    return TaskResponse(
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
  Future<LobbyResponse> createLobby(LobbyRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    if (request.taskId <= 0 || request.shopId <= 0 || request.customerId <= 0) {
      throw Exception('Неверные параметры лобби');
    }

    return LobbyResponse(
      id: DateTime.now().millisecondsSinceEpoch,
      taskId: request.taskId,
      shopId: request.shopId,
      customerId: request.customerId,
    );
  }

  @override
  Future<ProductResponse> createShopItem(ProductRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    if (request.name.isEmpty || request.price <= 0) {
      throw Exception('Название и цена обязательны');
    }

    return ProductResponse(
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
  Future<TaskResponse> createTask(TaskRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    if (request.name.isEmpty || request.reward <= 0) {
      throw Exception('Название и награда обязательны');
    }

    return TaskResponse(
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
  Future<List<TaskResponse>> getUserTasks(String userId) async {
    await Future.delayed(const Duration(seconds: 1));

    if (userId.isEmpty) {
      throw Exception('ID пользователя не может быть пустым');
    }

    return [
      TaskResponse(
        id: 1,
        name: 'Тестовая задача 1',
        reward: 50.0,
        description: 'Описание тестовой задачи',
        startPoint: 'Точка A',
        endPoint: 'Точка B',
        customerId: int.parse(userId),
        state: 'In Progress',
      ),
      TaskResponse(
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
  Future<UserResponse> updateUserProfile(UserUpdateRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    if (request.name.isEmpty || request.email.isEmpty) {
      throw Exception('Имя и email обязательны');
    }

    return UserResponse(
      id: 0,
      name: request.name,
      email: request.email,
      birthdayDate: request.birthdayDate,
      login: request.login,
      isAdmin: false,
    );
  }

  @override
  Future<WalletResponse> updateWallet(WalletRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    if (request.customerId <= 0 || request.balance < 0) {
      throw Exception('Неверные параметры кошелька');
    }

    return WalletResponse(
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
}