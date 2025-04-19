class WalletRequest {
  final int customerId;
  final int lobbyId;
  final double balance;

  WalletRequest({
    required this.customerId,
    required this.lobbyId,
    required this.balance,
  });

  Map<String, dynamic> toJson() => {
    'Customer_ID': customerId,
    'Lobby_ID': lobbyId,
    'Balance': balance,
  };
}