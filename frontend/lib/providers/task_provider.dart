import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zadachok/models/task/task_model.dart';
import 'package:zadachok/api/api_interface.dart';
import 'package:zadachok/providers/group_provider.dart';

class TaskProvider with ChangeNotifier {
  final ApiInterface apiClient;
  List<TaskModel> _tasks = [];
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

  // Новый метод для получения задач по дате
  List<TaskModel> getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      final taskDate = DateTime.parse(task.endPoint).toLocal();
      return taskDate.year == date.year &&
          taskDate.month == date.month &&
          taskDate.day == date.day;
    }).toList();
  }

  // Новый метод для получения общего количества звёзд за день
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

      debugPrint('Создание задачи с reward: ${task.reward}'); // Добавлено логирование
      final newTask = await apiClient.createTask(task);
      debugPrint('Получена задача с reward: ${newTask.reward}'); // Добавлено логирование

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
        // Проверка награды при обновлении
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
}