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
  const productCreateUrl = '$baseUrl/api/shop/product/create';
  const productDeleteUrl = '$baseUrl/api/shop/product/delete';
  const productUpdateUrl = '$baseUrl/api/shop/product/update';
  const productBuyUrl = '$baseUrl/api/shop/product/buy';

  // Генерируем уникальные тестовые данные
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final testUsername = 'testuser_$timestamp';
  final testEmail = 'test_$timestamp@example.com';
  const testPassword = 'TestPassword123!';
  const testCreatorId = 1;
  const testCustomerId = 2;
  String? lobbyCode;
  String? authToken;

  group('API Integration Tests', () {
    setUpAll(() async {
      print('Начало тестирования API');
      print('-----------------------------');
      print('Тестовые данные:');
      print('Имя пользователя: $testUsername');
      print('Email: $testEmail');
      print('Пароль: $testPassword');
      print('ID админа: $testCreatorId');
      print('ID второго пользователя: $testCustomerId');
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

    test('2.1 Регистрация нового пользователя', () async {
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

    test('2.2 Регистрация нового пользователя', () async {
      print('Попытка регистрации пользователя...');
      final requestData = {
        'login': 'kuzya',
        'password': testPassword,
        'email': 'kuzya@example,com',
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

    test('2.3 Логин пользователя и получение токена', () async {
      print('Попытка входа пользователя...');
      final requestData = {
        'login': testUsername,
        'password': testPassword,
      };

      print('Отправляемые данные: ${jsonEncode(requestData)}');

      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      print('Статус код: ${response.statusCode}');
      print('Ответ сервера: ${response.body}');

      expect(response.statusCode, 200,
          reason: 'Ожидался статус 200 (Успешный вход)');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        authToken = responseData['token'];
        expect(authToken, isNotNull, reason: 'Токен не должен быть null');
        print('Токен успешно получен\n');
      } else {
        print('Ошибка при входе пользователя\n');
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
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
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

        lobbyCode = lobbyData['code'];
        expect(lobbyCode, isNotNull, reason: 'Код лобби не должен быть null');
        print('Полученный код лобби: $lobbyCode');

        final customerIds = lobbyData['customerId'] as List;
        expect(customerIds.isNotEmpty, true,
            reason: 'Список customerId не должен быть пустым');

        final firstCustomerId = customerIds[0];
        print('Первый customerId: $firstCustomerId');
        expect(firstCustomerId, equals(1),
            reason: 'Первый customerId должен быть равен 1');

        print('Лобби успешно создано\n');
      } else {
        print('Ошибка при создании лобби\n');
      }
    });

    test('4. Добавление пользователя в лобби', () async {
      print('Попытка добавления пользователя в лобби...');

      final requestData = {
        'code': lobbyCode,
        'customerid': testCustomerId,
      };

      print('Отправляемые данные: ${jsonEncode(requestData)}');

      final response = await http.patch(
        Uri.parse(addUserLobbyUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestData),
      );

      print('Статус код: ${response.statusCode}');
      print('Ответ сервера: ${response.body}');

      expect(response.statusCode, 200,
          reason: 'Ожидался статус 200 (Успешное добавление пользователя)');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        expect(responseData['code'], equals(lobbyCode),
            reason: 'ID лобби должен соответствовать переданному');

        expect(responseData['customerId'], contains(testCustomerId),
            reason: 'Список customerId должен содержать добавленного пользователя');

        print('Пользователь успешно добавлен в лобби');
      } else {
        print('Ошибка при добавлении пользователя в лобби\n');
      }
    });

    test('5. Создание задания', () async {
      print('Создание задачи...');

      final requestData = {
        'name': 'TEST TASK',
        'reward': 100,
        'description': 'Ogo, chto eto? Eto je opisanie!',
        'startdate': '2025-05-02',
        'enddate': '2025-05-20',
        'lobbyid': 1,
        'customerid': 1,
      };

      print('Отправляемые данные: ${jsonEncode(requestData)}');

      final response = await http.post(
        Uri.parse(taskCreateUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
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


        print('Задание успешно создано');

      } else {
        print('Ошибка при создании задания\n');
      }
    });

    test('6. Создание продукта', () async {
      print('Создание продукта...');

      final requestData = {
        'name': 'TEST PRODUCT',
        'description': 'Это тестовый продукт для проверки',
        'photo': base64Encode(utf8.encode('test_image_data')),
        'state': false,
        'price': 0,
        'shopid': 1,
      };

      print('Отправляемые данные: ${jsonEncode(requestData)}');

      final response = await http.post(
        Uri.parse(productCreateUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestData),
      );

      print('Статус код: ${response.statusCode}');
      print('Ответ сервера: ${response.body}');

      expect(response.statusCode, 200,
          reason: 'Ожидался статус 200 (Успешное создание продукта)');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        expect(responseData['name'], equals('TEST PRODUCT'),
            reason: 'Название продукта не соответствует');
        expect(responseData['price'], equals(0),
            reason: 'Цена продукта не соответствует');

        print('Продукт успешно создан');

      } else {
        print('Ошибка при создании продукта\n');
      }
    });

    test('7. Покупка продукта', () async {
      print('Обновление продукта...');

      final requestData = {
        'customerId': 2,
        'productId': 1,
      };

      print('Отправляемые данные: ${jsonEncode(requestData)}');

      final response = await http.post(
        Uri.parse(productBuyUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestData),
      );

      print('Статус код: ${response.statusCode}');
      print('Ответ сервера: ${response.body}');

      expect(response.statusCode, 200,
          reason: 'Ожидался статус 200 (Успешная покупка продукты)');

      if (response.statusCode == 200) {
        expect(response.body, contains('Покупка прошла успешно'),
            reason: 'Ожидалось сообщение об успешной покупке');
        print('Продукт успешно куплен');

      } else {
        print('Ошибка при покупке продукта\n');
      }
    });

    test('8. Обновление продукта', () async {
      print('Обновление продукта...');

      final requestData = {
        'productid': 1,
        'name': 'UPDATED TEST PRODUCT',
        'description': 'Обновлённое описание тестового продукта',
        'photo': base64Encode(utf8.encode('updated_test_image_data')),
        'state': false,
        'price': 1999,
      };

      print('Отправляемые данные: ${jsonEncode(requestData)}');

      final response = await http.patch(
        Uri.parse(productUpdateUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestData),
      );

      print('Статус код: ${response.statusCode}');
      print('Ответ сервера: ${response.body}');

      expect(response.statusCode, 200,
          reason: 'Ожидался статус 200 (Успешное обновление продукта)');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        expect(responseData['name'], equals('UPDATED TEST PRODUCT'),
            reason: 'Название продукта не обновилось');
        expect(responseData['price'], equals(1999),
            reason: 'Цена продукта не обновилась');
        expect(responseData['state'], equals(false),
            reason: 'Состояние продукта не обновилось');

        print('Продукт успешно обновлён');

      } else {
        print('Ошибка при обновлении продукта\n');
      }
    });

    test('9. Удаление пользователя из лобби', () async {
      print('Попытка удаления пользователя из лобби...');

      final requestData = {
        'lobbyid': 1,
        'customerid': testCustomerId,
      };

      print('Отправляемые данные: ${jsonEncode(requestData)}');

      final response = await http.patch(
        Uri.parse(removeUserLobbyUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
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

        print('Пользователь успешно удален из лобби');
      } else {
        print('Ошибка при удалении пользователя из лобби\n');
      }
    });

    test('10. Удаление продукта', () async {
      print('Удаление продукта...');

      final requestData = {
        'shopid': 1,
        'productid': 1,
      };

      print('Отправляемые данные: ${jsonEncode(requestData)}');

      final response = await http.delete(
        Uri.parse(productDeleteUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestData),
      );

      print('Статус код: ${response.statusCode}');
      print('Ответ сервера: ${response.body}');

      if (response.statusCode == 200) {
        expect(response.body, contains('Продукт удалён успешно'),
            reason: 'Ответ сервера не содержит подтверждения удаления');

        print('Успех: ${response.body}');
        print('Продукт shopid=1, productid=1 удалён\n');
      } else {
        print('Ошибка при удалении продукта\n');
      }
    });

    test('11. Удаление лобби', () async {
      print('Удаление лобби...');

      final requestData = {
        'lobbyid': 1,
      };

      print('Отправляемые данные: ${jsonEncode(requestData)}');

      final response = await http.delete(
        Uri.parse('$baseUrl/api/lobby/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestData),
      );

      print('Статус код: ${response.statusCode}');
      print('Ответ сервера: ${response.body}');

      if (response.statusCode == 200) {
        expect(response.body, contains('Лобби успешно удалено'),
            reason: 'Ответ сервера не содержит подтверждения удаления');

        print('Успех: ${response.body}');
        print('Лобби с lobbyid=1 удалено\n');
      } else {
        print('Ошибка при удалении лобби\n');
        fail('Удаление лобби завершилось с ошибкой. Статус: ${response.statusCode}');
      }
    });
  });

  tearDownAll(() {
    print('Тестирование завершено');
  });
}