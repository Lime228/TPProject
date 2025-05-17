class WalletModel{
  @override
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



  //ну тут пока ничего не могу гарантировать, но точно не так будет
  WalletModel fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['Wallet_ID'] ?? 0,
      customerId: json['Customer_ID'],
      lobbyId: json['Lobby_ID'],
      balance: json['Balance'] is int
          ? (json['Balance'] as int).toDouble()
          : json['Balance'].toDouble(),
    );
  }

}
