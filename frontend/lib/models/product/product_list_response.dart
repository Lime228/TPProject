import 'package:untitled/models/product/product_response.dart';

class ProductListResponse {
  final List<ProductResponse> products;

  ProductListResponse({required this.products});

  factory ProductListResponse.fromJson(List<dynamic> json) {
    return ProductListResponse(
      products: json.map((item) => ProductResponse.fromJson(item)).toList(),
    );
  }
}