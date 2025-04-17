class LobbyRequest {
  final int taskId;
  final int shopId;
  final int customerId;

  LobbyRequest({
    required this.taskId,
    required this.shopId,
    required this.customerId,
  });

  Map<String, dynamic> toJson() => {
    'Task_ID': taskId,
    'Shop_ID': shopId,
    'Customer_ID': customerId,
  };
}