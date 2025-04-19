class ProductRequest {
  final String name;
  final String description;
  final String photo;
  final String state;
  final double price;
  final int customerId;

  ProductRequest({
    required this.name,
    required this.description,
    required this.photo,
    required this.state,
    required this.price,
    required this.customerId,
  });

  Map<String, dynamic> toJson() => {
    'Product_name': name,
    'Description': description,
    'Photo': photo,
    'Product_state': state,
    'Price': price,
    'Customer_ID': customerId,
  };
}