import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../api/api_client.dart';
import '../providers/auth_provider.dart';

class NotificationService {

  String? _token;
  ApiClient? _apiClient;
  ApiClient? client = new ApiClient();
  static final NotificationService _instance = NotificationService._internal();
  bool _notificationsEnabled = true;
  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();


  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
  }

  Future<bool> _checkAndRequestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
      return await Permission.notification.isGranted;
    }
    return true;
  }

  ApiClient? _getAuthenticatedClient() {
    if (_token == null) throw Exception('Токен отсутствует');
    client?.setAuthToken(_token!);
    return client;
  }

  void setAuthToken(String? token) {
    _token = token;
    if (token != null) {
      _apiClient = ApiClient()..setAuthToken(token);
    }
  }

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);

    // Создаем канал уведомлений (обязательно для Android 8.0+)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // ID канала
      'Task Notifications', // Название канала
      importance: Importance.max,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> showTaskNotification({
    required int taskId,
  }) async {
    if (!_notificationsEnabled) {
      debugPrint('Уведомления отключены в настройках');
      return;
    }

    if (!await _checkAndRequestPermissions()) {
      return;
    }

    try {
      // Получаем сгенерированный текст
      final notificationText = await generateAndWaitForNotification(taskId);
      if (notificationText == null) return;

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'Task Notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        0,
        'Напоминание о задаче',
        notificationText,
        platformDetails,
      );
    } catch (e) {
      debugPrint('Ошибка показа уведомления: $e');
    }
  }

  Future<String?> generateAndWaitForNotification(int taskId) async {
    if (_token == null || _apiClient == null) {
      throw Exception('Токен отсутствует');
    }

    try {
      // Шаг 1: Генерация уведомления
      final generateResponse = await _apiClient!.generateNotification(taskId);
      final notificationId = generateResponse['notificationId'] as String;

      // Шаг 2: Проверка статуса с интервалом
      while (true) {
        await Future.delayed(const Duration(minutes: 10));

        final statusResponse = await _apiClient!.getNotificationStatus(notificationId);

        if (statusResponse['status'] == 'COMPLETED') {
          final generatedText = statusResponse['generatedText'] as String;
          return generatedText.replaceFirst('output:', '').trim();
        } else if (statusResponse['status'] == 'FAILED') {
          throw Exception('Генерация уведомления не удалась');
        }
      }
    } catch (e) {
      debugPrint('Ошибка генерации уведомления: $e');
      return null;
    }
  }
}
