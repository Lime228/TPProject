import 'dart:convert';
import 'dart:io';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:zadachok/models/shop/product/product_model.dart';
import 'package:zadachok/providers/auth_provider.dart';
import 'package:zadachok/providers/group_provider.dart';
import 'package:zadachok/providers/settings_provider.dart';
import 'package:zadachok/providers/shop_provider.dart';
import 'dart:typed_data';

import '../models/wallet/wallet_model.dart';

const TextStyle _textStyleSemiBold = TextStyle(
  fontFamily: 'Inter',
  fontWeight: FontWeight.w600, // SemiBold
);

const TextStyle _textStyleBold = TextStyle(
  fontFamily: 'Inter',
  fontWeight: FontWeight.w700, // Bold
);

class ShopScreenConstants {
  static const double headerHeight = 100.0;

  static const double productCardRadius = 12.0;
  static const double productCardElevation = 4.0;
  static const double avatarRadius = 25.0;
  static const double headerFontSize = 22.0;
  static const Color primaryColor = Color(0xFF937DF3);
  static const Color secondaryColor = Color(0xFF937DF3);
  static const Color adminColor = Color(0xFF6E44FF);
  static const EdgeInsets headerPadding = EdgeInsets.fromLTRB(24, 15, 24, 10);
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets productCardPadding = EdgeInsets.all(8.0);
  static const double productCardWidth = 137.0;
  static const double productCardHeight = 137.0;
  static const double productInfoHeight = 4.0;
  static const double dialogBorderRadius = 16.0;
  static const EdgeInsets dialogPadding = EdgeInsets.all(24.0);
  static const Color dialogPrimaryColor = Color(0xFF937DF3);
  static const Color dialogSecondaryColor = Color(0xFF6E44FF);
  static const Color dialogErrorColor = Color(0xFFE57373);
  static const Color dialogSuccessColor = Color(0xFF81C784);
}

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _joinCodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _groupNameController = TextEditingController();
  final _searchController = TextEditingController();

  String _sortOption = 'all';

  File? _tempProductImage;
  final _addProductFormKey = GlobalKey<FormState>();
  final _editProductFormKey = GlobalKey<FormState>();
  ShopProvider? _shopProvider;
  bool _isMounted = false;

  File? _avatarImage;

  Future<void> _safeReportEvent(String eventName, {Map<String, dynamic>? attributes}) async {
    try {
      await AppMetrica.reportEvent(eventName);
    } catch (e) {
      debugPrint('Ошибка отправки события в AppMetrica: $e');
      await _reportErrorToAppMetrica(
        message: 'Failed to report event: $eventName',
        error: e,
      );
    }
  }

  Future<void> _reportErrorToAppMetrica({
    required dynamic error,
    String? message,
  }) async {
    try {
      await AppMetrica.reportError(
          message: message ?? 'Error occurred in ShopScreen',
        errorDescription: AppMetricaErrorDescription(
          (error is Exception ? error : Exception(error.toString())) as StackTrace,
        ),
      );
    } catch (e) {
      debugPrint('Ошибка отправки ошибки в AppMetrica: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isMounted) {
      _isMounted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeProviders();
      }
    });
  }

  void _initializeProviders() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _shopProvider = Provider.of<ShopProvider>(context, listen: false);

    _shopProvider?.setAuthProvider(authProvider);

    _loadData();
  }

  @override
  void dispose() {
    _joinCodeController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _linkController.dispose();
    _groupNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _searchProducts(String query) {
    _safeReportEvent('shop_search', attributes: {'query': query});
    Provider.of<ShopProvider>(context, listen: false).search(query);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: _textStyleSemiBold,)));
  }

  void _sortProducts({String? option}) {
    setState(() {
      _sortOption = option ?? 'all';
    });
    _safeReportEvent('shop_sort', attributes: {'option': option ?? 'all'});
    Provider.of<ShopProvider>(context, listen: false).sort(option: option);
  }

  void _resetFilters() {
    _safeReportEvent('shop_reset_filters');
    _searchController.clear();
    _sortOption = 'all';
    Provider.of<ShopProvider>(context, listen: false).resetFilters();
    FocusScope.of(context).unfocus();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    try {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (groupProvider.isInGroup && authProvider.isAuthorized) {
        await shopProvider.refreshProducts();
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки: ${e.toString()}', style: _textStyleSemiBold)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final userName =
        settingsProvider.userName ?? authProvider.user?.name ?? 'Гость';

    return Consumer<ShopProvider>(
      builder: (context, shopProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              _buildHeader(userName, settingsProvider.avatarBytes),
              Expanded(child: _buildMainContent()),
            ],
          ),
          floatingActionButton: _buildFloatingActionButton(),
        );
      },
    );
  }

  Widget _buildHeader(String userName, String? avatarBytes) {
    final authProvider = Provider.of<AuthProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);
    final theme = Theme.of(context);

    return FutureBuilder<WalletModel>(
      future:
      authProvider.isAuthorized
          ? authProvider.apiClient.updateWallet(
        WalletModel(
          customerId: authProvider.user!.id,
          lobbyId: Provider.of<GroupProvider>(context).lobbyId,
          balance: 0,
        ),
      )
          : null,
      builder: (context, snapshot) {
        final balance = snapshot.hasData ? snapshot.data!.balance : 0;

        return Container(
          width: double.infinity,
          height: ShopScreenConstants.headerHeight,
          decoration: BoxDecoration(
            color: ShopScreenConstants.primaryColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: ShopScreenConstants.headerPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: ShopScreenConstants.avatarRadius,
                    backgroundColor: Colors.white,
                    backgroundImage: authProvider.user?.photoBytes != null &&
                        authProvider.user!.photoBytes!.isNotEmpty
                        ? MemoryImage(base64Decode(authProvider.user!.photoBytes!))
                        : null,
                    child: authProvider.user?.photoBytes == null ||
                        authProvider.user!.photoBytes!.isEmpty
                        ? Icon(
                      Icons.person,
                      color: theme.colorScheme.secondary,
                      size: ShopScreenConstants.avatarRadius,
                    )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    authProvider.user?.name ?? 'Гость',
                    style: _textStyleBold.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (authProvider.isAuthorized && !authProvider.isAdmin && groupProvider.isInGroup)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            balance.toString(),
                            style: _textStyleBold.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (Provider.of<GroupProvider>(context).isOwner)
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 25,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4,
                      color: Colors.white,
                      offset: const Offset(0, 40),
                      onSelected: _handleMenuSelection,
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit, color: ShopScreenConstants.adminColor, size: 22),
                                const SizedBox(width: 3),
                                Text(
                                  'Управление товарами',
                                  style: _textStyleBold.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    final authProvider = Provider.of<AuthProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);
    final shopProvider = Provider.of<ShopProvider>(context);

    if (!groupProvider.isInGroup) {
      return _buildNoGroupView();
    }

    if (!shopProvider.isLoading && shopProvider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text('Нет товаров', style: _textStyleSemiBold.copyWith(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 8),
          ],
        ),
      );
    }

    return FutureBuilder(
      future: shopProvider.isLoading ? null : Future.value(true),
      builder: (context, snapshot) {
        if (shopProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(shopProvider.error!, style: _textStyleBold),
                ElevatedButton(
                  onPressed: () {
                    _safeReportEvent('shop_retry_load');
                    _loadData();
                  },
                  child: Text('Повторить попытку', style: _textStyleSemiBold),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildSearchAndSortBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () {
                  _safeReportEvent('shop_pull_to_refresh');
                  return _loadData();
                },
                child:
                shopProvider.products.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text('Ничего не найдено', style: _textStyleBold),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          _safeReportEvent('shop_reset_filters_button');
                          _resetFilters();
                        },
                        child: const Text('Сбросить фильтры', style: _textStyleSemiBold),
                      ),
                    ],
                  ),
                )
                    : GridView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: shopProvider.products.length,
                  itemBuilder: (context, index) {
                    final product = shopProvider.products[index];
                    return GestureDetector(
                      onTap: () {
                        _safeReportEvent('shop_product_tap', attributes: {'product_id': product.id});
                        _showProductDetails(product);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: _buildProductCard(product),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget? _buildFloatingActionButton() {
    final groupProvider = Provider.of<GroupProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final group = Provider.of<GroupProvider>(context, listen: false);

    if (!auth.isAuthorized || !group.isInGroup) return null;
    return groupProvider.isOwner
        ? FloatingActionButton(
      backgroundColor: ShopScreenConstants.primaryColor,
      onPressed: () {
        _safeReportEvent('shop_add_product_button');
        _showAddProductDialog();
      },
      child: const Icon(Icons.add, color: Colors.white),
    )
        : null;
  }

  Widget _buildProductImage(Uint8List photoBytes) {
    if (photoBytes.isEmpty) {
      return _buildPlaceholderImage();
    }

    return Image.memory(
      photoBytes,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        _safeReportEvent('shop_product_card_tap', attributes: {'product_id': product.id});
        _showProductDetails(product);
      },
      child: SizedBox(
        width: 168,
        height: 145,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  elevation: ShopScreenConstants.productCardElevation,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: SizedBox(
                      width: 200,
                      height: 170,
                      child: product.photoBytes.isNotEmpty
                          ? _buildProductImage(product.photoBytes)
                          : _buildPlaceholderImage(),
                    ),
                  ),
                ),
                Container(
                  width: 145,
                  height: 50,
                  decoration: BoxDecoration(
                    color: product.customerId != null
                        ? Colors.orange
                        : ShopScreenConstants.primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        product.name,
                        style: _textStyleBold.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              product.price.toStringAsFixed(
                                product.price.truncateToDouble() == product.price
                                    ? 0
                                    : 1,
                              ),
                              style: _textStyleBold.copyWith(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!product.isAvailable)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ),
            if (product.customerId != null && product.customerId != authProvider.user?.id)
              Positioned.fill(
                child: Container(
                  color: Colors.black38,
                  child: Center(
                    child: Text(
                      'Занято',
                      style: _textStyleBold.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPurchaseDialog(ProductModel product, ShopProvider shopProvider) {
    _safeReportEvent('shop_purchase_dialog_show', attributes: {'product_id': product.id});

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
        title: Text('Купить ${product.name}?', style: _textStyleBold),
        content: Text('Цена: ${product.price} звёзд', style: _textStyleBold),
        actions: [
          TextButton(
            onPressed: () {
              _safeReportEvent('shop_purchase_cancel', attributes: {'product_id': product.id});
              Navigator.pop(ctx);
            },
            child: Text('Отмена', style: _textStyleBold),
          ),
          TextButton(
            onPressed: () async {
              _safeReportEvent('shop_purchase_confirm', attributes: {'product_id': product.id});
              Navigator.pop(ctx);
              final success = await shopProvider.buyProduct(product.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Товар успешно куплен!', style: _textStyleSemiBold)),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка: ${shopProvider.error}', style: _textStyleSemiBold)),
                );
              }
            },
            child: const Text('Купить', style: _textStyleBold),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.shopping_bag, size: 50, color: Colors.grey),
      ),
    );
  }

  Widget _buildNoGroupView() {
    return Center(
      child: Padding(
        padding: ShopScreenConstants.defaultPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_add, size: 64, color: Color(0xFF937DF3)),
            const SizedBox(height: 20),
            Text(
              'Магазин доступен только для участников групп',
              style:  _textStyleBold.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Создайте новую группу или вступите в существующую, чтобы получить доступ к магазину',
              textAlign: TextAlign.center,
              style: _textStyleSemiBold.copyWith(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                _safeReportEvent('shop_create_group_button');
                _showCreateGroupDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ShopScreenConstants.secondaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:  Text(
                'Создать группу',
                style: _textStyleBold.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                _safeReportEvent('shop_join_group_button');
                _showJoinGroupDialog();
              },
              child:  Text(
                'Вступить в существующую группу',
                style: _textStyleBold.copyWith(color: Color(0xFF937DF3)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'edit':
        _safeReportEvent('shop_manage_products');
        _showProductListForEdit();
        break;
    }
  }

  void _showProductDetails(ProductModel product) {
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    _safeReportEvent('shop_product_details', attributes: {'product_id': product.id});

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    product.name,
                    style: _textStyleBold.copyWith(
                      fontSize: 18,
                      color: ShopScreenConstants.primaryColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _safeReportEvent('shop_product_details_close');
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      'Закрыть',
                      style: _textStyleSemiBold.copyWith(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: product.photoBytes.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    product.photoBytes,
                    fit: BoxFit.cover,
                  ),
                )
                    : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag, size: 50, color: Colors.grey),
                      Text('Нет изображения', style: _textStyleSemiBold.copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${product.price} звёзд',
                      style: _textStyleBold.copyWith(
                        fontSize: 18,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (product.description.isNotEmpty) ...[
                Text(
                    'Описание:',
                    style: _textStyleBold.copyWith(fontSize: 16)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    product.description,
                    style: _textStyleSemiBold.copyWith(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (product.link?.isNotEmpty ?? false) ...[
                Text(
                    'Ссылка:',
                    style: _textStyleBold.copyWith(fontSize: 16)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    _safeReportEvent('shop_product_link_open', attributes: {'product_id': product.id});
                    _openProductLink(product.link!);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.link!,
                      style: _textStyleSemiBold.copyWith(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (authProvider.isAuthorized && !authProvider.isAdmin)
                Column(
                  children: [
                    if (product.customerId == null)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ShopScreenConstants.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          _safeReportEvent('shop_product_buy', attributes: {'product_id': product.id});
                          Navigator.pop(ctx);
                          final success = await shopProvider.buyProduct(product.id);
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Товар зарезервирован! Подтвердите покупку.',
                                    style: _textStyleSemiBold),
                              ),
                            );
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Ошибка: ${shopProvider.error}',
                                  style: _textStyleSemiBold)),
                            );
                          }
                        },
                        child: Text(
                          'Купить',
                          style: _textStyleBold.copyWith(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      )
                    else if (product.customerId == authProvider.user?.id)
                      Column(
                        children: [
                          Text(
                            'Ожидает подтверждения',
                            style: _textStyleSemiBold.copyWith(color: Colors.orange),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              _safeReportEvent('shop_product_confirm', attributes: {'product_id': product.id});
                              Navigator.pop(ctx);
                              final success = await shopProvider.confirmPurchase(product.id);
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Покупка подтверждена!',
                                        style: _textStyleSemiBold),
                                  ),
                                );
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Ошибка: ${shopProvider.error}',
                                      style: _textStyleSemiBold)),
                                );
                              }
                            },
                            child: Text(
                              'Подтвердить покупку',
                              style: _textStyleBold.copyWith(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Товар зарезервирован другим пользователем',
                            style: _textStyleSemiBold.copyWith(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _reserveProduct(int productId) async {
    _safeReportEvent('shop_product_reserve', attributes: {'product_id': productId});
    final success = await Provider.of<ShopProvider>(context, listen: false)
        .buyProduct(productId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Товар зарезервирован! Подтвердите покупку.'))
      );
    }
  }

  void _confirmPurchase(int productId) async {
    _safeReportEvent('shop_product_confirm', attributes: {'product_id': productId});
    final success = await Provider.of<ShopProvider>(context, listen: false)
        .confirmPurchase(productId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Покупка подтверждена!'))
      );
    }
  }

  void _showAddProductDialog() {
    _safeReportEvent('shop_add_product_dialog_show');
    _nameController.clear();
    _descController.clear();
    _priceController.clear();
    _linkController.clear();
    _tempProductImage = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AnimatedPadding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            duration: const Duration(milliseconds: 100),
            child: Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _addProductFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _safeReportEvent('shop_add_product_cancel');
                                  _tempProductImage = null;
                                  Navigator.pop(ctx);
                                },
                                child:  Text(
                                  'Отмена',
                                  style: _textStyleSemiBold.copyWith(color: Colors.grey),
                                ),
                              ),
                              Text(
                                'Новый товар',
                                style: _textStyleBold.copyWith(
                                  color: ShopScreenConstants.primaryColor,
                                  fontSize: 18,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _safeReportEvent('shop_add_product_submit');
                                  _handleAddProduct(ctx);
                                },
                                child:  Text(
                                  'Готово',
                                  style: _textStyleBold.copyWith(
                                    color: ShopScreenConstants.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          GestureDetector(
                            onTap: () async {
                              _safeReportEvent('shop_add_product_image_pick');
                              final image = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                setState(
                                      () => _tempProductImage = File(image.path),
                                );
                              }
                            },
                            child: Container(
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _tempProductImage != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _tempProductImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    Text(
                                      'Добавить фото',
                                      style: _textStyleSemiBold.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildRoundedTextField(
                            controller: _nameController,
                            labelText: 'Название товара',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Введите название';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildRoundedTextField(
                            controller: _descController,
                            labelText: 'Описание',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),

                          _buildRoundedTextField(
                            controller: _priceController,
                            labelText: 'Цена в звёздах',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Введите цену';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Введите число';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildRoundedTextField(
                            controller: _linkController,
                            labelText: 'Ссылка на товар',
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoundedTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: labelText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines == null ? 0 : 16,
          ),
        ),
      ),
    );
  }

  Future<void> _handleAddProduct(BuildContext dialogContext) async {
    if (!_addProductFormKey.currentState!.validate()) return;

    final shopProvider = Provider.of<ShopProvider>(context, listen: false);

    try {
      Uint8List imageBytes = Uint8List(0);

      if (_tempProductImage != null) {
        imageBytes = await _tempProductImage!.readAsBytes();
      }

      final newProduct = ProductModel(
        name: _nameController.text,
        description: _descController.text,
        photoBytes: imageBytes,
        isAvailable: true,
        price: int.parse(_priceController.text),
        link: _linkController.text.isEmpty ? null : _linkController.text,
      );

      final success = await shopProvider.createProduct(newProduct);

      if (success && mounted) {
        Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Товар успешно добавлен!', style: _textStyleSemiBold)),
        );
        await shopProvider.refreshProducts();
      }
    } catch (e) {
      debugPrint('Ошибка при добавлении товара: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: ${e.toString()}', style: _textStyleSemiBold)));
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descController.clear();
    _priceController.clear();
    _linkController.clear();
    if (mounted) {
      setState(() {
        _tempProductImage = null;
      });
    }
  }

  void _showProductListForEdit() {
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    if (!groupProvider.isOwner) return;
    if (!groupProvider.isInGroup) {
      _showError('Вы не состоите в группе');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Управление товарами',
                    style: _textStyleBold.copyWith(
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _safeReportEvent('shop_manage_products_close');
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: shopProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : shopProvider.products.isEmpty
                  ? const Center(child: Text('Нет товаров для отображения', style: _textStyleSemiBold))
                  : ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: shopProvider.products.length,
                itemBuilder: (context, index) {
                  final product = shopProvider.products[index];
                  return ListTile(
                    title: Text(product.name, style: _textStyleSemiBold),
                    subtitle: Text('${product.price} звёзд', style: _textStyleSemiBold),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _safeReportEvent('shop_product_edit', attributes: {'product_id': product.id});
                            Navigator.pop(ctx);
                            _showEditProductDialog(product);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            _safeReportEvent('shop_product_delete_attempt', attributes: {'product_id': product.id});
                            final confirm = await showModalBottomSheet<bool>(
                              context: context,
                              builder: (ctx) => Material(
                                color: Colors.white,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16.0)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Удалить этот товар?',
                                        style: _textStyleBold.copyWith(
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () {
                                                _safeReportEvent('shop_product_delete_cancel', attributes: {'product_id': product.id});
                                                Navigator.pop(ctx, false);
                                              },
                                              child: const Text('Отмена', style: _textStyleSemiBold),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              onPressed: () {
                                                _safeReportEvent('shop_product_delete_confirm', attributes: {'product_id': product.id});
                                                Navigator.pop(ctx, true);
                                              },
                                              child: const Text('Удалить', style: _textStyleSemiBold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );

                            if (confirm == true) {
                              final success = await shopProvider
                                  .removeProduct(product.id);
                              if (mounted) {
                                if (success) {
                                  await shopProvider.refreshProducts();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Товар удалён', style: _textStyleSemiBold),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Ошибка: ${shopProvider.error}',
                                          style: _textStyleSemiBold
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndSortBar() {
    return Container(
      width: 352,
      height: 27,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 168,
            height: 27,
            decoration: BoxDecoration(
              color: ShopScreenConstants.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: PopupMenuButton<String>(
              color: Colors.white,
              offset: const Offset(0, 30),
              onSelected: (value) {
                _safeReportEvent('shop_sort_select', attributes: {'option': value});
                _sortProducts(option: value);
              },
              itemBuilder:
                  (context) => [
                const PopupMenuItem<String>(
                  value: 'price_asc',
                  child: Text('По возрастанию цены', style: _textStyleSemiBold),
                ),
                const PopupMenuItem<String>(
                  value: 'price_desc',
                  child: Text('По убыванию цены', style: _textStyleSemiBold),
                ),
                const PopupMenuItem<String>(
                  value: 'name',
                  child: Text('По названию', style: _textStyleSemiBold),
                ),
                const PopupMenuItem<String>(
                  value: 'all',
                  child: Text('Обычная сортировка', style: _textStyleSemiBold),
                ),
              ],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sort, color: Colors.white, size: 16),
                  SizedBox(width: 5),
                  Text(
                    'Сортировка',
                    style: _textStyleSemiBold.copyWith(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 27,
              decoration: BoxDecoration(
                color: const Color(0xFFC1FFEB),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: ShopScreenConstants.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ShopScreenConstants.primaryColor,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Поиск товаров...',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: _searchProducts,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[600], size: 16),
                    onPressed: () {
                      _safeReportEvent('shop_search_clear');
                      _resetFilters();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(ProductModel product) {
    _safeReportEvent('shop_edit_product_dialog_show', attributes: {'product_id': product.id});
    _nameController.text = product.name;
    _descController.text = product.description;
    _priceController.text = product.price.toString();
    _linkController.text = product.link ?? '';
    _tempProductImage = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _editProductFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              _safeReportEvent('shop_edit_product_cancel', attributes: {'product_id': product.id});
                              _tempProductImage = null;
                              Navigator.pop(ctx);
                            },
                            child: Text(
                              'Отмена',
                              style: _textStyleSemiBold.copyWith(color: Colors.grey),
                            ),
                          ),
                          Text(
                            'Редактировать товар',
                            style: _textStyleBold.copyWith(
                                fontSize: 18,
                                color: ShopScreenConstants.primaryColor
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _safeReportEvent('shop_edit_product_save', attributes: {'product_id': product.id});
                              _handleEditProduct(ctx, product);
                            },
                            child:  Text(
                              'Сохранить',
                              style: _textStyleBold.copyWith( color: ShopScreenConstants.primaryColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: () async {
                          _safeReportEvent('shop_edit_product_image_pick', attributes: {'product_id': product.id});
                          final image = await _picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            setState(() => _tempProductImage = File(image.path));
                          }
                        },
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _tempProductImage != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _tempProductImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                              : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                Text(
                                  'Добавить фото',
                                  style: _textStyleSemiBold.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildRoundedTextField(
                        controller: _nameController,
                        labelText: 'Название товара',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите название';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildRoundedTextField(
                        controller: _descController,
                        labelText: 'Описание',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      _buildRoundedTextField(
                        controller: _priceController,
                        labelText: 'Цена в звёздах',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите цену';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Введите число';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildRoundedTextField(
                        controller: _linkController,
                        labelText: 'Ссылка на товар',
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleEditProduct(
      BuildContext dialogContext,
      ProductModel product,
      ) async {
    if (!_editProductFormKey.currentState!.validate()) return;

    final shopProvider = Provider.of<ShopProvider>(context, listen: false);

    final updatedProduct = product.copyWith(
      name: _nameController.text,
      description: _descController.text,
      photoBytes:
      _tempProductImage != null
          ? await _tempProductImage!.readAsBytes()
          : product.photoBytes,
      price: int.parse(_priceController.text),
      link: _linkController.text,
    );

    try {
      final success = await shopProvider.updateProduct(updatedProduct);
      if (mounted) {
        if (success) {
          _tempProductImage = null;
          Navigator.pop(dialogContext);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Товар успешно обновлен', style: _textStyleSemiBold)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка: ${shopProvider.error}', style: _textStyleSemiBold)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка: ${e.toString()}', style: _textStyleSemiBold)));
      }
    }
  }



  void _showCreateGroupDialog() {
    _safeReportEvent('shop_create_group_dialog_show');
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    if (groupProvider.isInGroup) {
      _showError('Вы уже в группе');
      return;
    }

    bool _isCreating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ShopScreenConstants.dialogBorderRadius),
            ),
            backgroundColor: Colors.white,
            elevation: 8,
            child: Padding(
              padding: ShopScreenConstants.dialogPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Заголовок
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Создать группу',
                        style: _textStyleBold.copyWith(
                          fontSize: 20,
                          color: ShopScreenConstants.dialogPrimaryColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey),
                        onPressed: _isCreating ? null : () => Navigator.pop(ctx),
                      ),
                    ],
                  ),

                  // Иконка + описание
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.group_add,
                          size: 64,
                          color: ShopScreenConstants.dialogPrimaryColor,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Создайте свою группу',
                          style: _textStyleSemiBold.copyWith(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'После создания вы получите код для приглашения друзей',
                          style: _textStyleSemiBold.copyWith(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Кнопки
                  if (_isCreating)
                    CircularProgressIndicator()
                  else
                    Row(
                      children: [
                        // Кнопка "Отмена"
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color: ShopScreenConstants.dialogPrimaryColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              'Отмена',
                              style: _textStyleSemiBold.copyWith(
                                color: ShopScreenConstants.dialogPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        // Кнопка "Создать"
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ShopScreenConstants.dialogPrimaryColor,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              setState(() => _isCreating = true);
                              try {
                                await groupProvider.createGroup();
                                if (mounted) {
                                  Navigator.pop(ctx);
                                  _showGroupCreatedDialog(groupProvider.groupCode!);
                                }
                              } catch (e) {
                                _showError('Ошибка: ${e.toString()}');
                                setState(() => _isCreating = false);
                              }
                            },
                            child: Text(
                              'Создать',
                              style: _textStyleBold.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showGroupCreatedDialog(String groupCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShopScreenConstants.dialogBorderRadius),
        ),
        backgroundColor: Colors.white,
        elevation: 8,
        child: Padding(
          padding: ShopScreenConstants.dialogPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Иконка успеха
              Icon(
                Icons.check_circle,
                size: 64,
                color: ShopScreenConstants.dialogSuccessColor,
              ),
              SizedBox(height: 16),

              // Заголовок
              Text(
                'Группа создана!',
                style: _textStyleBold.copyWith(
                  fontSize: 20,
                  color: ShopScreenConstants.primaryColor,
                ),
              ),
              SizedBox(height: 16),

              // Код группы
              Text(
                'Код для присоединения:',
                style: _textStyleSemiBold,
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  color: ShopScreenConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  groupCode,
                  style: _textStyleBold.copyWith(
                    fontSize: 24,
                    letterSpacing: 2,
                    color: ShopScreenConstants.primaryColor,
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Подсказка
              Text(
                'Дайте этот код участникам, чтобы они могли присоединиться',
                style: _textStyleSemiBold.copyWith(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),

              // Кнопка "Скопировать"
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ShopScreenConstants.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: groupCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Код скопирован!', style: _textStyleSemiBold))
                  );
                  Navigator.pop(ctx);
                },
                child: Text(
                  'Скопировать код',
                  style: _textStyleBold.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJoinGroupDialog() {
    _safeReportEvent('shop_join_group_dialog_show');
    bool _isJoining = false;
    String? _errorText;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ShopScreenConstants.dialogBorderRadius),
            ),
            backgroundColor: Colors.white,
            elevation: 8,
            child: Padding(
              padding: ShopScreenConstants.dialogPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Заголовок
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Вступить в группу',
                        style: _textStyleBold.copyWith(
                          fontSize: 20,
                          color: ShopScreenConstants.primaryColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey),
                        onPressed: _isJoining ? null : () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Иконка
                  Icon(
                    Icons.group,
                    size: 48,
                    color: ShopScreenConstants.primaryColor,
                  ),
                  SizedBox(height: 16),

                  // Поле ввода
                  TextField(
                    controller: _joinCodeController,
                    decoration: InputDecoration(
                      labelText: 'Код группы',
                      hintText: 'Введите 6-значный код',
                      errorText: _errorText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: ShopScreenConstants.primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                    maxLength: 6,
                    textCapitalization: TextCapitalization.characters,
                    style: _textStyleSemiBold.copyWith(letterSpacing: 2),
                  ),
                  SizedBox(height: 16),

                  // Кнопки
                  if (_isJoining)
                    CircularProgressIndicator()
                  else
                    Row(
                      children: [
                        // Отмена
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color: ShopScreenConstants.primaryColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              'Отмена',
                              style: _textStyleSemiBold.copyWith(
                                color: ShopScreenConstants.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        // Присоединиться
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ShopScreenConstants.primaryColor,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              final code = _joinCodeController.text.trim();
                              if (code.length != 6) {
                                setState(() => _errorText = 'Нужно 6 символов');
                                return;
                              }

                              setState(() => _isJoining = true);
                              try {
                                final success = await Provider.of<GroupProvider>(
                                  context,
                                  listen: false,
                                ).joinGroup(code);

                                if (success && mounted) {
                                  Navigator.pop(ctx);
                                  _showJoinSuccessDialog();
                                } else {
                                  setState(() {
                                    _errorText = 'Неверный код';
                                    _isJoining = false;
                                  });
                                }
                              } catch (e) {
                                setState(() {
                                  _errorText = 'Ошибка: ${e.toString()}';
                                  _isJoining = false;
                                });
                              }
                            },
                            child: Text(
                              'Присоединиться',
                              style: _textStyleBold.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showJoinSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShopScreenConstants.dialogBorderRadius),
        ),
        backgroundColor: Colors.white,
        elevation: 8,
        child: Padding(
          padding: ShopScreenConstants.dialogPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: ShopScreenConstants.dialogSuccessColor,
              ),
              SizedBox(height: 16),
              Text(
                'Вы в группе!',
                style: _textStyleBold.copyWith(
                  fontSize: 20,
                  color: ShopScreenConstants.primaryColor,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Теперь вы можете покупать товары в магазине',
                style: _textStyleSemiBold.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ShopScreenConstants.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Отлично!',
                  style: _textStyleBold.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openProductLink(String url) async {
    _safeReportEvent('shop_product_link_open', attributes: {'url': url});
    // TODO: Реализовать открытие ссылки
  }
}

class _uploadAvatarToServer {
  _uploadAvatarToServer(File file);
}