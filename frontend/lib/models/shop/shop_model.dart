import '../base_request.dart';
import '../base_response.dart';

class ShopModel implements BaseRequest<ShopModel>, BaseResponse{
  final int id;
  final int productId;
  final int quantity;

  ShopModel({
    this.id = 0, // 0 означает новый объект (для создания)
    required this.productId,
    required this.quantity,
  });

  // Для запроса (без ID)
  Map<String, dynamic> toCreateJson() => {
    'Product_ID': productId,
    'Quantity': quantity,
  };

  // Для полного JSON (с ID)
  Map<String, dynamic> toJson() => {
    if (id != 0) 'Shop_ID': id,
    'Product_ID': productId,
    'Quantity': quantity,
  };

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['Shop_ID'] ?? 0,
      productId: json['Product_ID'],
      quantity: json['Quantity'],
    );
  }

  // Для списка магазинов по productId
  static List<ShopModel> listByProductFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => ShopModel.fromJson(json)).toList();
  }

  // Валидация
  void validate() {
    if (productId <= 0) throw ArgumentError('Product ID must be positive');
    if (quantity < 0) throw ArgumentError('Quantity cannot be negative');
  }

  @override
  ShopModel fromJson(Map<String, dynamic> json) {
    // TODO: implement fromJson
    throw UnimplementedError();
  }
}