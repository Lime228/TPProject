import '../base_request.dart';
import '../base_response.dart';

class UserModel implements BaseRequest<UserModel>, BaseResponse {
  @override
  final int id;
  final String name;
  final String email;
  final DateTime birthdayDate;
  final String login;
  final bool isAdmin;
  final String photo;
  final String password;

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
      name: json['name'],
      email: json['email'],
      birthdayDate: DateTime.parse(json['birthdayDate']),
      login: json['login'],
    );
  }

  // Для ответа
  factory UserModel.fromResponse(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'],
      email: json['email'],
      birthdayDate: DateTime.parse(json['birthdayDate']),
      login: json['login'],
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    if (id != 0) 'id': id,
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
