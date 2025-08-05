import 'dart:convert';
import 'package:flutter/material.dart';

class TaskModel {
  final int id;
  final String name;
  final int reward;
  final String description;
  final String startPoint;
  final String endPoint;
  final int state;
  final int customerId;

  final bool isCompleted;
  final bool isOverdue;

  TaskModel({
    this.id = 0,
    required this.name,
    required this.reward,
    required this.description,
    required this.startPoint,
    required this.endPoint,
    required this.customerId,
    required this.state,
    this.isCompleted = false,
    this.isOverdue = false,
  });

  DateTime? get deadline {
    try {
      return DateTime.parse(endPoint);
    } catch (e) {
      debugPrint('Invalid deadline format: $endPoint');
      return null;
    }
  }

  DateTime get createdAt {
    try {
      return startPoint.isNotEmpty ? DateTime.parse(startPoint) : DateTime.now();
    } catch (e) {
      debugPrint('Invalid startPoint format: $startPoint');
      return DateTime.now();
    }
  }

  TaskModel copyWith({
    int? id,
    String? name,
    int? reward,
    String? description,
    String? startPoint,
    String? endPoint,
    int? customerId,
    int? state,
    bool? isCompleted,
    bool? isOverdue,
  }) {
    return TaskModel(
      id: id ?? this.id,
      name: name ?? this.name,
      reward: reward ?? this.reward,
      description: description ?? this.description,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      state: state ?? this.state,
      customerId: customerId ?? this.customerId,
      isCompleted: isCompleted ?? this.isCompleted,
      isOverdue: isOverdue ?? this.isOverdue,
    );
  }

  Map<String, dynamic> createRequest(int lobbyId) => {
    'name': name,
    'reward': reward,
    'description': description,
    'startdate': startPoint,
    'enddate': endPoint,
    'lobbyid': lobbyId,
    'customerid': customerId,
  };

  Map<String, dynamic> updateRequest() => {
    'taskId': id,
    'name': name,
    'description': description,
    'reward': reward,
    'startdate': startPoint,
    'enddate': endPoint,
    'state': state,
    'customerid': customerId,
  };

  Map<String, dynamic> deleteRequest() => {
    'taskId': id
  };

  factory TaskModel.fromResponse(Map<String, dynamic> json) {
    debugPrint('TaskModel.fromResponse: $json');
    final taskId = json['id'] ?? json['taskId'] ?? 0;
    return TaskModel(
      id: taskId,
      name: json['name'] ?? '',
      reward: json['reward']?.toInt() ?? 0,
      description: json['description'] ?? '',
      startPoint: json['startDate'] ?? json['startdate'] ?? DateTime.now().toIso8601String(),
      endPoint: json['endDate'] ?? json['enddate'] ?? DateTime.now().toIso8601String(),
      customerId: json['customerId'] ?? json['customerid'] ?? 0,
      state: json['isActive'] ?? json['state'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      isOverdue: json['isOverdue'] ?? false,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    debugPrint('TaskModel.fromJson: $json');
    final taskId = json['id'] ?? json['taskId'] ?? 0;
    return TaskModel(
      id: taskId,
      name: json['name'] ?? '',
      reward: json['reward']?.toInt() ?? 0,
      description: json['description'] ?? '',
      startPoint: json['startDate'] ?? json['startdate'] ?? DateTime.now().toIso8601String(),
      endPoint: json['endDate'] ?? json['enddate'] ?? DateTime.now().toIso8601String(),
      customerId: json['customerId'] ?? json['customerid'] ?? 0,
      state: json['isActive'] ?? json['state'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      isOverdue: json['isOverdue'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'taskId': id,
    'name': name,
    'reward': reward,
    'description': description,
    'startDate': startPoint,
    'endDate': endPoint,
    'customerId': customerId,
    'isActive': state,
    'state': state,
    'isCompleted': isCompleted,
    'isOverdue': isOverdue,
  };

  @override
  String toString() {
    return 'TaskModel(id: $id, name: $name, state: $state)';
  }
}
