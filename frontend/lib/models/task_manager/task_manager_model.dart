import '../base_request.dart';
import '../base_response.dart';

class TaskManagerModel implements BaseRequest<TaskManagerModel>, BaseResponse {
  @override
  final int id;
  final int lobbyId;
  final int taskId;

  TaskManagerModel({
    this.id = 0,
    required this.lobbyId,
    required this.taskId,
  });

  // Реализация BaseRequest
  @override
  Map<String, dynamic> toCreateJson() => {
    'Lobby_ID': lobbyId,
    'Task_ID': taskId,
  };

  // Реализация BaseResponse
  @override
  Map<String, dynamic> toJson() => {
    'Task_Lobby_ID': id,
    'Lobby_ID': lobbyId,
    'Task_ID': taskId,
  };

  TaskManagerModel fromJson(Map<String, dynamic> json) {
    return TaskManagerModel(
      id: json['Task_Lobby_ID'] ?? 0,
      lobbyId: json['Lobby_ID'],
      taskId: json['Task_ID'],
    );
  }

  List<TaskManagerModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => fromJson(json)).toList();
  }

  // Валидация
  void validate() {
    if (lobbyId <= 0) throw ArgumentError('Lobby ID must be positive');
    if (taskId <= 0) throw ArgumentError('Task ID must be positive');
  }
}