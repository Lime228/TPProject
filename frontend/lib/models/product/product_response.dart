class ProductResponse {
  final int id;
  final String name;
  final String description;
  final String photo;
  final String state;
  final double price;
  final int customerId;

  ProductResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.photo,
    required this.state,
    required this.price,
    required this.customerId,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      id: json['Product_ID'],
      name: json['Product_name'],
      description: json['Description'],
      photo: json['Photo'],
      state: json['Product_state'],
      price: json['Price'].toDouble(),
      customerId: json['Customer_ID'],
    );
  }

  Map<String, dynamic> toJson() => {
    'Product_ID': id,
    'Product_name': name,
    'Description': description,
    'Photo': photo,
    'Product_state': state,
    'Price': price,
    'Customer_ID': customerId,
  };
}