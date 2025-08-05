import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zadachok/models/task/task_model.dart';
import 'package:zadachok/api/api_interface.dart';
import 'package:zadachok/providers/group_provider.dart';
import 'package:zadachok/services/connectivity_service.dart';
import 'package:zadachok/services/local_storage_service.dart';

import '../api/api_client.dart';
import '../models/lobby/lobby_model.dart';
import '../models/user/user_model.dart';
import '../models/wallet/wallet_model.dart';
import 'auth_provider.dart';

class TaskProvider with ChangeNotifier {
  final client = ApiClient();
  final LocalStorageService _localStorage;
  final ConnectivityService _connectivity;
  
  List<TaskModel> _tasks = [];
  List<TaskModel> _filteredTasks = [];
  AuthProvider? authProvider;
  bool _isLoadingTasks = false;
  bool _isLoadingTaskCreation = false;
  bool _isLoadingTaskDeletion = false;
  String? _error;
  UserModel? _user;
  int? _currentLobbyId;
  bool _isOffline = false;

  TaskProvider({
    required this.authProvider,
    required LocalStorageService localStorage,
    required ConnectivityService connectivity,
  }) : _localStorage = localStorage,
       _connectivity = connectivity {
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    _connectivity.onlineStream.listen((isOnline) {
      _isOffline = !isOnline;
      if (isOnline) {
        _syncPendingChanges();
      }
      _safeNotifyListeners();
    });
  }

  Future<void> _syncPendingChanges() async {
    if (_currentLobbyId == null) return;

    final pendingChanges = _localStorage.getPendingChanges();
    if (pendingChanges.isEmpty) return;

    List<Map<String, dynamic>> failedChanges = [];

    for (final change in pendingChanges) {
      try {
        final apiClient = _getAuthenticatedClient();
        switch (change['type']) {
          case 'create':
            final task = TaskModel.fromJson(change['data']);
            await apiClient.createTask(task, _currentLobbyId!);
            break;
          case 'update':
            final task = TaskModel.fromJson(change['data']);
            if (task.id <= 0) {
              debugPrint('Пропускаю обновление задачи с невалидным ID: ${task.id}');
              continue;
            }
            await apiClient.updateTask(task);
            break;
          case 'delete':
            final taskId = change['data']['taskId'];
            if (taskId <= 0) {
              debugPrint('Пропускаю удаление задачи с невалидным ID: $taskId');
              continue;
            }
            await apiClient.deleteTask(TaskModel(
              id: taskId,
              name: '',
              reward: 0,
              description: '',
              startPoint: '',
              endPoint: '',
              customerId: 0,
              state: 0,
            ));
            break;
        }
      } catch (e) {
        debugPrint('Ошибка синхронизации изменения ${change['type']}: $e');
        // Добавляем в failedChanges только если это не ошибка с невалидным ID
        if (!e.toString().contains('ID задачи не может быть пустым')) {
          failedChanges.add(change);
        }
      }
    }

    // Сохраняем только неудачные изменения
    if (failedChanges.isEmpty) {
      await _localStorage.clearPendingChanges();
    } else {
      final changesJson = failedChanges.map((change) => jsonEncode(change)).toList();
      await _localStorage.savePendingChanges(changesJson);
    }

    await refreshTasks();
  }

  List<TaskModel> get tasks => _tasks;
  bool get isLoadingTasks => _isLoadingTasks;
  bool get isLoadingTaskCreation => _isLoadingTaskCreation;
  bool get isLoadingTaskDeletion => _isLoadingTaskDeletion;
  String? get error => _error;
  String _searchQuery = '';
  String _sortOption = 'default'; // ✅ default сортировка

  List<TaskModel> get filteredTasks => _filteredTasks;

  void setUser(UserModel user) {
    if (_user != user) {
      _user = user;
      if (_currentLobbyId != null) {
        refreshTasks();
      }
      _safeNotifyListeners();
    }
  }

  void setLobbyId(int lobbyId) {
    if (_currentLobbyId != lobbyId) {
      _currentLobbyId = lobbyId;
      if (_user != null) {
        refreshTasks();
      }
      _safeNotifyListeners();
    }
  }

