import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zadachok/models/task/task_model.dart';
import 'package:zadachok/api/api_interface.dart';
import 'package:zadachok/providers/group_provider.dart';

class TaskProvider with ChangeNotifier {
  final ApiInterface apiClient;
  List<TaskModel> _tasks = [];
  List<TaskModel> _filteredTasks = [];
  bool _isLoadingTasks = false;
  bool _isLoadingTaskCreation = false;
  bool _isLoadingTaskDeletion = false;
  String? _error;

  TaskProvider({required this.apiClient});

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


  List<TaskModel> getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      final taskDate = DateTime.parse(task.endPoint).toLocal();
      return taskDate.year == date.year &&
          taskDate.month == date.month &&
          taskDate.day == date.day;
    }).toList();
  }


  double getTotalStarsForDate(DateTime date) {
    return getTasksForDate(date).fold(0, (sum, task) => sum + task.reward);
  }

  Future<void> loadTasks(String userId) async {
    _setLoadingTasks(true);
    _error = null;
    try {
      final response = await apiClient.getUserTasks(userId);
      _tasks = TaskModel.listFromJson(response);
    } catch (e) {
      _error = 'Ошибка загрузки задач: ${e.toString()}';
    } finally {
      _setLoadingTasks(false);
    }
  }

  Future<bool> addTask(TaskModel task, BuildContext context) async {
    _setLoadingTaskCreation(true);
    _error = null;

    try {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);

      if (!groupProvider.isInGroup) {
        throw Exception('Вы должны быть в группе для создания задач');
      }

      if (!groupProvider.isOwner) {
        throw Exception('Только администратор может создавать задачи');
      }

      debugPrint('Создание задачи с reward: ${task.reward}');
      final newTask = await apiClient.createTask(task);
      debugPrint('Получена задача с reward: ${newTask.reward}');

      _tasks.add(newTask);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка при создании задачи: $e');
      _error = e.toString();
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
      await apiClient.deleteTask(taskId.toString());

      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();

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
      final taskStart = DateTime.parse(task.startPoint);
      final taskEnd = DateTime.parse(task.endPoint);
      return (taskStart.isBefore(end) || DateUtils.isSameDay(taskStart, end)) &&
          (taskEnd.isAfter(start) || DateUtils.isSameDay(taskEnd, start)) &&
          task.state != 'Completed';
    }).toList();
  }

  Future<void> completeTask(int taskId) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      final updatedTask = await apiClient.completeTask(taskId.toString());
      _tasks.removeWhere((t) => t.id == taskId);
      _tasks.add(updatedTask);
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка завершения задачи: ${e.toString()}';
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {

        if (task.reward < 0) {
          throw Exception('Награда не может быть отрицательной');
        }

        _tasks[index] = task;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Ошибка обновления задачи: ${e.toString()}';
    }
  }

  void _setLoadingTasks(bool loading) {
    _isLoadingTasks = loading;
    notifyListeners();
  }

  void _setLoadingTaskCreation(bool loading) {
    _isLoadingTaskCreation = loading;
    notifyListeners();
  }

  void _setLoadingTaskDeletion(bool loading) {
    _isLoadingTaskDeletion = loading;
    notifyListeners();
  }

  void searchTasks(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }


  void sortTasks({String? option}) {
    _sortOption = option ?? 'default';
    _applyFilters();
    notifyListeners();
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
          final aDate = DateTime.parse(a.endPoint);
          final bDate = DateTime.parse(b.endPoint);
          return aDate.compareTo(bDate);
        });
        break;
      case 'completed':
        result = result.where((t) => t.state == 'Completed').toList();
        break;
      case 'pending':
        result = result.where((t) => t.state != 'Completed').toList();
        break;
      default:

        result.sort((a, b) {
          if (a.state == 'Completed' && b.state != 'Completed') return 1;
          if (a.state != 'Completed' && b.state == 'Completed') return -1;
          return 0;
        });
    }

    _filteredTasks = result;
  }


  void resetFilters() {
    _searchQuery = '';
    _sortOption = 'all';
    _applyFilters();
    notifyListeners();
  }
}