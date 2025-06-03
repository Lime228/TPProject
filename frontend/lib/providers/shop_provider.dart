import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zadachok/models/shop/shop_model.dart';
import 'package:zadachok/models/user/user_model.dart';
import '../api/api_client.dart';
import '../api/api_interface.dart';
import '../models/shop/product/product_model.dart';
import 'auth_provider.dart';
import 'group_provider.dart';

class ShopProvider with ChangeNotifier {
  final client = ApiClient();
  final SharedPreferences prefs;
  AuthProvider? authProvider;

  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  String _searchQuery = '';
  String _sortBy = 'name';
  bool _isLoading = false;
  String? _error;
  int? _currentShopId;

  ShopProvider({required this.authProvider, required this.prefs});

  // Геттеры
  List<ProductModel> get products => _filteredProducts;
  List<ProductModel> get allProducts => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get currentShopId => _currentShopId;

  void setAuthProvider(AuthProvider provider) {
    authProvider = provider;
    notifyListeners();
  }


  Future<void> refreshProducts() async {
    if (_currentShopId == null || authProvider?.user == null) return;

    if (_isLoading) return;

    _setLoading(true);
    _error = null;

    try {
      final apiClient = _getAuthenticatedClient();
      final products = await apiClient.getShopProducts(_currentShopId!);
      _products = products.where((p) => p.isAvailable).toList();
      debugPrint('Начало обновления товаров для магазина $_currentShopId');
      _products = products;
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка обновления товаров: ${e.toString()}';
      debugPrint(_error!);
    } finally {
      _setLoading(false);
    }
    debugPrint('Загружено ${_products.length} товаров');
  }

  ApiClient _getAuthenticatedClient() {
    if (authProvider?.token == null) throw Exception('Токен отсутствует');
    client.setAuthToken(authProvider!.token!);
    return client;
  }

  Future<void> _loadShopId() async {
    _currentShopId = prefs.getInt('current_shop_id');
  }

  Future<void> setCurrentShop(int shopId) async {
    if (shopId <= 0) {
      debugPrint('Ошибка: некорректный shopId: $shopId');
      return;
    }
    _currentShopId = shopId;
    await prefs.setInt('current_shop_id', shopId);
    await refreshProducts();
  }

  Future<void> loadProducts() async {
    if (_currentShopId == null) {
      _error = 'Магазин не выбран';
      return;
    }

    _setLoading(true);
    try {
      final apiClient = _getAuthenticatedClient();
      _products = await apiClient.getShopProducts(_currentShopId!);
      _applyFilters();
    } catch (e) {
      _error = 'Ошибка загрузки товаров: $e';
      debugPrint(_error!);
    } finally {
      _setLoading(false);
    }
  }


  Future<bool> createProduct(ProductModel product) async {
    if (_currentShopId == null) {
      _error = 'Магазин не выбран';
      return false;
    }

    try {
      final shop = ShopModel(id: _currentShopId!, productIds: []);
      final apiClient = _getAuthenticatedClient();
      final newProduct = await apiClient.createShopItem(shop, product);
      _products.add(newProduct);
      _applyFilters();
      notifyListeners(); // Добавьте это
      return true;
    } catch (e) {
      _error = 'Ошибка добавления товара: $e';
      debugPrint(_error!);
      return false;
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
    try {
      final apiClient = _getAuthenticatedClient();
      final updated = await apiClient.updateShopItem(product);
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

  // Резервирование товара (первый этап)
  Future<bool> buyProduct(int productId) async {
    try {
      final result = await client.buyShopItem(
        _currentShopId!,
        productId,
        authProvider!.user!.id,
      );

      if (result.customerId == authProvider!.user!.id) {
        await refreshProducts();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Ошибка резервирования: ${e.toString()}';
      return false;
    }
  }

  Future<bool> confirmPurchase(int productId) async {
    try {
      final product = _products.firstWhere((p) => p.id == productId);

      // Проверяем что пользователь - покупатель
      if (product.customerId != authProvider!.user!.id) {
        throw Exception('Нельзя подтвердить чужую покупку');
      }

      // Обновляем статус товара
      final updated = await client.updateShopItem(
          product.copyWith(
            id: productId, // Убедимся, что ID передается
            isAvailable: false,
          )
      );

      return !updated.isAvailable;
    } catch (e) {
      _error = 'Ошибка подтверждения: ${e.toString()}';
      return false;
    }
  }


  Future<bool> removeProduct(int productId) async {

    if (_currentShopId == null) {
      _error = 'Магазин не выбран';
      return false;
    }

    try {
      final apiClient = _getAuthenticatedClient();
      await apiClient.deleteShopItem(_currentShopId!, productId);
      _products.removeWhere((p) => p.id == productId);
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Ошибка удаления товара: $e';
      debugPrint(_error!);
      return false;
    }
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
  @override
  void dispose() {
    _setLoading(false); // Отменяем текущую загрузку при уничтожении
    super.dispose();
  }
}