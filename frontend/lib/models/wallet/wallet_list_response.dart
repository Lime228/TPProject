import 'package:untitled/models/wallet/wallet_response.dart';

class WalletListResponse {
  final List<WalletResponse> wallets;

  WalletListResponse({required this.wallets});

  factory WalletListResponse.fromJson(List<dynamic> json) {
    return WalletListResponse(
      wallets: json.map((item) => WalletResponse.fromJson(item)).toList(),
    );
  }
}