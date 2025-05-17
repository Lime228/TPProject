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
  bool _isLoadingProductCreation = false;
  bool _isLoadingProductDeletion = false;
  String? _error;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  bool get isLoadingProductCreation => _isLoadingProductCreation;
  bool get isLoadingProductDeletion => _isLoadingProductDeletion;
  String? get error => _error;

  List<ProductModel> _filteredProducts = [];
  String _searchQuery = '';
  String _sortOption = 'all';

  List<ProductModel> get filteredProducts => _filteredProducts;


  ShopProvider({required this.apiClient, required this.prefs}) {
    _init();
  }

  Future<void> _init() async {
    await loadProducts();
  }

  Future<void> loadProducts() async {
    _setLoading(true);
    _error = null;

    try {
      _products = await apiClient.getShopProducts();
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка загрузки товаров: ${e.toString()}';
      debugPrint(_error!);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addProduct(ProductModel product) async {
    try {
      final newProduct = await apiClient.createShopItem(product);
      _products.add(newProduct);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createProduct(ProductModel product) async {
    _setLoadingProductCreation(true);
    _error = null;

    try {
      debugPrint('Создание товара: ${product.name}');
      final newProduct = await apiClient.createShopItem(product);
      debugPrint('Получен товар с id: ${newProduct.id}');

      _products.add(newProduct);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка при создании товара: $e');
      _error = e.toString();
      return false;
    } finally {
      _setLoadingProductCreation(false);
    }
  }


  Future<bool> updateProduct(ProductModel product) async {
    _setLoading(true);
    _error = null;

    try {
      debugPrint('Обновление товара с id: ${product.id}');
      final updatedProduct = await apiClient.updateShopItem(product);
      debugPrint('Товар обновлен: ${updatedProduct.id}');

      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }

      await _updateCache();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Ошибка обновления товара: ${e.toString()}';
      debugPrint('Ошибка обновления товара: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> removeProduct(int productId) async {
    _setLoadingProductDeletion(true);
    _error = null;

    try {
      debugPrint('Удаление товара с id: $productId');
      await apiClient.deleteShopItem(productId.toString());
      _products.removeWhere((p) => p.id == productId);

      await _updateCache();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Ошибка удаления товара: ${e.toString()}';
      debugPrint('Ошибка удаления товара: $e');
      return false;
    } finally {
      _setLoadingProductDeletion(false);
    }
  }

  Future<void> _updateCache() async {
    final groupId = prefs.getString('current_group_id');
    if (groupId != null) {
      await prefs.setString(
          'cached_products_$groupId',
          jsonEncode(ProductModel.listToJson(_products))
      );
    }
  }

  Future<void> refreshProducts() async {
    await loadProducts();
  }

  void clearProducts() {
    _products = [];
    notifyListeners();
  }

  void searchProducts(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void sortProducts({String? option}) {
    _sortOption = option ?? 'all';
    _applyFilters();
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _sortOption = 'all';
    _applyFilters();
    notifyListeners();
  }



  void _applyFilters() {

    List<ProductModel> result = _products.where((product) {
      final nameMatches = product.name.toLowerCase().contains(_searchQuery);
      final descMatches = product.description.toLowerCase().contains(_searchQuery);
      return nameMatches || descMatches;
    }).toList();


    switch (_sortOption) {
      case 'price_asc':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'name':
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      default:
        break;
    }

    _filteredProducts = result;
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      Future.microtask(() => notifyListeners());
    }
  }


  void _setLoadingProductCreation(bool loading) {
    _isLoadingProductCreation = loading;
    notifyListeners();
  }

  void _setLoadingProductDeletion(bool loading) {
    _isLoadingProductDeletion = loading;
    notifyListeners();
  }
}