  void _safeNotifyListeners() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) return;
      notifyListeners();
    });
  }

  ApiClient _getAuthenticatedClient() {
    if (authProvider?.token == null) throw Exception('Токен отсутствует');
    client.setAuthToken(authProvider!.token!);
    return client;
  }

  void setAuthProvider(AuthProvider provider) {
    if (authProvider != provider) {
      authProvider = provider;
      _safeNotifyListeners();
    }
  }
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> refreshTasks() async {
    if (_currentLobbyId == null || _user == null) {
      debugPrint('Не могу обновить задачи: lobbyId = $_currentLobbyId, user = ${_user?.id}');
      return;
    }

    _setLoadingTasks(true);
    _error = null;

    try {
      if (_connectivity.isOnline) {
        debugPrint('Загружаю задачи онлайн для lobbyId = $_currentLobbyId');
        final apiClient = _getAuthenticatedClient();
        final lobby = await apiClient.getLobby(_currentLobbyId!);
        debugPrint('Получил лобби: ${lobby.id}');
        final allTasks = await apiClient.getUserTasks(lobby, _user!);
        debugPrint('Получил ${allTasks.length} задач с сервера');

        _tasks = _user!.role.isAdmin
            ? allTasks
            : allTasks.where((task) => task.customerId == _user!.id).toList();
        debugPrint('Отфильтровал ${_tasks.length} задач для пользователя');

        // Сохраняем актуальные задачи в локальное хранилище
        await _localStorage.saveTasks(_tasks);
      } else {
        debugPrint('Загружаю задачи из локального хранилища (оффлайн режим)');
        _tasks = _localStorage.getTasks();
        debugPrint('Загружено ${_tasks.length} задач из локального хранилища');
      }

      _applyFilters();
      _safeNotifyListeners();
    } catch (e) {
      _error = 'Ошибка обновления задач: ${e.toString()}';
      debugPrint('ОШИБКА: $_error');
      debugPrint('Stack trace: ${StackTrace.current}');
      
      // В случае ошибки загружаем локальные данные
      _tasks = _localStorage.getTasks();
      _applyFilters();
      _safeNotifyListeners();
    } finally {
      _setLoadingTasks(false);
    }
  }

  List<TaskModel> getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      final taskDate = task.deadline ?? DateTime.now();
      return taskDate.year == date.year &&
          taskDate.month == date.month &&
          taskDate.day == date.day;
    }).toList();
  }

  double getTotalStarsForDate(DateTime date) {
    return getTasksForDate(date).fold(0, (sum, task) => sum + task.reward);
  }

  Future<void> loadTasks(int lobbyId) async {
    if (_user == null) {
      throw Exception('Пользователь не авторизован');
    }

    _setLoadingTasks(true);
    _error = null;

    try {
      final lobby = LobbyModel(
        id: lobbyId,
        taskId: [],
        shopId: 0,
        customerId: [_user!.id],
      );
      final apiClient = _getAuthenticatedClient();
      _tasks = await apiClient.getUserTasks(lobby, _user!);
      _applyFilters(); // ✅ применить фильтрацию
      _safeNotifyListeners();
    } catch (e) {
      _error = 'Ошибка загрузки задач: ${e.toString()}';
      debugPrint(_error!);
    } finally {
      _setLoadingTasks(false);
    }
  }

  Future<bool> addTask({
    required TaskModel task,
    required int lobbyId,
  }) async {
    _setLoadingTaskCreation(true);
    _error = null;

    try {
      if (task.name.isEmpty) {
        throw Exception('Название задачи не может быть пустым');
      }

      if (_connectivity.isOnline) {
        final apiClient = _getAuthenticatedClient();
        final newTask = await apiClient.createTask(task, lobbyId);
        _tasks.add(newTask);
        await _localStorage.saveTasks(_tasks);
      } else {
        // Генерируем временный отрицательный ID для локальной задачи
        task = task.copyWith(id: -DateTime.now().millisecondsSinceEpoch);
        await _localStorage.addLocalTask(task);
        _tasks.add(task);
      }

      _applyFilters();
      _safeNotifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Ошибка создания задачи: $e');
      return false;
    } finally {
      _setLoadingTaskCreation(false);
    }
  }

  Future<bool> deleteTask(int taskId) async {
    _setLoadingTaskDeletion(true);
    _error = null;

    try {
      if (_connectivity.isOnline) {
        final apiClient = _getAuthenticatedClient();
        await apiClient.deleteTask(TaskModel(
          id: taskId,
          name: '',
          reward: 0,
          description: '',
          startPoint: '',
          endPoint: '',
          customerId: 0,
          state: 0,
        ));
        
        _tasks.removeWhere((task) => task.id == taskId);
        await _localStorage.saveTasks(_tasks);
      } else {
        await _localStorage.deleteLocalTask(taskId);
        _tasks.removeWhere((task) => task.id == taskId);
      }

      _applyFilters();
      _safeNotifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка удаления задачи: $e');
      _error = e.toString();
      return false;
    } finally {
      _setLoadingTaskDeletion(false);
    }
  }

  Future<List<TaskModel>> getTasksForDateRange(DateTime start, DateTime end) async {
    return _tasks.where((task) {
      final taskStart = task.createdAt;
      final taskEnd = task.deadline ?? DateTime.now();
      return (taskStart.isBefore(end) || DateUtils.isSameDay(taskStart, end)) &&
          (taskEnd.isAfter(start) || DateUtils.isSameDay(taskEnd, start)) &&
          task.state != 2;
    }).toList();
  }

  Future<void> completeTask(int taskId, UserModel user) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);

      final updatedTask = task.copyWith(
        state: 1,
        endPoint: DateTime.now().toIso8601String(),
      );

      final apiClient = _getAuthenticatedClient();
      final serverResponse = await apiClient.completeTask(updatedTask, user);

      _tasks.removeWhere((t) => t.id == taskId);
      _tasks.add(serverResponse);
      _applyFilters(); // ✅ обновление после изменений
      _safeNotifyListeners();
    } catch (e) {
      _error = 'Ошибка завершения задачи: ${e.toString()}';
      debugPrint(_error!);
      rethrow;
    }
  }

  Future<void> confirmTask(int taskId) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        final apiClient = _getAuthenticatedClient();
        TaskModel confirmedTask;

        if (task.state == 1) {
          confirmedTask = await apiClient.completeTask(
            task.copyWith(state: 2),
            _user!,
          );
        } else {
          confirmedTask = await apiClient.completeTask(
            task.copyWith(
              state: 2,
              endPoint: DateTime.now().toIso8601String(),
              customerId: _user!.id,
            ),
            _user!,
          );
        }

        _tasks[index] = confirmedTask;
        _applyFilters(); // ✅ пересортировка
        _safeNotifyListeners();
      }
    } catch (e) {
      _error = 'Ошибка подтверждения задачи: ${e.toString()}';
      debugPrint(_error!);
      rethrow;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    try {
      if (_connectivity.isOnline) {
        final apiClient = _getAuthenticatedClient();
        await apiClient.updateTask(task);
        
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = task;
        }
        await _localStorage.saveTasks(_tasks);
      } else {
        await _localStorage.updateLocalTask(task);
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = task;
        }
      }

      _applyFilters();
      _safeNotifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Ошибка обновления задачи: $e');
      return false;
    }
  }

  void _setLoadingTasks(bool loading) {
    if (_isLoadingTasks != loading) {
      _isLoadingTasks = loading;
      _safeNotifyListeners();
    }
  }

  void _setLoadingTaskCreation(bool loading) {
    if (_isLoadingTaskCreation != loading) {
      _isLoadingTaskCreation = loading;
      _safeNotifyListeners();
    }
  }

  void _setLoadingTaskDeletion(bool loading) {
    if (_isLoadingTaskDeletion !=loading) {
      _isLoadingTaskDeletion = loading;
      _safeNotifyListeners();
    }
  }

  void searchTasks(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    _safeNotifyListeners();
  }

  void sortTasks({String? option}) {
    _sortOption = option ?? 'default';
    _applyFilters();
    _safeNotifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _sortOption = 'default'; // ✅ не "all", а "default"
    _applyFilters();
    _safeNotifyListeners();
  }

  void _applyFilters() {
    List<TaskModel> result = _tasks;

    if (_searchQuery.isNotEmpty) {
      result = result.where((task) {
        final nameMatches = task.name.toLowerCase().contains(_searchQuery);
        final descMatches = task.description.toLowerCase().contains(_searchQuery);
        return nameMatches || descMatches;
      }).toList();
    }

    switch (_sortOption) {
      case 'date':
        result.sort((a, b) {
          final aDate = a.deadline ?? DateTime.now();
          final bDate = b.deadline ?? DateTime.now();
          return aDate.compareTo(bDate);
        });
        break;
      case 'completed':
        result = result.where((t) => t.state == 2).toList();
        break;
      case 'pending':
        result = result.where((t) => t.state == 0).toList();
        break;
      case 'unconfirmed':
        result = result.where((t) => t.state == 1).toList();
        break;
      default:
        result.sort((a, b) => a.state.compareTo(b.state));
    }

    _filteredTasks = result;
  }
}
