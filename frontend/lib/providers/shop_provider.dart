import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zadachok/models/shop/shop_model.dart';
import '../api/api_interface.dart';
import '../models/shop/product/product_model.dart';

class ShopProvider with ChangeNotifier {
  final ApiInterface api;
  final SharedPreferences prefs;

  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  String _searchQuery = '';
  String _sortBy = 'name';
  bool _isLoading = false;
  String? _error;
  int? _currentShopId;

  // Геттеры
  List<ProductModel> get products => _filteredProducts;
  List<ProductModel> get allProducts => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get currentShopId => _currentShopId;

  ShopProvider({required this.api, required this.prefs}) {
    _loadShopId();
  }

  Future<void> _loadShopId() async {
    _currentShopId = prefs.getInt('current_shop_id');
  }

  Future<void> setCurrentShop(int shopId) async {
    _currentShopId = shopId;
    await prefs.setInt('current_shop_id', shopId);
    await loadProducts();
  }

  Future<void> loadProducts() async {
    if (_currentShopId == null) {
      _error = 'Магазин не выбран';
      return;
    }

    _setLoading(true);
    try {
      _products = await api.getShopProducts(_currentShopId!);
      _applyFilters();
    } catch (e) {
      _error = 'Ошибка загрузки товаров: $e';
      debugPrint(_error!);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createProduct(ProductModel product) async {
    return await addProduct(product);
  }

  Future<bool> addProduct(ProductModel product) async {
    if (_currentShopId == null) {
      _error = 'Магазин не выбран';
      return false;
    }

    try {
      final shop = ShopModel(id: _currentShopId!, productIds: []);
      final newProduct = await api.createShopItem(shop, product);
      _products.add(newProduct);
      _applyFilters();
      return true;
    } catch (e) {
      _error = 'Ошибка добавления товара: $e';
      debugPrint(_error!);
      return false;
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
    try {
      final updated = await api.updateShopItem(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) _products[index] = updated;
      _applyFilters();
      return true;
    } catch (e) {
      _error = 'Ошибка обновления товара: $e';
      debugPrint(_error!);
      return false;
    }
  }

  Future<bool> removeProduct(int productId) async {
    try {
      await api.deleteShopItem(productId);
      _products.removeWhere((p) => p.id == productId);
      _applyFilters();
      return true;
    } catch (e) {
      _error = 'Ошибка удаления товара: $e';
      debugPrint(_error!);
      return false;
    }
  }

  Future<void> refreshProducts() async {
    await loadProducts();
  }

  void clearProducts() {
    _products = [];
    _filteredProducts = [];
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _sortBy = 'name';
    _applyFilters();
  }

  void search(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void sort({String? option}) {
    if (option != null) {
      _sortBy = option;
      _applyFilters();
    }
  }

  void _applyFilters() {
    // Фильтрация
    _filteredProducts = _products.where((p) {
      return p.name.toLowerCase().contains(_searchQuery) ||
          p.description.toLowerCase().contains(_searchQuery);
    }).toList();

    // Сортировка
    switch (_sortBy) {
      case 'price_asc':
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      default: // name
        _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
    }

    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}