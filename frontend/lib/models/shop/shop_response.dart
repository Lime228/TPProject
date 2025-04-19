class ShopResponse {
  final int id;
  final int productId;
  final int quantity;

  ShopResponse({
    required this.id,
    required this.productId,
    required this.quantity,
  });

  factory ShopResponse.fromJson(Map<String, dynamic> json) {
    return ShopResponse(
      id: json['Shop_ID'],
      productId: json['Product_ID'],
      quantity: json['Quantity'],
    );
  }

  Map<String, dynamic> toJson() => {
    'Shop_ID': id,
    'Product_ID': productId,
    'Quantity': quantity,
  };
}