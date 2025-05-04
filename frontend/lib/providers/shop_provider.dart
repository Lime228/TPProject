import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zadachok/api/api_interface.dart';
import 'package:zadachok/models/shop/product/product_model.dart';

class ShopProvider with ChangeNotifier {
  final ApiInterface apiClient;
  final SharedPreferences prefs;

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ShopProvider({required this.apiClient, required this.prefs}) {
    _init();
  }

  Future<void> _init() async {
    final groupId = prefs.getString('current_group_id');
    if (groupId == null) {
      _products = [];
      return;
    }

    final cachedData = prefs.getString('cached_products_$groupId');
    if (cachedData != null) {
      try {
        final jsonList = jsonDecode(cachedData) as List;
        _products = ProductModel.listFromJson(jsonList);
      } catch (e) {
        print('Ошибка загрузки кэша: $e');
      }
    }
    await loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      _isLoading = true;
      notifyListeners();

      final groupId = prefs.getString('current_group_id');
      if (groupId == null) {
        _products = [];
        return;
      }

      _products = await apiClient.getShopItems();
      await prefs.setString(
          'cached_products_$groupId',
          jsonEncode(ProductModel.listToJson(_products))
      );
      _error = null;
    } catch (e) {
      _error = 'Ошибка загрузки товаров';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      _isLoading = true;
      notifyListeners();

      final newProduct = await apiClient.createShopItem(product);
      _products.add(newProduct);
      _error = null;
    } catch (e) {
      _error = 'Ошибка добавления товара';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updatedProduct = await apiClient.updateShopItem(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      _error = null;
    } catch (e) {
      _error = 'Ошибка обновления товара';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeProduct(int productId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await apiClient.deleteShopItem(productId.toString());
      _products.removeWhere((p) => p.id == productId);
      _error = null;
    } catch (e) {
      _error = 'Ошибка удаления товара';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearProducts() {
    _products = [];
    notifyListeners();
  }
}