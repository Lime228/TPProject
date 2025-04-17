import 'dart:async';
import '../models/user/register_request.dart';
import '../models/user/user_response.dart';
import 'api_interface.dart';

class MockApiClient implements ApiInterface {

  const MockApiClient();

  @override
  Future<UserResponse> register(RegisterRequest request) async {
    // Имитация задержки сети
    await Future.delayed(const Duration(seconds: 1));

    // Валидация тестовых данных
    if (request.login.isEmpty || request.password.isEmpty) {
      throw Exception('Все поля обязательны для заполнения');
    }

    if (request.password.length < 6) {
      throw Exception('Пароль должен содержать минимум 6 символов');
    }

    // Успешный ответ
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
  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (username != 'test' || password != 'test123') {
      throw Exception('Неверные учетные данные');
    }
    return true;

    // В реальном приложении здесь бы возвращался токен
  }
}