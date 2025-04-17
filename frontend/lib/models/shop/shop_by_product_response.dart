import 'package:untitled/models/shop/shop_response.dart';

class ShopByProductResponse {
  final List<ShopResponse> shops;

  ShopByProductResponse({required this.shops});

  factory ShopByProductResponse.fromJson(List<dynamic> json) {
    return ShopByProductResponse(
      shops: json.map((item) => ShopResponse.fromJson(item)).toList(),
    );
  }
}