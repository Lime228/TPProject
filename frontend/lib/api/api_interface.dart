import 'package:zadachok/models/task/task_model.dart';

import '../models/lobby/lobby_model.dart';
import '../models/shop/product/product_model.dart';
import '../models/user/user_model.dart';
import '../models/wallet/wallet_model.dart';

abstract class ApiInterface {
  Future<UserModel> register(UserModel request);
  Future<UserModel> login(UserModel request);
  Future<void> recoverPassword({required String email, required String login});
  Future<UserModel> updateUserProfile(UserModel request);


  Future<LobbyModel> createLobby(LobbyModel request);


  Future<TaskModel> createTask(TaskModel request, int lId);
  Future<List<TaskModel>> getUserTasks(LobbyModel lobby, UserModel user);
  Future<TaskModel> completeTask(TaskModel task, UserModel user);
  Future<void> deleteTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);

  Future<List<ProductModel>> getShopItems();
  Future<ProductModel> createShopItem(ProductModel request);
  Future<ProductModel> updateShopItem(ProductModel request);
  Future<void> deleteShopItem(String itemId);




  Future<WalletModel> updateWallet(WalletModel request);

  void dispose();
}