import 'dart:convert';

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
    'photo': base64Encode(product.photoBytes),
    'state': product.isAvailable,
    'price': product.price,
    'shopid': id,
    'link': product.link,
  };

  // Запрос на покупку продукта
  Map<String, dynamic> buyProductRequest(int customerId, int productId) => {
    'customerId': customerId,
    'productId': productId,
  };

  // Запрос на обновление продукта
  Map<String, dynamic> updateProductRequest(ProductModel product) => {
    'productid': product.id,
    'name': product.name,
    'description': product.description,
    'photo': base64Encode(product.photoBytes),
    'state': product.isAvailable,
    'price': product.price,
    if (product.link != null) 'link': product.link,
  };

  // Запрос на удаление продукта
  Map<String, dynamic> deleteProductRequest(int shopId, int productId) => {
    'shopId': shopId,
    'productId': productId,
  };

  // Сериализация в JSON
  Map<String, dynamic> toJson() => {
    if (id != 0) 'shopId': id,
    'productId': productIds,
  };



  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['shopId'] ?? 0,
      productIds: List<int>.from(json['productId'] ?? []),
    );
  }

  factory ShopModel.fromResponse(Map<String, dynamic> json) {
    return ShopModel(
      id: json['shopId'] ?? 0,
      productIds: List<int>.from(json['productId'] ?? []),
    );
  }

  // Валидация магазина
  void validate() {
    if (productIds.any((id) => id <= 0)) {
      throw ArgumentError('Все ID продуктов должны быть положительными');
    }
  }
}
