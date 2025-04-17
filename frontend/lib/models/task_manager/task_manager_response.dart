class TaskManagerResponse {
  final int id;
  final int lobbyId;
  final int taskId;

  TaskManagerResponse({
    required this.id,
    required this.lobbyId,
    required this.taskId,
  });

  factory TaskManagerResponse.fromJson(Map<String, dynamic> json) {
    return TaskManagerResponse(
      id: json['Task_Lobby_ID'],
      lobbyId: json['Lobby_ID'],
      taskId: json['Task_ID'],
    );
  }

  Map<String, dynamic> toJson() => {
    'Task_Lobby_ID': id,
    'Lobby_ID': lobbyId,
    'Task_ID': taskId,
  };
}