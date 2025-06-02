import 'package:zadachok/models/task/task_model.dart';

import '../models/lobby/lobby_model.dart';
import '../models/shop/product/product_model.dart';
import '../models/shop/shop_model.dart';
import '../models/user/user_model.dart';
import '../models/wallet/wallet_model.dart';

abstract class ApiInterface {
  Future<UserModel> register(UserModel request);
  Future<UserModel> login(UserModel request);
  Future<bool> resetPassword(UserModel request, String code, String password);
  Future<bool> restorePassword(UserModel request);
  Future<UserModel> updateUserProfile(UserModel request);
  String? getAuthToken();
  void setAuthToken(String token);
  Future<LobbyModel> createLobby(int creatorID);
  Future<TaskModel> createTask(TaskModel request, int lId);
  Future<List<TaskModel>> getUserTasks(LobbyModel lobby, UserModel user);
  Future<TaskModel> completeTask(TaskModel task, UserModel user);
  Future<void> deleteTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<List<ProductModel>> getShopProducts(int shopID);
  Future<ProductModel> createShopItem(ShopModel shop, ProductModel product);
  Future<ProductModel> updateShopItem(ProductModel request);
  Future<void> deleteShopItem(int shopId, int productId);
  Future<WalletModel> updateWallet(WalletModel request);
  Future<Map<String, dynamic>> generateNotification(int taskId);
  Future<Map<String, dynamic>> getNotificationStatus(String notificationId);


  void dispose();
}