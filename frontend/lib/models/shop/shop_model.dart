import 'package:zadachok/models/shop/product/product_model.dart';

import '../base_request.dart';
import '../base_response.dart';

class ShopModel implements BaseRequest<ShopModel>, BaseResponse{
  final int id;
  final List<int> productId;

  ShopModel({
    this.id = 0, // 0 означает новый объект (для создания)
    required this.productId,
  });


  Map<String, dynamic> productCreateRequest(ProductModel p) => {
    'name': p.name,
    'description': p.description,
    'photo': p.photo,
    'state': p.state,
    'price': p.price,
    'shopid': id,
  };

  Map<String, dynamic> productBuyRequest(int cId, int pId) => {
    'customerId': cId,
    'productId': pId
  };

  Map<String, dynamic> productUpdateRequest(ProductModel p) => {
    'productid': p.id,
    'name': p.name,
    'description': p.description,
    'photo': p.photo,
    'state': p.state,
    'price': p.price,
  };

  //че то с гетами подумать

  Map<String, dynamic> productDeleteRequest(ProductModel p) => {
    'shopid': id,
    'productid':p.id
  };

  // Для полного JSON (с ID)
  Map<String, dynamic> toJson() => {
    if (id != 0) 'Shop_ID': id,
    'Product_ID': productId,
  };

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['Shop_ID'] ?? 0,
      productId: json['Product_ID'],
    );
  }

  // Для списка магазинов по productId
  static List<ShopModel> listByProductFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => ShopModel.fromJson(json)).toList();
  }

  // Валидация
  void validate() {
    if (productId.any((id) => id <= 0)) {
      throw ArgumentError('All product IDs must be positive');
    }
  }

  @override
  ShopModel fromJson(Map<String, dynamic> json) {
    // TODO: implement fromJson
    throw UnimplementedError();
  }
}