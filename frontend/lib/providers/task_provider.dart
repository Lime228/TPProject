import 'package:flutter/material.dart';
import 'package:zadachok/models/task/task_model.dart';
import 'package:zadachok/api/api_interface.dart';

class TaskProvider with ChangeNotifier {
  final ApiInterface apiClient;
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;

  TaskProvider({required this.apiClient});

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTasks(String userId) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await apiClient.getUserTasks(userId);
      _tasks = TaskModel.listFromJson(response);
    } catch (e) {
      _error = 'Ошибка загрузки задач: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addTask(TaskModel task) async {
    _setLoading(true);
    _error = null;
    try {
      task.validate();
      final newTask = await apiClient.createTask(task);
      _tasks.add(newTask);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Ошибка создания задачи: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteTask(int taskId) async {
    _setLoading(true);
    _error = null;
    try {
      await apiClient.deleteTask(taskId.toString());
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Ошибка удаления задачи: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}