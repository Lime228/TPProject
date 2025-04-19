class LobbyResponse {
  final int id;
  final int taskId;
  final int shopId;
  final int customerId;

  LobbyResponse({
    required this.id,
    required this.taskId,
    required this.shopId,
    required this.customerId,
  });

  factory LobbyResponse.fromJson(Map<String, dynamic> json) {
    return LobbyResponse(
      id: json['Lobby_ID'],
      taskId: json['Task_ID'],
      shopId: json['Shop_ID'],
      customerId: json['Customer_ID'],
    );
  }

  Map<String, dynamic> toJson() => {
    'Lobby_ID': id,
    'Task_ID': taskId,
    'Shop_ID': shopId,
    'Customer_ID': customerId,
  };
}