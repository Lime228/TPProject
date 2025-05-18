class ProductModel {
  final int id;
  final String name;
  final String description;
  final String photoBase64;
  final bool isAvailable;
  final int price;
  final String? link;
  final int? customerId; // Может быть null, если продукт не куплен

  ProductModel({
    this.id = 0,
    required this.name,
    required this.description,
    required this.photoBase64,
    required this.isAvailable,
    required this.price,
    this.customerId,
    this.link,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      photoBase64: json['photo'] ?? '',
      isAvailable: json['state'] ?? false,
      price: json['price'] ?? '',
      customerId: json['customerId'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != 0) 'id': id,
    'name': name,
    'description': description,
    'photo': photoBase64,
    'state': isAvailable,
    'price': price,
    if (customerId != null) 'customerId': customerId,
    if (link != null) 'link': link,
  };

  ProductModel copyWith({
    int? id,
    String? name,
    String? description,
    String? photoBase64,
    bool? isAvailable,
    int? price,
    int? customerId,
    String? link,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      photoBase64: photoBase64 ?? this.photoBase64,
      isAvailable: isAvailable ?? this.isAvailable,
      price: price ?? this.price,
      customerId: customerId ?? this.customerId,
      link: link ?? this.link,
    );
  }
}
