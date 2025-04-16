class UserResponse {
  final int id;
  final String username;
  final String email;

  UserResponse({
    required this.id,
    required this.username,
    required this.email,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'],
      username: json['username'],
      email: json['email'],
    );
  }
}