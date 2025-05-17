import 'package:flutter/cupertino.dart';

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


  @override
  Map<String, dynamic> createRequest() => {
    'creatorID': customerId[0],
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



  @override
  Map<String, dynamic> toJson() => {
    if (id != 0) 'id': id,
    'shopId': shopId,
    'taskId': taskId,
    'customerId': customerId,
  };

  @override
  factory LobbyModel.fromResponse(Map<String, dynamic> json) {
    try {
      final id = json['id'] ?? json['lobbyId'] ?? json['data']['id'] ?? 0;
      if (id == 0) throw Exception('ID лобби не найден в ответе');

      return LobbyModel(
        id: id,
        shopId: json['shopId'] ?? 0,
        taskId: List<int>.from(json['taskId'] ?? []),
        customerId: List<int>.from(json['customerId'] ?? []),
      );
    } catch (e) {
      debugPrint('Ошибка парсинга LobbyModel: $e\nResponse: $json');
      rethrow;
    }
  }


  static List<LobbyModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => LobbyModel.fromResponse(json)).toList();
  }

  @override
  @override
  LobbyModel fromJson(Map<String, dynamic> json) {
    return LobbyModel.fromResponse(json);
  }
}