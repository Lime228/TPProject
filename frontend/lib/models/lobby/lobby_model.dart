class LobbyModel {
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

  Map<String, dynamic> addRequest(int userID) => {
    'code': code,
    'customerid': userID,
  };


  Map<String, dynamic> deleteRequest() => {
    'lobbyid': id,
  };

  factory LobbyModel.fromResponse(Map<String, dynamic> json) {
    return LobbyModel(
      id: json['lobbyId'] ?? 0,
      shopId: json['shopId'],
      taskId: List<int>.from(json['taskId'] ?? []),
      customerId: List<int>.from(json['customerId'] ?? []),
      code: json['code'],
    );
  }

}