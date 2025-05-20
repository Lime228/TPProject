class UserModel {
  final int id;
  final String name;
  final String email;
  final DateTime? birthdayDate;
  final String login;
  final UserRole role;
  final String photoBase64;
  String? password; // Только для регистрации/авторизации

  UserModel({
    this.id = 0,
    required this.name,
    required this.email,
    this.birthdayDate,
    required this.login,
    this.photoBase64 = '',
    this.password,
    this.role = UserRole.user,
  });

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    DateTime? birthdayDate,
    String? login,
    String? photoBase64,
    String? password,
    UserRole? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      birthdayDate: birthdayDate ?? this.birthdayDate,
      login: login ?? this.login,
      photoBase64: photoBase64 ?? this.photoBase64,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }

  factory UserModel.fromResponse(Map<String, dynamic> json) {
    return UserModel(
      id: json['customer_ID'] ?? 0,
      name: json['name'] ?? '',
      email: json['customer_email'] ?? '',
      birthdayDate: json['birthdayDate'] != null
          ? DateTime.tryParse(json['birthdayDate'])
          : null,
      login: json['login'] ?? '',
      photoBase64: json['photo'] ?? '',
      role: UserRole.fromBool(json['isAdmin'] ?? false),
    );
  }

  Map<String, dynamic> toRegisterRequest() => {
    'login': login,
    'password': password,
    'email': email,
    'name': name,
    if (birthdayDate != null) 'birthdayDate': birthdayDate!.toIso8601String(),
    if (photoBase64.isNotEmpty) 'photo': photoBase64,
  };

  Map<String, dynamic> toLoginRequest() => {
    'login': login,
    'password': password,
  };

  Map<String, dynamic> toUpdateRequest() => {
    'customerId': id,
    'name': name,
    'email': email,
    if (birthdayDate != null) 'birthdayDate': birthdayDate!.toIso8601String(),
    if (photoBase64.isNotEmpty) 'photo': photoBase64,
    'isAdmin': role == UserRole.admin,
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    if (birthdayDate != null) 'birthdayDate': birthdayDate!.toIso8601String(),
    'login': login,
    'isAdmin': role == UserRole.admin,
    'photo': photoBase64,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      birthdayDate: json['birthdayDate'] != null
          ? DateTime.tryParse(json['birthdayDate'])
          : null,
      login: json['login'] ?? '',
      photoBase64: json['photo'] ?? '',
      role: UserRole.fromBool(json['isAdmin'] ?? false),
    );
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

  factory UserRole.fromBool(bool isAdmin) => isAdmin ? UserRole.admin : UserRole.user;

  bool get isAdmin => this == UserRole.admin;
}
