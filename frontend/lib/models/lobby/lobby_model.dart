import '../base_request.dart';
import '../base_response.dart';

class LobbyModel implements BaseRequest<LobbyModel>, BaseResponse{
  @override
  int id;
  int shopId;
  List<int> taskId;
  List<int> customerId;

  LobbyModel({
    this.id = 0, // 0 означает новый объект (для создания)
    required this.taskId,
    required this.shopId,
    required this.customerId,
  });

  // Для запроса (без ID)
  Map<String, dynamic> createRequest() => {
    'creatorID': customerId,
  };

  Map<String, dynamic> removeRequest() => {
    'lobbyid': id,
    'customerid':customerId
  };

  Map<String, dynamic> addRequest() => {
    'lobbyid': id,
    'customerid':customerId
  };

  Map<String, dynamic> getRequest() => { // переделать это явно не так
    'lobbyid': id,
    'customerid':customerId
  };

  Map<String, dynamic> deleteRequest() => {
    'lobbyid': id,
  };


  // Для ответа (с ID)
  Map<String, dynamic> toJson() => {
    if (id != 0) 'lobbyId': id,
    'taskId': taskId,
    'shopId': shopId,
    'customerId': customerId,
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