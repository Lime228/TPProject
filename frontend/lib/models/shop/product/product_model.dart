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
  final String? link;

  ProductModel({
    this.id = 0, // 0 для новых продуктов
    required this.name,
    required this.description,
    required this.photo,
    required this.state,
    required this.price,
    required this.customerId,
    this.link,
  });

  ProductModel copyWith({
    int? id,
    String? name,
    String? description,
    String? photo,
    String? state,
    double? price,
    int? customerId,
    String? link,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      photo: photo ?? this.photo,
      state: state ?? this.state,
      price: price ?? this.price,
      customerId: customerId ?? this.customerId,
      link: link ?? this.link,
    );
  }

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
    if (link != null) 'Link': link,
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
  static List<ProductModel> listFromJson(List<dynamic> json) {
    return json.map((item) => ProductModel.fromJson(item)).toList();
  }

  static List<Map<String, dynamic>> listToJson(List<ProductModel> products) {
    return products.map((product) => product.toJson()).toList();
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