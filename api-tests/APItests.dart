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

    test('1. Проверка здоровья API', () async {
      print('Тестирование подключения к API...');
      try {
        final response = await http.get(Uri.parse(healthCheckUrl));
        
        printOnFailure('Статус код: ${response.statusCode}');
        printOnFailure('Тело ответа: ${response.body}');
        
        expect(response.statusCode, 200);
        expect(response.headers['content-type'], 'application/json');
        
        final healthData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(healthData['status'], 'UP');
        
        print('API здоров и доступен\n');
      } catch (e) {
        fail('Ошибка подключения к API: $e');
      }
    });

    test('2. Регистрация нового пользователя', () async {
      print('Попытка регистрации пользователя...');
      try {
        final requestData = {
          'login': testUsername,
          'password': testPassword,
          'email': testEmail,
        };

        printOnFailure('Отправляемые данные: ${jsonEncode(requestData)}');

        final response = await http.post(
          Uri.parse(registerUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestData),
        );

        printOnFailure('Статус код: ${response.statusCode}');
        printOnFailure('Ответ сервера: ${response.body}');

        expect(response.statusCode, 200);
        expect(response.headers['content-type'], 'application/json');

        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['token'], isNotNull);
        
        authToken = responseData['token'];
        print('Пользователь успешно зарегистрирован. Токен получен.\n');
      } catch (e) {
        fail('Ошибка при регистрации пользователя: $e');
      }
    });

    test('3. Вход пользователя в систему', () async {
      print('Попытка входа пользователя...');
      try {
        final requestData = {
          'login': testUsername,
          'password': testPassword,
        };

        printOnFailure('Отправляемые данные: ${jsonEncode(requestData)}');

        final response = await http.post(
          Uri.parse(loginUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestData),
        );

        printOnFailure('Статус код: ${response.statusCode}');
        printOnFailure('Ответ сервера: ${response.body}');

        expect(response.statusCode, 200);
        expect(response.headers['content-type'], 'application/json');

        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['token'], isNotNull);
        
        print('Пользователь успешно вошел в систему\n');
      } catch (e) {
        fail('Ошибка при входе пользователя: $e');
      }
    });

    test('4. Создание нового лобби', () async {
      print('Попытка создания лобби...');
      try {
        final requestData = {
          'creatorID': testCreatorId,
        };

        printOnFailure('Отправляемые данные: ${jsonEncode(requestData)}');

        final response = await http.post(
          Uri.parse(createLobbyUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
          body: jsonEncode(requestData),
        );

        printOnFailure('Статус код: ${response.statusCode}');
        printOnFailure('Ответ сервера: ${response.body}');

        expect(response.statusCode, 200);
        expect(response.headers['content-type'], 'application/json');

        final lobbyData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(lobbyData['creatorId'], testCreatorId);
        expect(lobbyData['id'], isNotNull);
        
        print('Создано новое лобби:');
        print('ID: ${lobbyData['id']}');
        print('ID создателя: ${lobbyData['creatorId']}\n');
      } catch (e) {
        fail('Ошибка при создании лобби: $e');
      }
    });
  });

  tearDownAll(() {
    print('Тестирование завершено');
  });
}
