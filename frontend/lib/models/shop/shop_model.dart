import 'package:zadachok/models/shop/product/product_model.dart';

class ShopModel {
  final int id;
  final List<int> productIds;

  ShopModel({
    this.id = 0,
    required this.productIds,
  });

  // Запрос на создание продукта
  Map<String, dynamic> createProductRequest(ProductModel product) => {
    'name': product.name,
    'description': product.description,
    'photo': product.photoBase64,
    'state': product.isAvailable,
    'price': product.price,
    'shopId': id,
    if (product.link != null) 'link': product.link,
  };

  // Запрос на покупку продукта
  Map<String, dynamic> buyProductRequest(int customerId, int productId) => {
    'customerId': customerId,
    'productId': productId,
    'shopId': id,
  };

  // Запрос на обновление продукта
  Map<String, dynamic> updateProductRequest(ProductModel product) => {
    'productId': product.id,
    'name': product.name,
    'description': product.description,
    'photo': product.photoBase64,
    'state': product.isAvailable,
    'price': product.price,
    'shopId': id,
    if (product.link != null) 'link': product.link,
  };

  // Запрос на удаление продукта
  Map<String, dynamic> deleteProductRequest(int productId) => {
    'shopId': id,
    'productId': productId,
  };

  // Сериализация в JSON
  Map<String, dynamic> toJson() => {
    if (id != 0) 'shopId': id,
    'productIds': productIds,
  };



  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['shopId'] ?? 0,
      productIds: List<int>.from(json['productIds'] ?? []),
    );
  }

  factory ShopModel.fromResponse(Map<String, dynamic> json) {
    return ShopModel(
      id: json['shopId'] ?? 0,
      productIds: List<int>.from(json['productIds'] ?? []),
    );
  }

  // Валидация магазина
  void validate() {
    if (productIds.any((id) => id <= 0)) {
      throw ArgumentError('Все ID продуктов должны быть положительными');
    }
  }
}
