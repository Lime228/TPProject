import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zadachok/models/task/task_model.dart';
import 'package:zadachok/api/api_interface.dart';
import 'package:zadachok/providers/group_provider.dart';

import '../api/api_client.dart';
import '../models/lobby/lobby_model.dart';
import '../models/user/user_model.dart';
import '../models/wallet/wallet_model.dart';
import 'auth_provider.dart';

class TaskProvider with ChangeNotifier {
  final client = ApiClient();
  List<TaskModel> _tasks = [];
  List<TaskModel> _filteredTasks = [];
  AuthProvider? authProvider;
  bool _isLoadingTasks = false;
  bool _isLoadingTaskCreation = false;
  bool _isLoadingTaskDeletion = false;
  String? _error;
  UserModel? _user;
  int? _currentLobbyId;

  TaskProvider({required this.authProvider });

  List<TaskModel> get tasks => _tasks;
  bool get isLoadingTasks => _isLoadingTasks;
  bool get isLoadingTaskCreation => _isLoadingTaskCreation;
  bool get isLoadingTaskDeletion => _isLoadingTaskDeletion;
  String? get error => _error;
  String _searchQuery = '';
  String _sortOption = 'all';

  List<TaskModel> get filteredTasks => _filteredTasks.isNotEmpty && _searchQuery.isNotEmpty
      ? _filteredTasks
      : _tasks;

  void setUser(UserModel user) {
    if (_user != user) {
      _user = user;
      _safeNotifyListeners();
    }
  }

  void setLobbyId(int lobbyId) {
    if (_currentLobbyId != lobbyId) {
      _currentLobbyId = lobbyId;
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
    if (_currentLobbyId == null || _user == null) return;

    _setLoadingTasks(true);
    _error = null;

    try {
      final apiClient = _getAuthenticatedClient();
      final lobby = await apiClient.getLobby(_currentLobbyId!);
      final allTasks = await apiClient.getUserTasks(lobby, _user!);

      _tasks = _user!.role.isAdmin
          ? allTasks
          : allTasks.where((task) => task.customerId == _user!.id).toList();

      _safeNotifyListeners();
    } catch (e) {
      _error = 'Ошибка обновления задач: ${e.toString()}';
      debugPrint(_error!);
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
      final apiClient = _getAuthenticatedClient();
      final newTask = await apiClient.createTask(task, lobbyId);
      _tasks.add(newTask);
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
      debugPrint('Попытка удаления задачи: $taskId');

      final taskToDelete = TaskModel(
        id: taskId,
        name: '',
        reward: 0,
        description: '',
        startPoint: '',
        endPoint: '',
        customerId: 0,
        state: 0,
      );
      final apiClient = _getAuthenticatedClient();
      await apiClient.deleteTask(taskToDelete);

      _tasks.removeWhere((task) => task.id == taskId);
      _safeNotifyListeners();

      debugPrint('Задача $taskId удалена');
      return true;
    } catch (e) {
      debugPrint('Ошибка удаления: $e');
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
          task.state != 2; // Исключаем только подтвержденные задачи
    }).toList();
  }

  Future<void> completeTask(int taskId, UserModel user) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);

      // Обновляем endPoint на текущее время
      final updatedTask = task.copyWith(
        state: 1, // выполнено, но не подтверждено
        endPoint: DateTime.now().toIso8601String(),
      );

      final apiClient = _getAuthenticatedClient();
      final serverResponse = await apiClient.completeTask(updatedTask, user);

      _tasks.removeWhere((t) => t.id == taskId);
      _tasks.add(serverResponse);

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
          // Если задача уже выполнена (state=1), просто подтверждаем
          confirmedTask = await apiClient.completeTask(
            task.copyWith(state: 2), // подтверждено
            _user!,
          );
        } else {
          // Если задача новая (state=0), сразу подтверждаем и обновляем время
          confirmedTask = await apiClient.completeTask(
            task.copyWith(
              state: 2, // подтверждено
              endPoint: DateTime.now().toIso8601String(),
              customerId: _user!.id, // назначаем на админа
            ),
            _user!,
          );
        }

        _tasks[index] = confirmedTask;
        _safeNotifyListeners();
      }
    } catch (e) {
      _error = 'Ошибка подтверждения задачи: ${e.toString()}';
      debugPrint(_error!);
      rethrow;
    }
  }



  Future<void> updateTask(TaskModel task) async {
    try {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        if (task.reward < 0) {
          throw Exception('Награда не может быть отрицательной');
        }
        final apiClient = _getAuthenticatedClient();
        final updatedTask = await apiClient.updateTask(task);
        _tasks[index] = updatedTask;
        _safeNotifyListeners();
      }
    } catch (e) {
      _error = 'Ошибка обновления задачи: ${e.toString()}';
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

  void _applyFilters() {
    List<TaskModel> result = _tasks.where((task) {
      final nameMatches = task.name.toLowerCase().contains(_searchQuery);
      final descMatches = task.description.toLowerCase().contains(_searchQuery);
      return nameMatches || descMatches;
    }).toList();

    switch (_sortOption) {
      case 'date':
        result.sort((a, b) {
          final aDate = a.deadline ?? DateTime.now();
          final bDate = b.deadline ?? DateTime.now();
          return aDate.compareTo(bDate);
        });
        break;
      case 'completed':
        result = result.where((t) => t.state == 2).toList(); // Только подтвержденные
        break;
      case 'pending':
        result = result.where((t) => t.state == 0).toList(); // Только в процессе
        break;
      case 'unconfirmed':
        result = result.where((t) => t.state == 1).toList(); // Выполненные, но не подтвержденные
        break;
      default:
        result.sort((a, b) {
          // Сначала невыполненные (0), затем ожидающие подтверждения (1), затем подтвержденные (2)
          return a.state.compareTo(b.state);
        });
    }

    _filteredTasks = result;
  }

  void resetFilters() {
    _searchQuery = '';
    _sortOption = 'all';
    _applyFilters();
    _safeNotifyListeners();
  }
}