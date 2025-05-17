class UserModel{
  int id;
  String name;
  String email;
  DateTime birthdayDate;
  String login;
  bool isAdmin;
  String photo;
  String password;

  UserModel({
    this.id = 0,
    required this.name,
    required this.email,
    required this.birthdayDate,
    required this.login,
    this.photo = '',
    this.password = '',
    this.isAdmin = false,
  });

  // Для ответа
  factory UserModel.fromResponse(Map<String, dynamic> json) {
    return UserModel(
      id: json['customer_ID'] ?? 0,
      login: json['login'] ?? '',
      email: json['customer_email'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      birthdayDate: DateTime.parse(json['birthdayDate'] ?? DateTime.now().toString()),
      photo: json['photo'],
      name: json['name'] ?? '',
    );
  }


  Map<String, dynamic> registerRequest() => {
    'login': login,
    'password': password,
    'email': email,
  };

  Map<String, dynamic> loginRequest() => {
    'login': login,
    'password': password,
  };

  Map<String, dynamic> updateDetailsRequest() => {
    'customerId': id,
    'birthday': birthdayDate, // вероятно тут надо как то по другому передавать
    'photo': photo,
    'name': name
  };



}
