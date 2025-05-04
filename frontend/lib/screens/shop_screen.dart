import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:zadachok/models/shop/product/product_model.dart';
import 'package:zadachok/providers/auth_provider.dart';
import 'package:zadachok/providers/group_provider.dart';
import 'package:zadachok/providers/settings_provider.dart';
import 'package:zadachok/providers/shop_provider.dart';


class ShopScreenConstants {
  static const double headerHeight = 100.0;
  static const double productCardWidth = 168.0;
  static const double productCardHeight = 180.0;
  static const double productCardRadius = 12.0;
  static const double productCardElevation = 4.0;
  static const double avatarRadius = 25.0;
  static const double headerFontSize = 22.0;
  static const Color primaryColor = Color(0xFF937DF3);
  static const Color secondaryColor = Color(0xFF6E44FF);
  static const EdgeInsets headerPadding = EdgeInsets.fromLTRB(24, 15, 24, 10);
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets productCardPadding = EdgeInsets.all(8.0);
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

  File? _tempProductImage;
  final _addProductFormKey = GlobalKey<FormState>();
  final _editProductFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _joinCodeController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _linkController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);

    if (groupProvider.isInGroup) {
      await shopProvider.loadProducts();
    } else {
      shopProvider.clearProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final userName = settingsProvider.userName ?? authProvider.user?.name ?? 'Гость';

    return Scaffold(

      backgroundColor: Colors.white,
      body: Column(
        children: [

          _buildHeader(userName, settingsProvider.avatarImage),


          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader(String userName, File? avatarImage) {
    final authProvider = Provider.of<AuthProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);


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
                backgroundImage: avatarImage != null
                    ? FileImage(avatarImage)
                    : null,
                child: avatarImage == null
                    ? const Icon(Icons.person, color: Colors.deepPurple, size: 25)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                settingsProvider.userName ?? authProvider.user?.name ?? 'Гость',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (Provider.of<GroupProvider>(context).isOwner)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white, size: 25),
              onSelected: (value) => _handleMenuSelection(value),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Управление товарами'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    final authProvider = Provider.of<AuthProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);
    final shopProvider = Provider.of<ShopProvider>(context);

    if (!authProvider.isAuthenticated) {
      return _buildUnauthorizedView();
    }

    if (!groupProvider.isInGroup) {
      return _buildNoGroupView();
    }

    if (shopProvider.isLoading && shopProvider.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (shopProvider.error != null) {
      return Center(child: Text(shopProvider.error!));
    }

    return Padding(
      padding: ShopScreenConstants.productCardPadding,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: shopProvider.products.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showProductDetails(shopProvider.products[index]),
            child: _buildProductCard(shopProvider.products[index]),
          );
        },
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    final groupProvider = Provider.of<GroupProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final group = Provider.of<GroupProvider>(context, listen: false);

    if (!auth.isAuthenticated || !group.isInGroup) return null;
    return groupProvider.isOwner
        ? FloatingActionButton(
      backgroundColor: ShopScreenConstants.primaryColor,
      onPressed: () => _showAddProductDialog(),
      child: const Icon(Icons.add),
    )
        : null;
  }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      elevation: ShopScreenConstants.productCardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ShopScreenConstants.productCardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: product.photo.isNotEmpty
                  ? Image.network(
                product.photo,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
              )
                  : _buildPlaceholderImage(),
            ),
          ),

          Padding(
            padding: ShopScreenConstants.defaultPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (product.description.isNotEmpty)
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${product.price.toStringAsFixed(0)} звёзд',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    if (product.link?.isNotEmpty ?? false)
                      IconButton(
                        icon: const Icon(Icons.link),
                        onPressed: () => _openProductLink(product.link!),
                      ),
                  ],
                ),
              ],
            ),
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

  Widget _buildUnauthorizedView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),
          SizedBox(height: 20),
          Text('Доступ ограничен', style: TextStyle(fontSize: 24)),
          SizedBox(height: 10),
          Text('Для работы с магазином необходимо авторизоваться',
              textAlign: TextAlign.center),
        ],
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
            const Text(
              'Магазин доступен только для участников групп',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Создайте новую группу или вступите в существующую, чтобы получить доступ к магазину',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _showCreateGroupDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: ShopScreenConstants.secondaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Создать группу', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: _showJoinGroupDialog,
              child: const Text(
                'Вступить в существующую группу',
                style: TextStyle(color: Color(0xFF6E44FF)),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(product.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (product.photo.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product.photo,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                _buildPlaceholderImage(),
              const SizedBox(height: 16),
              if (product.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    product.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              Text(
                'Цена: ${product.price.toStringAsFixed(0)} звёзд',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              if (product.link?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: InkWell(
                    onTap: () => _openProductLink(product.link!),
                    child: Text(
                      product.link!,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog() {
    _nameController.clear();
    _descController.clear();
    _priceController.clear();
    _linkController.clear();
    _tempProductImage = null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Добавить товар'),
            content: SingleChildScrollView(
              child: Form(
                key: _addProductFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final image = await _picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() => _tempProductImage = File(image.path));
                        }
                      },
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: _tempProductImage != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_tempProductImage!, fit: BoxFit.cover),
                        )
                            : const Icon(Icons.add_a_photo, size: 40),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Название товара'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите название';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(labelText: 'Описание'),
                    ),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Цена в звёздах'),
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
                    TextFormField(
                      controller: _linkController,
                      decoration: const InputDecoration(labelText: 'Ссылка на товар'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _tempProductImage = null;
                  Navigator.pop(ctx);
                },
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => _handleAddProduct(ctx),
                child: const Text('Добавить'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleAddProduct(BuildContext dialogContext) async {
    if (!_addProductFormKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);

    final newProduct = ProductModel(
      id: DateTime.now().millisecondsSinceEpoch,
      name: _nameController.text,
      description: _descController.text,
      photo: _tempProductImage?.path ?? '',
      state: 'Available',
      price: double.parse(_priceController.text),
      customerId: authProvider.user?.id ?? 0,
      link: _linkController.text,
    );

    try {
      await shopProvider.addProduct(newProduct);
      if (mounted) {
        _tempProductImage = null;
        Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Товар добавлен')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.toString()}')),
        );
      }
    }
  }

  void _showProductListForEdit() {
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    if (!groupProvider.isOwner) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Управление товарами'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: shopProvider.products.length,
            itemBuilder: (context, index) {
              final product = shopProvider.products[index];
              return ListTile(
                title: Text(product.name),
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
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => shopProvider.removeProduct(product.id),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть'),
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

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Редактировать товар'),
            content: SingleChildScrollView(
              child: Form(
                key: _editProductFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final image = await _picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() => _tempProductImage = File(image.path));
                        }
                      },
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: _tempProductImage != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_tempProductImage!, fit: BoxFit.cover),
                        )
                            : product.photo.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(product.photo, fit: BoxFit.cover),
                        )
                            : const Icon(Icons.add_a_photo, size: 40),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Название товара'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите название';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(labelText: 'Описание'),
                    ),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Цена в звёздах'),
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
                    TextFormField(
                      controller: _linkController,
                      decoration: const InputDecoration(labelText: 'Ссылка на товар'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _tempProductImage = null;
                  Navigator.pop(ctx);
                },
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => _handleEditProduct(ctx, product),
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleEditProduct(BuildContext dialogContext, ProductModel product) async {
    if (!_editProductFormKey.currentState!.validate()) return;

    final shopProvider = Provider.of<ShopProvider>(context, listen: false);

    final updatedProduct = product.copyWith(
      name: _nameController.text,
      description: _descController.text,
      photo: _tempProductImage?.path ?? product.photo,
      price: double.parse(_priceController.text),
      link: _linkController.text,
    );

    try {
      await shopProvider.updateProduct(updatedProduct);
      if (mounted) {
        _tempProductImage = null;
        Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Товар обновлен')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.toString()}')),
        );
      }
    }
  }

  void _showJoinGroupDialog() {
    _joinCodeController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Вступить в группу"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _joinCodeController,
              decoration: const InputDecoration(labelText: "Код группы"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Отмена"),
          ),
          TextButton(
            onPressed: () async {
              final scaffold = ScaffoldMessenger.of(context);
              try {
                final success = await Provider.of<GroupProvider>(context, listen: false)
                    .joinGroup(_joinCodeController.text.trim());

                if (success && mounted) {
                  Navigator.pop(context);
                  scaffold.showSnackBar(
                    const SnackBar(content: Text('Вы успешно вступили в группу!')),
                  );
                } else {
                  scaffold.showSnackBar(
                    const SnackBar(content: Text('Неверный код группы')),
                  );
                }
              } catch (e) {
                scaffold.showSnackBar(
                  SnackBar(content: Text('Ошибка: ${e.toString()}')),
                );
              }
            },
            child: const Text("Вступить"),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog() {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    _groupNameController.clear();

    if (groupProvider.isInGroup) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вы уже в группе')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Создать группу'),
        content: TextField(
          controller: _groupNameController,
          decoration: const InputDecoration(
            labelText: 'Название группы',
            hintText: 'Минимум 3 символа',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              final scaffold = ScaffoldMessenger.of(context);
              try {
                final name = _groupNameController.text.trim();
                if (name.isEmpty) {
                  scaffold.showSnackBar(
                    const SnackBar(content: Text('Введите название группы')),
                  );
                  return;
                }

                await groupProvider.createGroup(name);
                if (mounted) {
                  Navigator.pop(ctx);
                  scaffold.showSnackBar(
                    const SnackBar(content: Text('Группа создана!')),
                  );
                }
              } catch (e) {
                scaffold.showSnackBar(
                  SnackBar(content: Text('Ошибка: ${e.toString()}')),
                );
              }
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  void _openProductLink(String url) async {
    // TODO: Реализовать открытие ссылки
  }
}