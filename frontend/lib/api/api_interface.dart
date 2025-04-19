import '../models/shop/product/product_request.dart';
import '../models/lobby/lobby_request.dart';
import '../models/lobby/lobby_response.dart';
import '../models/shop/product/product_response.dart';
import '../models/task/task_request.dart';
import '../models/task/task_response.dart';
import '../models/user/register_request.dart';
import '../models/user/user_response.dart';
import '../models/user/user_update_request.dart';
import '../models/wallet/wallet_request.dart';
import '../models/wallet/wallet_response.dart';

abstract class ApiInterface {
  Future<UserResponse> register(RegisterRequest request);
  Future<UserResponse> login(String username, String password);
  Future<void> recoverPassword({required String email, required String login});
  Future<UserResponse> updateUserProfile(UserUpdateRequest request);


  Future<LobbyResponse> createLobby(LobbyRequest request);


  Future<TaskResponse> createTask(TaskRequest request);
  Future<List<TaskResponse>> getUserTasks(String userId);
  Future<TaskResponse> completeTask(String taskId);


  Future<ProductResponse> createShopItem(ProductRequest request);


  Future<WalletResponse> updateWallet(WalletRequest request);
}