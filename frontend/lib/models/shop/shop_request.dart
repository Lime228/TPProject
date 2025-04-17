class ShopRequest {
  final int productId;
  final int quantity;

  ShopRequest({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
    'Product_ID': productId,
    'Quantity': quantity,
  };
}