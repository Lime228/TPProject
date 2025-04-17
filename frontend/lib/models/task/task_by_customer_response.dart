import 'package:untitled/models/task/task_response.dart';

class TaskByCustomerResponse {
  final List<TaskResponse> tasks;

  TaskByCustomerResponse({required this.tasks});

  factory TaskByCustomerResponse.fromJson(List<dynamic> json) {
    return TaskByCustomerResponse(
      tasks: json.map((item) => TaskResponse.fromJson(item)).toList(),
    );
  }
}