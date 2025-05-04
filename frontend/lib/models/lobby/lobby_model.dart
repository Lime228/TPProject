import '../base_request.dart';
import '../base_response.dart';

class LobbyModel implements BaseRequest<LobbyModel>, BaseResponse{
  @override
  final int id;
  final int taskId;
  final int shopId;
  final int customerId;

  LobbyModel({
    this.id = 0, // 0 означает новый объект (для создания)
    required this.taskId,
    required this.shopId,
    required this.customerId,
  });

  // Для запроса (без ID)
  Map<String, dynamic> toCreateJson() => {
    'Task_ID': taskId,
    'Shop_ID': shopId,
    'Customer_ID': customerId,
  };

  // Для ответа (с ID)
  Map<String, dynamic> toJson() => {
    if (id != 0) 'Lobby_ID': id,
    'Task_ID': taskId,
    'Shop_ID': shopId,
    'Customer_ID': customerId,
  };

  factory LobbyModel.fromJson(Map<String, dynamic> json) {
    return LobbyModel(
      id: json['Lobby_ID'] ?? 0,
      taskId: json['Task_ID'],
      shopId: json['Shop_ID'],
      customerId: json['Customer_ID'],
    );
  }

  // Для списка лобби по customerId
  static List<LobbyModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => LobbyModel.fromJson(json)).toList();
  }

  @override
  @override
  LobbyModel fromJson(Map<String, dynamic> json) {
    return LobbyModel.fromJson(json);
  }
}