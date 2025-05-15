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
  final int shopId;
  final String? link;

  ProductModel({
    this.id = 0, // 0 для новых продуктов
    required this.name,
    required this.description,
    required this.photo,
    required this.state,
    required this.price,
    required this.customerId,
    required this.shopId,
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
      shopId: this.shopId,
    );
  }

  // Для создания продукта (без ID)
  Map<String, dynamic> createRequest() => {
    'name': name,
    'description': description,
    'photo': photo,
    'state': state,
    'price': price,
    'customerid': customerId,
    'shopid': shopId
  };

  Map<String, dynamic> updateRequest() => {
    'productid': id,
    'name': name,
    'description': description,
    'photo': photo,
    'state': state,
    'price': price,
  };
  Map<String, dynamic> deleteRequest() => {
    'shopid': shopId,
    'productid': id,
  };

  // Для полного JSON (с ID)
  Map<String, dynamic> toJson() => {
    if (id != 0) 'id': id,
    'name': name,
    'description': description,
    'photo': photo,
    'state': state,
    'price': price,
    'customerid': customerId,
    'shopid': shopId,
    if (link != null) 'Link': link,
  };

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'],
      description: json['description'],
      photo: json['photo'],
      state: json['state'],
      price: json['price'] is int
          ? (json['price'] as int).toDouble()
          : json['price'].toDouble(),
      customerId: json['customerid'],
      shopId: json['shopid'],
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