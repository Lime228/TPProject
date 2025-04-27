import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  const baseUrl = 'http://localhost:8081';
  const registerUrl = '$baseUrl/api/auth/register';
  const loginUrl = '$baseUrl/api/auth/login';
  const createLobbyUrl = '$baseUrl/api/lobby/create';
  const healthCheckUrl = '$baseUrl';

  // Генерируем уникальные тестовые данные
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final testUsername = 'testuser_$timestamp';
  final testEmail = 'test_$timestamp@example.com';
  const testPassword = 'TestPassword123!';
  const testCreatorId = 1;

  // Переменные для хранения состояния между тестами
  late String authToken;

  group('API Integration Tests', () {
    setUpAll(() async {
      print('Начало тестирования API');
      print('-----------------------------');
      print('Тестовые данные:');
      print('Имя пользователя: $testUsername');
      print('Email: $testEmail');
      print('Пароль: $testPassword');
      print('-----------------------------\n');
    });

    test('1. Проверка подключения к API', () async {
      print('Тестирование подключения к базовому URL...');
      final response = await http.get(Uri.parse(baseUrl));

      print('Статус код: ${response.statusCode}');
      print('Тело ответа: ${response.body.isEmpty ? 'Пусто' : response.body}');

      expect(response.statusCode, anyOf([200, 401, 403, 404]),
          reason: 'Ожидался любой из статусов 200, 401, 403 или 404');

      print(' Проверка подключения завершена\n');
    });

    test('2. Регистрация нового пользователя', () async {
      print('Попытка регистрации пользователя...');
      final requestData = {
        'login': testUsername,
        'password': testPassword,
        'email': testEmail,
      };

      print('Отправляемые данные: ${jsonEncode(requestData)}');

      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      print('Статус код: ${response.statusCode}');
      print('Ответ сервера: ${response.body}');

      expect(response.statusCode, 200,
          reason: 'Ожидался статус 200 (Успешная регистрация)');

      if (response.statusCode == 200) {
        print('Пользователь успешно зарегистрирован\n');
      } else {
        print('Ошибка при регистрации пользователя\n');
      }
    });

    //ВКЛЮЧИТЬ ПОСЛЕ ПОЧИНКИ ЛОББИ
    
    // test('3. Создание нового лобби', () async {
    //   print('Попытка создания лобби...');

    //   final requestData = {
    //     'creatorID': testCreatorId,
    //   };

    //   print('Отправляемые данные: ${jsonEncode(requestData)}');

    //   final response = await http.post(
    //     Uri.parse(createLobbyUrl),
    //     headers: {'Content-Type': 'application/json'},
    //     body: jsonEncode(requestData),
    //   );

    //   print('Статус код: ${response.statusCode}');
    //   print('Ответ сервера: ${response.body}');

    //   expect(response.statusCode, 200,
    //       reason: 'Ожидался статус 200 (Успешное создание лобби)');

    //   if (response.statusCode == 200) {
    //     final lobbyData = jsonDecode(response.body);
    //     expect(lobbyData['creatorId'], testCreatorId,
    //         reason: 'ID создателя должно соответствовать отправленному');
    //     expect(lobbyData['id'], isNotNull,
    //         reason: 'ID лобби не должен быть null');

    //     print('Создано новое лобби:');
    //     print('ID: ${lobbyData['id']}');
    //     print('ID создателя: ${lobbyData['creatorId']}');
    //     print('Лобби успешно создано\n');
    //   } else {
    //     print('Ошибка при создании лобби\n');
    //   }
    // });
  });

  tearDownAll(() {
    print('Тестирование завершено');
  });
}
