// class UserResponse {
//   final int id;
//   final String username;
//   final String email;
//
//   UserResponse({
//     required this.id,
//     required this.username,
//     required this.email,
//   });
//
//   factory UserResponse.fromJson(Map<String, dynamic> json) {
//     return UserResponse(
//       id: json['id'],
//       username: json['username'],
//       email: json['email'],
//     );
//   }
// }

class UserResponse {
  final int id;
  final String name;
  final String email;
  final DateTime birthdayDate;
  final String login;
  final bool isAdmin;

  UserResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.birthdayDate,
    required this.login,
    required this.isAdmin,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['Customer_ID'],
      name: json['Customer_name'],
      email: json['Customer_email'],
      birthdayDate: DateTime.parse(json['Birthday_date']),
      login: json['Login'],
      isAdmin: json['Admin'],
    );
  }

  Map<String, dynamic> toJson() => {
    'Customer_ID': id,
    'Customer_name': name,
    'Customer_email': email,
    'Birthday_date': birthdayDate.toIso8601String(),
    'Login': login,
    'Admin': isAdmin,
  };
}