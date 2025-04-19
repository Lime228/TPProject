import '../../base_request.dart';
import '../../base_response.dart';

class ProductModel implements BaseRequest<ProductModel>, BaseResponse{
  final int id;
  final String name;
  final String description;
  final String photo;
  final String state;
  final double price;
  final int customerId;

  ProductModel({
    this.id = 0, // 0 для новых продуктов
    required this.name,
    required this.description,
    required this.photo,
    required this.state,
    required this.price,
    required this.customerId,
  });

  // Для создания продукта (без ID)
  Map<String, dynamic> toCreateJson() => {
    'Product_name': name,
    'Description': description,
    'Photo': photo,
    'Product_state': state,
    'Price': price,
    'Customer_ID': customerId,
  };

  // Для полного JSON (с ID)
  Map<String, dynamic> toJson() => {
    if (id != 0) 'Product_ID': id,
    'Product_name': name,
    'Description': description,
    'Photo': photo,
    'Product_state': state,
    'Price': price,
    'Customer_ID': customerId,
  };

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['Product_ID'] ?? 0,
      name: json['Product_name'],
      description: json['Description'],
      photo: json['Photo'],
      state: json['Product_state'],
      price: json['Price'] is int
          ? (json['Price'] as int).toDouble()
          : json['Price'].toDouble(),
      customerId: json['Customer_ID'],
    );
  }

  // Для списка продуктов
  static List<ProductModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => ProductModel.fromJson(json)).toList();
  }

  // Валидация продукта
  void validate() {
    if (name.isEmpty) throw ArgumentError('Product name cannot be empty');
    if (price <= 0) throw ArgumentError('Price must be positive');
    if (customerId <= 0) throw ArgumentError('Customer ID must be positive');
  }

  @override
  ProductModel fromJson(Map<String, dynamic> json) {
    // TODO: implement fromJson
    throw UnimplementedError();
  }
}