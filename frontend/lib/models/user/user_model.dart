import '../base_request.dart';
import '../base_response.dart';

class UserModel implements BaseRequest<UserModel>, BaseResponse {
  @override
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

  // Для запроса
  factory UserModel.fromRequest(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      birthdayDate: DateTime.parse(json['birthdayDate'] ?? DateTime.now().toString()),
      login: json['login'] ?? '',
    );
  }

  // Для ответа
  factory UserModel.fromResponse(Map<String, dynamic> json) {
    final dynamic idValue = json['customer_ID'] ?? json['id'] ?? json['user_id'] ?? 0;
    final int id = int.tryParse(idValue.toString()) ?? 0;

    if (id == 0) {
      throw FormatException('Invalid user ID in response. Fields: ${json.keys}');
    }

    return UserModel(
      id: json['customer_ID'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      birthdayDate: DateTime.parse(json['birthdayDate'] ?? DateTime.now().toString()),
      login: json['login'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'customer_ID': id,
    'name': name,
    'email': email,
    'birthdayDate': birthdayDate.toIso8601String(),
    'login': login,
    'isAdmin': isAdmin,
  };

  Map<String, dynamic> registerRequest() => {
    'login': login,
    'password': password,
    'email': email,
  };

  Map<String, dynamic> loginRequest() => {
    'login': login,
    'password': password,
  };

  @override
  UserModel fromJson(Map<String, dynamic> json) {
    return UserModel.fromResponse(json);
  }
}
