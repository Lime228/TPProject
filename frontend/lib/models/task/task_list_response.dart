import 'package:zadachok/models/task/task_response.dart';

class TaskListResponse {
  final List<TaskResponse> tasks;

  TaskListResponse({required this.tasks});

  factory TaskListResponse.fromJson(List<dynamic> json) {
    return TaskListResponse(
      tasks: json.map((item) => TaskResponse.fromJson(item)).toList(),
    );
  }
}