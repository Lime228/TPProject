import '../models/user/register_request.dart';
import '../models/user/user_response.dart';

abstract class ApiInterface {
  Future<UserResponse> register(RegisterRequest request);
  Future<UserResponse> login(String username, String password);
  Future<void> recoverPassword({required String email, required String login});
}