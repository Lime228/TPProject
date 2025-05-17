class ProductModel{
  int id;
  String name;
  String description;
  String photo;
  bool state;
  int price;
  int customerId;
  String? link;

  ProductModel({
    this.id = 0,
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
    bool? state,
    int? price,
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
  // Map<String, dynamic> createRequest(int shopID) => {
  //   'name': name,
  //   'description': description,
  //   'photo': photo,
  //   'state': state,
  //   'price': price,
  //   'shopid': shopID,
  //   'link': link
  // };
  //
  // Map<String, dynamic> updateRequest() => {
  //   'productid': id,
  //   'name': name,
  //   'description': description,
  //   'photo': photo,
  //   'state': state,
  //   'price': price,
  //   'link': link
  // };
  // Map<String, dynamic> deleteRequest(int shopID) => {
  //   'shopid': shopID,
  //   'productid': id,
  // };

  // // Для полного JSON (с ID)
  // Map<String, dynamic> toJson() => {
  //   if (id != 0) 'id': id,
  //   'name': name,
  //   'description': description,
  //   'photo': photo,
  //   'state': state,
  //   'price': price,
  //   'customerid': customerId,
  //   // 'shopid': shopId,
  //   if (link != null) 'Link': link,
  // };

  factory ProductModel.fromResponse(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'],
      description: json['description'],
      photo: json['photo'],
      state: json['state'],
      price: json['price'] is int
          ? (json['price'] as int).toDouble()
          : json['price'].toDouble(),
      customerId: json['customerid'], // его скорее всего нет и не будет ни в одном из возвратов с сервера напомните исправить если надо будет
      link: json['link'],
    );
  }


  // static List<Map<String, dynamic>> listToJson(List<ProductModel> products) {
  //   return products.map((product) => product.toJson()).toList();
  // }

  // Валидация продукта
  void validate() {
    if (name.isEmpty) throw ArgumentError('Product name cannot be empty');
    if (price <= 0) throw ArgumentError('Price must be positive');
    if (customerId <= 0) throw ArgumentError('Customer ID must be positive');
  }

}