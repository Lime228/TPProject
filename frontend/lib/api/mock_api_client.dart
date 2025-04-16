import 'dart:async';
import '../models/register_request.dart';
import '../models/user_response.dart';
import 'api_interface.dart';

class MockApiClient implements ApiInterface {

  const MockApiClient();

  @override
  Future<UserResponse> register(RegisterRequest request) async {
    // Имитация задержки сети
    await Future.delayed(const Duration(seconds: 1));

    // Валидация тестовых данных
    if (request.username.isEmpty || request.password.isEmpty) {
      throw Exception('Все поля обязательны для заполнения');
    }

    if (request.password.length < 6) {
      throw Exception('Пароль должен содержать минимум 6 символов');
    }

    // Успешный ответ
    return UserResponse(
      id: DateTime.now().millisecondsSinceEpoch,
      username: request.username,
      email: request.email,
    );
  }

  @override
  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (username != 'test' || password != 'test123') {
      throw Exception('Неверные учетные данные');
    }
    return true;

    // В реальном приложении здесь бы возвращался токен
  }
}