class WalletResponse {
  final int id;
  final int customerId;
  final int lobbyId;
  final double balance;

  WalletResponse({
    required this.id,
    required this.customerId,
    required this.lobbyId,
    required this.balance,
  });

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    return WalletResponse(
      id: json['Wallet_ID'],
      customerId: json['Customer_ID'],
      lobbyId: json['Lobby_ID'],
      balance: json['Balance'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'Wallet_ID': id,
    'Customer_ID': customerId,
    'Lobby_ID': lobbyId,
    'Balance': balance,
  };
}