import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class ProductModel {
  final int id;
  final String name;
  final String description;
  final Uint8List photoBytes; // Изменяем на Uint8List
  final bool isAvailable;
  final int price;
  final String? link;
  final int? customerId; // Может быть null, если продукт не куплен

  ProductModel({
    this.id = 0,
    required this.name,
    required this.description,
    required this.photoBytes, // Обязательное поле
    required this.isAvailable,
    required this.price,
    this.link,
    this.customerId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    debugPrint('=== ProductModel.fromJson ===');
    debugPrint('Raw JSON: $json');
    debugPrint('Link in JSON: ${json['link']}');
    
    final model = ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      photoBytes: base64Decode(json['photo'] ?? ''),
      isAvailable: json['state'] ?? false,
      price: json['price'] ?? 0,
      link: json['link'],
      customerId: json['customerId'],
    );
    
    debugPrint('Created model link: ${model.link}');
    return model;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'photo': base64Encode(photoBytes),
    'state': isAvailable,
    'price': price,
    if (link != null) 'link': link,
    if (customerId != null) 'customerId': customerId,
  };

  ProductModel copyWith({
    int? id,
    String? name,
    String? description,
    Uint8List? photoBytes,
    bool? isAvailable,
    int? price,
    int? customerId,
    String? link,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      photoBytes: photoBytes ?? this.photoBytes,
      isAvailable: isAvailable ?? this.isAvailable,
      price: price ?? this.price,
      customerId: customerId ?? this.customerId,
      link: link ?? this.link,
    );
  }
}
