import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  const baseUrl = 'http://localhost:8081';
  const registerUrl = '$baseUrl/api/auth/register';
  const loginUrl = '$baseUrl/api/auth/login';
  const createLobbyUrl = '$baseUrl/api/lobby/create';
  const addUserLobbyUrl = '$baseUrl/api/lobby/add';
  const removeUserLobbyUrl = '$baseUrl/api/lobby/remove';
  const taskCreateUrl = '$baseUrl/api/task/create';
  const healthCheckUrl = '$baseUrl';

  // Генерируем уникальные тестовые данные
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final testUsername = 'testuser_$timestamp';
  final testEmail = 'test_$timestamp@example.com';
  const testPassword = 'TestPassword123!';
  const testCreatorId = 1;
  const testCustomerId = 2;

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
    
    test('3. Создание нового лобби', () async {
      print('Попытка создания лобби...');
    
      final requestData = {
        'creatorID': testCreatorId,
      };
    
      print('Отправляемые данные: ${jsonEncode(requestData)}');
    
      final response = await http.post(
        Uri.parse(createLobbyUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );
    
      print('Статус код: ${response.statusCode}');
      print('Ответ сервера: ${response.body}');
    
      expect(response.statusCode, 200,
          reason: 'Ожидался статус 200 (Успешное создание лобби)');
    
      if (response.statusCode == 200) {
        final lobbyData = jsonDecode(response.body);
        
        expect(lobbyData['lobbyId'], isNotNull,
            reason: 'ID лобби не должен быть null');
    
        // Проверка первого customerId
        final customerIds = lobbyData['customerId'] as List;
        expect(customerIds.isNotEmpty, true,
            reason: 'Список customerId не должен быть пустым');
        
        final firstCustomerId = customerIds[0];
        print('Первый customerId: $firstCustomerId');
        expect(firstCustomerId, equals(1),
            reason: 'Первый customerId должен быть равен 1');
    
        print('Создано новое лобби:');
        print('ID: ${lobbyData['lobbyId']}');
        print('ID создателя: $firstCustomerId');
        print('Лобби успешно создано\n');
      } else {
        print('Ошибка при создании лобби\n');
      }
    });
    test('4. Добавление пользователя в лобби', () async {
      print('Попытка добавления пользователя в лобби...');

      final requestData = {
        'lobbyid': 1,
        'customerid': testCustomerId,
      };

      print('Отправляемые данные: ${jsonEncode(requestData)}');

      final response = await http.post(
        Uri.parse(addUserLobbyUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      print('Статус код: ${response.statusCode}');
      print('Ответ сервера: ${response.body}');

      expect(response.statusCode, 200,
          reason: 'Ожидался статус 200 (Успешное добавление пользователя)');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        expect(responseData['lobbyId'], equals(1),
            reason: 'ID лобби должен соответствовать переданному');
        
        expect(responseData['customerId'], contains(testCustomerId),
            reason: 'Список customerId должен содержать добавленного пользователя');

        print('Пользователь успешно добавлен в лобби:');
        print('ID лобби: ${responseData['lobbyId']}');
        print('Добавленный customerId: $testCustomerId');
        print('Текущий список customerId: ${responseData['customerId']}\n');
      } else {
        print('Ошибка при добавлении пользователя в лобби\n');
      }
    });

    test('5. Удаление пользователя из лобби', () async {
      print('Попытка удаления пользователя из лобби...');

      final requestData = {
        'lobbyid': 1,
        'customerid': testCustomerId,
      };

      print('Отправляемые данные: ${jsonEncode(requestData)}');

      final response = await http.post(
        Uri.parse(removeUserLobbyUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      print('Статус код: ${response.statusCode}');
      print('Ответ сервера: ${response.body}');

      expect(response.statusCode, 200,
          reason: 'Ожидался статус 200 (Успешное удаление пользователя)');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        expect(responseData['lobbyId'], equals(1),
            reason: 'ID лобби должен соответствовать переданному');
        
        expect(responseData['customerId'], isNot(contains(testCustomerId)),
            reason: 'Список customerId не должен содержать удаленного пользователя');

        print('Пользователь успешно удален из лобби:');
        print('ID лобби: ${responseData['lobbyId']}');
        print('Удаленный customerId: $testCustomerId');
        print('Текущий список customerId: ${responseData['customerId']}\n');
      } else {
        print('Ошибка при удалении пользователя из лобби\n');
      }
    });
    test('6. Создание задания', () async {
      print('Создание задачи...');

      final requestData = {
        'name': 'TEST TASK',
        'reward': 100,
        'description': 'Ogo, chto eto? Eto je opisanie!',
        'startdate': '2025-05-2',
        'enddate': '2025-05-20',
        'lobbyid': 1,
        'creatorid': 1,
      };

      print('Отправляемые данные: ${jsonEncode(requestData)}');

      final response = await http.post(
        Uri.parse(taskCreateUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      print('Статус код: ${response.statusCode}');
      print('Ответ сервера: ${response.body}');

      expect(response.statusCode, 200,
          reason: 'Ожидался статус 200 ()');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        expect(responseData['name'], equals('TEST TASK'),
            reason: 'Название задания не соответствует');
        

        print('Задание успешно создано:');
        print('Название задания: ${responseData['name']}');
        print('Описание: ${responseData['description']}');
        print('Награда: ${responseData['reward']}\n');
      } else {
        print('Ошибка при создании задания\n');
      }
    });
  });

  tearDownAll(() {
    print('Тестирование завершено');
  });
}
