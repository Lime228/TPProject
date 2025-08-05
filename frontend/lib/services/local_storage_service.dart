import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task/task_model.dart';

class LocalStorageService {
  static const String _tasksKey = 'offline_tasks';
  static const String _pendingChangesKey = 'pending_changes';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveTasks(List<TaskModel> tasks) async {
    final tasksJson = tasks.map((task) {
      final json = task.toJson();
      debugPrint('Сохраняю задачу: id=${task.id}, json=$json');
      return jsonEncode(json);
    }).toList();
    await _prefs.setStringList(_tasksKey, tasksJson);
  }

  List<TaskModel> getTasks() {
    final tasksJson = _prefs.getStringList(_tasksKey) ?? [];
    return tasksJson.map((json) {
      try {
        final decoded = jsonDecode(json);
        debugPrint('Загружаю задачу из хранилища: $decoded');
        return TaskModel.fromJson(decoded);
      } catch (e) {
        debugPrint('Ошибка при загрузке задачи: $e, json=$json');
        return null;
      }
    }).where((task) => task != null).cast<TaskModel>().toList();
  }

  Future<void> addPendingChange(String type, Map<String, dynamic> data) async {
    final changes = getPendingChanges();
    
    // Проверяем, нет ли уже такого изменения
    final existingIndex = changes.indexWhere((change) => 
      change['type'] == type && 
      change['data']['id'] == data['id']
    );

    final change = {
      'type': type,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };

    debugPrint('Добавляю изменение: $change');

    if (existingIndex != -1) {
      changes[existingIndex] = change;
    } else {
      changes.add(change);
    }

    await savePendingChanges(changes.map((change) => jsonEncode(change)).toList());
  }

  Future<void> savePendingChanges(List<String> changesJson) async {
    await _prefs.setStringList(_pendingChangesKey, changesJson);
  }

  List<Map<String, dynamic>> getPendingChanges() {
    final changesJson = _prefs.getStringList(_pendingChangesKey) ?? [];
    return changesJson.map((json) {
      try {
        final decoded = jsonDecode(json);
        debugPrint('Загружаю изменение: $decoded');
        return Map<String, dynamic>.from(decoded);
      } catch (e) {
        debugPrint('Ошибка при загрузке изменения: $e, json=$json');
        return null;
      }
    }).where((change) => change != null).cast<Map<String, dynamic>>().toList();
  }

  Future<void> clearPendingChanges() async {
    await _prefs.remove(_pendingChangesKey);
  }

  Future<void> addLocalTask(TaskModel task) async {
    final tasks = getTasks();
    tasks.add(task);
    await saveTasks(tasks);
    await addPendingChange('create', task.createRequest(task.state));
  }

  Future<void> updateLocalTask(TaskModel task) async {
    final tasks = getTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      await saveTasks(tasks);
      
      final updateData = task.updateRequest();
      debugPrint('Сохраняю обновление задачи: $updateData');
      await addPendingChange('update', updateData);
    }
  }

  Future<void> deleteLocalTask(int taskId) async {
    final tasks = getTasks();
    final task = tasks.firstWhere((t) => t.id == taskId, orElse: () => TaskModel(
      id: taskId,
      name: '',
      reward: 0,
      description: '',
      startPoint: '',
      endPoint: '',
      customerId: 0,
      state: 0,
    ));
    
    tasks.removeWhere((t) => t.id == taskId);
    await saveTasks(tasks);
    
    final deleteData = {'taskId': taskId};
    debugPrint('Сохраняю удаление задачи: $deleteData');
    await addPendingChange('delete', deleteData);
  }

  Future<void> clearAll() async {
    await _prefs.remove(_tasksKey);
    await _prefs.remove(_pendingChangesKey);
  }
} 