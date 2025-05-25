import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
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
    Provider.of<ShopProvider>(context, listen: false).search(query);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: _textStyleSemiBold,)));
  }

  void _sortProducts({String? option}) {
    setState(() {
      _sortOption = option ?? 'all';
    });
    Provider.of<ShopProvider>(context, listen: false).sort(option: option);
  }

  void _resetFilters() {
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
                      offset: const Offset(0, 40), // Смещение меню относительно кнопки
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
                  onPressed: _loadData,
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
                onRefresh: _loadData,
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
                                onPressed: _resetFilters,
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
                              onTap: () => _showProductDetails(product),
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
          onPressed: () => _showAddProductDialog(),
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
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        if (authProvider.isAdmin) {
          _showProductDetails(product);
        } else {
          _showProductDetails(product);
        }
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
                      child:
                          product.photoBytes.isNotEmpty
                              ? _buildProductImage(product.photoBytes)
                              : _buildPlaceholderImage(),
                    ),
                  ),
                ),
                Container(
                  width: 145,
                  height: 50,
                  decoration: BoxDecoration(
                    color: ShopScreenConstants.primaryColor,
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
                                product.price.truncateToDouble() ==
                                        product.price
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
          ],
        ),
      ),
    );
  }

  void _showPurchaseDialog(ProductModel product, ShopProvider shopProvider) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Купить ${product.name}?', style: _textStyleBold),
            content: Text('Цена: ${product.price} звёзд', style: _textStyleBold),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Отмена', style: _textStyleBold),
              ),
              TextButton(
                onPressed: () async {
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
              onPressed: _showCreateGroupDialog,
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
              onPressed: _showJoinGroupDialog,
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
        _showProductListForEdit();
        break;
    }
  }

  void _showProductDetails(ProductModel product) {
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

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
                  const SizedBox(width: 40), // Для выравнивания
                  Text(
                    product.name,
                    style: _textStyleBold.copyWith(
                      fontSize: 18,
                      color: ShopScreenConstants.primaryColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
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

              // Изображение товара
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

              // Цена товара
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

              // Описание товара
              if (product.description.isNotEmpty) ...[
                Text(
                  'Описание:',
                  style: _textStyleBold.copyWith(
                    fontSize: 16,
                  ),
                ),
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

              // Ссылка на товар
              if (product.link?.isNotEmpty ?? false) ...[
                Text(
                  'Ссылка:',
                  style: _textStyleBold.copyWith(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _openProductLink(product.link!),
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

              // Кнопка покупки
              if (authProvider.isAuthorized && !authProvider.isAdmin)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ShopScreenConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final success = await shopProvider.buyProduct(product.id);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Товар успешно куплен!', style: _textStyleSemiBold), ),
                      );
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ошибка: ${shopProvider.error}', style: _textStyleSemiBold)),
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
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddProductDialog() {
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
                                onPressed: () => _handleAddProduct(ctx),
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
      Uint8List imageBytes = Uint8List(0); // Пустой массив по умолчанию

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
                    onPressed: () => Navigator.pop(ctx),
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
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: const Text('Отмена', style: _textStyleSemiBold),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              onPressed: () => Navigator.pop(ctx, true),
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
              onSelected: (value) => _sortProducts(option: value),
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
                    onPressed: _resetFilters,
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
                            onPressed: () => _handleEditProduct(ctx, product),
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

  void _showJoinGroupDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Вступить в группу", style: _textStyleBold),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _joinCodeController,
                  decoration: const InputDecoration(
                    labelText: "Код группы",
                    hintText: "Введите 6-значный код",
                  ),
                  maxLength: 6,
                  textCapitalization: TextCapitalization.characters,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Отмена", style: _textStyleSemiBold),
              ),
              TextButton(
                onPressed: () async {
                  final code = _joinCodeController.text.trim();
                  if (code.length != 6) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text("Код должен содержать 6 символов", style: _textStyleSemiBold),
                      ),
                    );
                    return;
                  }

                  final success = await Provider.of<GroupProvider>(
                    context,
                    listen: false,
                  ).joinGroup(code);

                  if (success && mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Вы успешно присоединились!", style: _textStyleSemiBold),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text("Ошибка присоединения", style: _textStyleSemiBold)),
                    );
                  }
                },
                child: const Text("Присоединиться", style: _textStyleBold),
              ),
            ],
          ),
    );
  }

  void _showCreateGroupDialog() {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    if (groupProvider.isInGroup) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Вы уже в группе', style: _textStyleSemiBold)));
      return;
    }

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Создать новую группу", style: _textStyleBold),
            content: const Text(
              "Нажмите 'Создать' для генерации группы с уникальным кодом",
                style: _textStyleSemiBold
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Отмена", style: _textStyleSemiBold),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await groupProvider.createGroup();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Группа создана! Код: ${groupProvider.groupCode}',
                            style: _textStyleSemiBold
                        ),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка: ${e.toString()}', style: _textStyleSemiBold)),
                    );
                  }
                },
                child: const Text("Создать",style: _textStyleBold),
              ),
            ],
          ),
    );
  }

  void _openProductLink(String url) async {
    // TODO: Реализовать открытие ссылки
  }
}

class _uploadAvatarToServer {
  _uploadAvatarToServer(File file);
}
