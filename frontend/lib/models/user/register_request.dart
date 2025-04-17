class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final DateTime birthdayDate;
  final String login;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.birthdayDate,
    required this.login,
  });

  Map<String, dynamic> toJson() => {
    'Customer_name': name,
    'Customer_email': email,
    'Password': password,
    'Birthday_date': birthdayDate.toIso8601String(),
    'Login': login,
  };
}