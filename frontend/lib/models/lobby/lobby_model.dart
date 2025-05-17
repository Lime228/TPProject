import 'package:flutter/cupertino.dart';

import '../base_request.dart';
import '../base_response.dart';

class LobbyModel implements BaseRequest<LobbyModel>, BaseResponse {
  @override
  int id;
  int shopId;
  List<int> taskId;
  List<int> customerId;
  String? code;

  LobbyModel({
    this.id = 0,
    required this.taskId,
    required this.shopId,
    required this.customerId,
    this.code,
  });

  @override
  Map<String, dynamic> createRequest(int creatorID) => {

    'creatorID': creatorID,
  };

  Map<String, dynamic> removeRequest() => {
    'lobbyid': id,
    'customerid': customerId,
  };

  Map<String, dynamic> addRequest() => {
    'code': code,
    'customerid': customerId,
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
    if (code != null) 'code': code,
  }; //udalit

  @override
  factory LobbyModel.fromResponse(Map<String, dynamic> json) {
    return LobbyModel(
      id: json['lobbyId'] ?? 0,
      shopId: json['shopId'],
      taskId: List<int>.from(json['taskId'] ?? []),
      customerId: List<int>.from(json['customerId'] ?? []),
      code: json['code'],
    );
  }

  static List<LobbyModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => LobbyModel.fromResponse(json)).toList();
  }

  @override
  LobbyModel fromJson(Map<String, dynamic> json) {
    return LobbyModel.fromResponse(json);
  }
}