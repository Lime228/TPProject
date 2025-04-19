import 'package:zadachok/models/task_manager/task_manager_response.dart';

class TaskManagerListResponse {
  final List<TaskManagerResponse> taskManagers;

  TaskManagerListResponse({required this.taskManagers});

  factory TaskManagerListResponse.fromJson(List<dynamic> json) {
    return TaskManagerListResponse(
      taskManagers: json.map((item) => TaskManagerResponse.fromJson(item)).toList(),
    );
  }
}