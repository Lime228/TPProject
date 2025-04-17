import '../models/user/register_request.dart';
import '../models/user/user_response.dart';

abstract class ApiInterface {
  Future<UserResponse> register(RegisterRequest request);
  Future<void> login(String username, String password); // Изменено на UserResponse
}