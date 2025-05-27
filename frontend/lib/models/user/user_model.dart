import 'dart:convert';
import 'dart:typed_data';

class UserModel {
  final int id;
  final String name;
  final String email;
  final DateTime? birthdayDate;
  final String login;
  final UserRole role;
  final String? photoBytes;
  String? password; // Только для регистрации/авторизации

  UserModel({
    this.id = 0,
    required this.name,
    required this.email,
    this.birthdayDate,
    required this.login,
    this.photoBytes,
    this.password,
    this.role = UserRole.user,
  });

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    DateTime? birthdayDate,
    String? login,
    String? photoBytes,
    String? password,
    UserRole? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      birthdayDate: birthdayDate ?? this.birthdayDate,
      login: login ?? this.login,
      photoBytes: photoBytes ?? this.photoBytes,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }

  factory UserModel.fromResponse(Map<String, dynamic> json) {
    return UserModel(
      id: _parseId(json),
      login: json['login'] ?? '',
      email: _parseEmail(json),
      role: UserRole.fromString(json['admin']?.toString() ?? ''),
      birthdayDate: _parseBirthdayDate(json),
      photoBytes: _parsePhotoBytes(json),
      name: _parseName(json),
    );
  }

  // Вспомогательные методы для парсинга с учетом обоих форматов
  static int _parseId(Map<String, dynamic> json) {
    return json['id'] ?? json['customer_ID'] ?? 0;
  }

  static String _parseName(Map<String, dynamic> json) {
    return json['name'] ?? json['customer_name'] ?? '';
  }

  static String _parseEmail(Map<String, dynamic> json) {
    return json['email'] ?? json['customer_email'] ?? '';
  }

  static DateTime? _parseBirthdayDate(Map<String, dynamic> json) {
    final dateStr = json['birthdayDate'] ?? json['birthday_date'];
    return dateStr != null ? DateTime.tryParse(dateStr) : null;
  }

  static String? _parsePhotoBytes(Map<String, dynamic> json) {
    return json['photo']?.toString() ?? json['customer_photo']?.toString();
  }

  Map<String, dynamic> toRegisterRequest() => {
    'login': login,
    'password': password,
    'email': email,
    'name': name,
  };

  Map<String, dynamic> toLoginRequest() => {
    'login': login,
    'password': password,
  };

  Map<String, dynamic> toRestoreRequest() => {
    'login': login,
    'email': email,
  };

  Map<String, dynamic> toResetRequest(String code, String newPassword) => {
    'login': login,
    'code': code,
    'newPassword': newPassword
  };

  Map<String, dynamic> toUpdateRequest() => {
    'customerId': id,
    'name': name,
    'email': email,
    if (birthdayDate != null) 'birthdayDate': birthdayDate!.toIso8601String(),
    if (photoBytes != null && photoBytes!.isNotEmpty) 'photo': photoBytes,
    'admin': role == UserRole.admin ? "ADMIN" : "USER",
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    if (birthdayDate != null) 'birthdayDate': birthdayDate!.toIso8601String(),
    'login': login,
    'photo': photoBytes,
    'admin': role == UserRole.admin ? "ADMIN" : "USER",
  };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _parseId(json),
      login: json['login'] ?? '',
      email: _parseEmail(json),
      role: UserRole.fromString(json['admin']?.toString() ?? ''),
      birthdayDate: _parseBirthdayDate(json),
      photoBytes: _parsePhotoBytes(json),
      name: _parseName(json),
    );
  }

  Uint8List? get photoBytesUint8List {
    return photoBytes != null && photoBytes!.isNotEmpty
        ? base64Decode(photoBytes!)
        : null;
  }

  @override
  bool operator ==(Object other) => identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum UserRole {
  user,
  admin;

  factory UserRole.fromString(String role) {
    if (role.toUpperCase() == "ADMIN") {
      return UserRole.admin;
    }
    return UserRole.user;
  }

  factory UserRole.fromBool(bool isAdmin) => isAdmin ? UserRole.admin : UserRole.user;

  bool get isAdmin => this == UserRole.admin;
}