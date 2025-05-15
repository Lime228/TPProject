import '../base_request.dart';
import '../base_response.dart';

class WalletModel implements BaseRequest<WalletModel>, BaseResponse {
  @override
  int id;
  int customerId;
  int lobbyId;
  int balance;

  WalletModel({
    this.id = 0, // 0 для новых кошельков
    required this.customerId,
    required this.lobbyId,
    required this.balance,
  });

  // Реализация BaseRequest - для создания/обновления
  @override
  Map<String, dynamic> toCreateJson() => {
    'Customer_ID': customerId,
    'Lobby_ID': lobbyId,
    'Balance': balance,
  };

  // Реализация BaseResponse - для полных данных
  @override
  Map<String, dynamic> toJson() => {
    'Wallet_ID': id,
    'Customer_ID': customerId,
    'Lobby_ID': lobbyId,
    'Balance': balance,
  };

  // Парсинг из JSON
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

  // Для списка кошельков (заменяет WalletListResponse)
  List<WalletModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => fromJson(json)).toList();
  }

  // Для кошельков по customerId (заменяет WalletByCustomerResponse)
  List<WalletModel> listByCustomerFromJson(List<dynamic> jsonList) {
    return listFromJson(jsonList);
  }

  // Валидация
  void validate() {
    if (customerId <= 0) throw ArgumentError('Customer ID must be positive');
    if (lobbyId < 0) throw ArgumentError('Lobby ID cannot be negative');
    if (balance < 0) throw ArgumentError('Balance cannot be negative');
  }
}
