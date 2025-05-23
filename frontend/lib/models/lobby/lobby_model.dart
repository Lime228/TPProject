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

  // Для создания лобби
  Map<String, dynamic> createRequest(int creatorID) => {
    'creatorID': creatorID,
  };

  // Для удаления пользователя
  Map<String, dynamic> removeRequest(int userID) => {
    'lobbyid': id,
    'customerid': userID,
  };

  // Для добавления пользователя (по коду)
  Map<String, dynamic> addRequest(int userID) => {
    'code': code,
    'customerid': userID,
  };

  // Для удаления лобби
  Map<String, dynamic> deleteRequest() => {
    'lobbyid': id,
  };

  // Для сохранения в SharedPreferences
  Map<String, dynamic> toJson() => {
    'id': id,
    'shopId': shopId,
    'taskId': taskId,
    'customerId': customerId,
    'code': code,
  };

  factory LobbyModel.fromJson(Map<String, dynamic> json) {
    return LobbyModel(
      id: json['id'] ?? 0,
      shopId: json['shopId'],
      taskId: List<int>.from(json['taskId'] ?? []),
      customerId: List<int>.from(json['customerId'] ?? []),
      code: json['code'],
    );
  }

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