import 'package:untitled/models/wallet/wallet_response.dart';

class WalletByCustomerResponse {
  final List<WalletResponse> wallets;

  WalletByCustomerResponse({required this.wallets});

  factory WalletByCustomerResponse.fromJson(List<dynamic> json) {
    return WalletByCustomerResponse(
      wallets: json.map((item) => WalletResponse.fromJson(item)).toList(),
    );
  }
}