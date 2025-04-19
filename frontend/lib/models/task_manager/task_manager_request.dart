class TaskManagerRequest {
  final int lobbyId;
  final int taskId;

  TaskManagerRequest({
    required this.lobbyId,
    required this.taskId,
  });

  Map<String, dynamic> toJson() => {
    'Lobby_ID': lobbyId,
    'Task_ID': taskId,
  };
}