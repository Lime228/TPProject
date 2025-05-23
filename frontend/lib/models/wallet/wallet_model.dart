class WalletModel {
  int id;
  int customerId;
  int lobbyId;
  int balance;

  WalletModel({
    this.id = 0,
    required this.customerId,
    required this.lobbyId,
    required this.balance,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] ?? 0,
      customerId: json['customerId'],
      lobbyId: json['lobbyId'],
      balance: json['balance'] is int ? json['balance'] : json['balance'].toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'lobbyId': lobbyId,
      'balance': balance,
    };
  }
}
