import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();
  bool _isOnline = true;
  Timer? _retryTimer;
  StreamSubscription? _connectivitySubscription;

  ConnectivityService() {
    debugPrint('Инициализация ConnectivityService');
    _initConnectivity();
  }

  Stream<bool> get onlineStream => _controller.stream;
  bool get isOnline => _isOnline;

  Future<void> _initConnectivity() async {
    try {
      await _setupConnectivityListener();
    } catch (e) {
      debugPrint('Ошибка инициализации ConnectivityService: $e');
      // В случае ошибки считаем, что мы онлайн и пробуем переинициализировать через 5 секунд
      _isOnline = true;
      _controller.add(true);
      _scheduleRetry();
    }
  }

  Future<void> _setupConnectivityListener() async {
    try {
      // Отписываемся от предыдущей подписки, если она была
      await _connectivitySubscription?.cancel();
      
      // Подписываемся на изменения состояния подключения
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
      
      // Проверяем текущее состояние
      final result = await _connectivity.checkConnectivity();
      _handleConnectivityChange(result);
      
      _retryTimer?.cancel();
      _retryTimer = null;
    } catch (e) {
      debugPrint('Ошибка настройки слушателя подключения: $e');
      _scheduleRetry();
    }
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;
    debugPrint('Статус подключения изменился: ${result.name}, онлайн: $_isOnline');
    if (wasOnline != _isOnline) {
      _controller.add(_isOnline);
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 5), _initConnectivity);
  }

  void dispose() {
    _retryTimer?.cancel();
    _connectivitySubscription?.cancel();
    _controller.close();
  }
} 