import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:zadachok/providers/auth_provider.dart';
import 'package:zadachok/providers/settings_provider.dart';
import 'package:zadachok/providers/group_provider.dart';
import 'package:zadachok/routes/main_navigation.dart';

import '../api/api_client.dart';
import '../models/user/user_model.dart';
import '../providers/shop_provider.dart';
import '../providers/task_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const double BLOCK_WIDTH = 352.0;
  static const double BLOCK_PADDING = 15.0;
  static const double BLOCK_BORDER_RADIUS = 15.0;
  static const double TITLE_FONT_SIZE = 25.0;
  static const Color TITLE_COLOR = Color(0xFF6E44FF);
  static const Color DECORATIVE_LINE_COLOR = Color(0xFFCCC1FF);
  static const double DECORATIVE_LINE_WIDTH = 250.0;
  static const double DECORATIVE_LINE_HEIGHT = 2.0;
  static const double AVATAR_RADIUS = 50.0;
  static const double SETTINGS_ICON_SIZE = 24.0;

  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _nameController = TextEditingController(text: 'Имя');
  // final _surnameController = TextEditingController(text: 'Фамилия');
  final _birthDateController = TextEditingController(text: 'ДД.ММ.ГГГГ');
  final _picker = ImagePicker();

  File? _avatarImage;

  final Map<String, int> _taskStatistics = {
    'Пн': 3, 'Вт': 7, 'Ср': 3,
    'Чт': 8, 'Пт': 6, 'Сб': 4, 'Вс': 2,
  };

  final Map<String, GlobalKey> _blockKeys = {
    'личные данные': GlobalKey(),
    'статистика': GlobalKey(),
    'уведомления': GlobalKey(),
    'другие настройки': GlobalKey(),
    'бонусные настройки': GlobalKey(),
    'экспериментальные функции': GlobalKey(),
    'обновления': GlobalKey(),
    'геолокация': GlobalKey(),
    'аккаунт': GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    if (authProvider.isAuthorized && authProvider.user != null) {
      final user = authProvider.user!;
      _nameController.text = user.name;
      // _surnameController.text = user.name.split(' ').length > 1 ? user.name.split(' ')[1] : '';

      if (user.birthdayDate != null) {
        _birthDateController.text =
        '${user.birthdayDate!.day}.${user.birthdayDate!.month}.${user.birthdayDate!.year}';
      }

      // Загрузка аватарки из настроек
      await settingsProvider.loadSettings();
      if (settingsProvider.avatarImage != null) {
        setState(() => _avatarImage = settingsProvider.avatarImage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isAuthorized = authProvider.isAuthorized;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Настройки',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: TITLE_COLOR,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildSearchField(),
                    const SizedBox(height: 15),
                    _buildPersonalDataBlock(authProvider, isAuthorized),
                    _buildDecorativeLine(),
                    _buildStatisticsBlock(authProvider, isAuthorized),
                    _buildDecorativeLine(),
                    _buildNotificationsBlock(settings),
                    _buildDecorativeLine(),
                    _buildAccountBlock(authProvider, isAuthorized),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildSearchField() {
    return GestureDetector(
      onTap: () => _scrollToBlock(_searchController.text),
      child: Container(
        width: BLOCK_WIDTH,
        height: 27,
        decoration: BoxDecoration(
          color: const Color(0xFFC1FFEB),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            const Icon(Icons.search, color: TITLE_COLOR, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 12, color: TITLE_COLOR),
                decoration: const InputDecoration(
                  hintText: 'Поиск',
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDataBlock(AuthProvider authProvider, bool isAuthorized) {
    return _buildBlock(
      key: _blockKeys['личные данные']!,
      title: 'Личные данные',
      child: isAuthorized
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),
          const SizedBox(width: 30),
          _buildNameFields(),
        ],
      )
          : _unauthorizedMessage('Упс(\nЛичные данные можно просматривать\nтолько авторизовавшись'),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: AVATAR_RADIUS,
          backgroundColor: Colors.grey,
          backgroundImage: _avatarImage != null ? FileImage(_avatarImage!) : null,
          child: _avatarImage == null
              ? const Icon(Icons.person, size: 50, color: Colors.white)
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: TITLE_COLOR,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameFields() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Поле для имени
          const Text('Имя', style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _nameController,
              onChanged: (value) async {
                if (authProvider.isAuthorized && authProvider.user != null) {
                  final updatedUser = authProvider.user!.copyWith(name: value);
                  await _updateUserProfile(updatedUser);
                }
              },
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
                hintText: 'Введите имя',
              ),
            ),
          ),
          const SizedBox(height: 16),

          // // Поле для фамилии
          // const Text('Фамилия', style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
          // const SizedBox(height: 8),
          // Container(
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(18),
          //     boxShadow: const [
          //       BoxShadow(
          //         color: Colors.black12,
          //         blurRadius: 8,
          //         offset: Offset(0, 4),
          //       ),
          //     ],
          //   ),
          //   child: TextField(
          //     controller: _surnameController,
          //     onChanged: (value) async {
          //       if (authProvider.isAuthorized && authProvider.user != null) {
          //         final fullName = _nameController.text + (value.isNotEmpty ? ' $value' : '');
          //         final updatedUser = authProvider.user!.copyWith(name: fullName);
          //         await _updateUserProfile(updatedUser);
          //       }
          //     },
          //     decoration: const InputDecoration(
          //       contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          //       border: InputBorder.none,
          //       hintText: 'Введите фамилию',
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 16),

          // Поле для даты рождения
          const Text('Дата рождения', style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _birthDateController,
              onChanged: (value) async {
                if (authProvider.isAuthorized && authProvider.user != null) {
                  try {
                    final dateParts = value.split('.');
                    if (dateParts.length == 3) {
                      final day = int.parse(dateParts[0]);
                      final month = int.parse(dateParts[1]);
                      final year = int.parse(dateParts[2]);
                      final newDate = DateTime(year, month, day);

                      final updatedUser = authProvider.user!.copyWith(birthdayDate: newDate);
                      await _updateUserProfile(updatedUser);

                      // Обновляем в локальных настройках
                      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
                      await settingsProvider.updateUserData(birthDate: value);
                    }
                  } catch (e) {
                    debugPrint('Ошибка формата даты: $e');
                  }
                }
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
                hintText: 'ДД.ММ.ГГГГ',
                hintStyle: TextStyle(
                  color: Color(0x81_E4_E4_E4), // Чёрный, 50% прозрачности
                ),
                filled: true,
                fillColor: Colors.white, // Светло-серый фон
              ),
              keyboardType: TextInputType.datetime,
            )
          ),

          // Кнопка сохранения изменений (опционально)
          if (authProvider.isAuthorized) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6E44FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () async {
                  // Дополнительное подтверждение сохранения
                  final shouldSave = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Сохранить изменения?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Отмена'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Сохранить'),
                        ),
                      ],
                    ),
                  );

                  if (shouldSave == true) {
                    await _updateAllFields();
                  }
                },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 35, top: 0), // ← Настройте значения
                    child: Text(
                      'Сохранить изменения',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _updateAllFields() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthorized || authProvider.user == null) return;

    try {
      // Формируем полное имя
      final fullName = _nameController.text;

      // Парсим дату рождения
      DateTime? birthDate;
      try {
        final dateParts = _birthDateController.text.split('.');
        if (dateParts.length == 3) {
          birthDate = DateTime(
            int.parse(dateParts[2]),
            int.parse(dateParts[1]),
            int.parse(dateParts[0]),
          );
        }
      } catch (e) {
        debugPrint('Ошибка парсинга даты: $e');
      }

      // Создаем обновленного пользователя
      final updatedUser = authProvider.user!.copyWith(
        name: fullName,
        birthdayDate: birthDate,
      );

      // Обновляем на сервере
      await _updateUserProfile(updatedUser);

      // Обновляем локальные настройки
      final settingsProvider = Provider.of<SettingsProvider>(
          context, listen: false);
      await settingsProvider.updateUserData(
        name: _nameController.text,
        // surname: _surnameController.text,
        birthDate: _birthDateController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Данные успешно сохранены')),
      );
    } catch (e) {
      debugPrint('Ошибка сохранения данных: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сохранения: $e')),
      );
    }
  }

  Widget _buildStatisticsBlock(AuthProvider authProvider, bool isAuthorized) {
    return _buildBlock(
      key: _blockKeys['статистика']!,
      title: 'Статистика',
      child: isAuthorized
          ? Column(
        children: [
          const Text(
            'Количество выполненных заданий по дням',
            style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 220,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _taskStatistics.entries.map((entry) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 28,
                        height: entry.value * 18.0,
                        decoration: BoxDecoration(
                          color: TITLE_COLOR,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.key,
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        entry.value.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      )
          : _unauthorizedMessage('Упс(\nСтатистику можно просматривать\nтолько авторизовавшись'),
    );
  }

  Widget _buildNotificationsBlock(SettingsProvider settings) {
    return _buildBlock(
      key: _blockKeys['уведомления']!,
      title: 'Уведомления',
      child: SwitchListTile(
        activeTrackColor: Color(0xFF6E44FF),
        value: settings.notificationsEnabled,
        onChanged: (val) => settings.update('notificationsEnabled', val),
        title: const Text('Получать уведомления'),
        secondary: const Icon(Icons.notifications, size: SETTINGS_ICON_SIZE),
      ),
    );
  }



  Widget _buildAccountBlock(AuthProvider authProvider, bool isAuthorized) {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    return _buildBlock(
      key: _blockKeys['аккаунт']!,
      title: 'Аккаунт',
      child: isAuthorized
          ? Column(
        children: [
          const SizedBox(height: 20),

          // 🔄 Кнопка обновления данных
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: TextButton(
              onPressed: () async {
                try {
                  await authProvider.refreshAll(groupProvider, taskProvider, shopProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Данные успешно обновлены')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка обновления: $e')),
                  );
                }
              },
              child: const Text(
                'Обновить данные',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: TextButton(
              onPressed: () {
                authProvider.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                      (route) => false,
                );
              },
              child: const Text(
                'Выйти из аккаунта',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'После выхода потребуется повторная авторизация',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      )
          : Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: TextButton(
              onPressed: () {
                authProvider.logout();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                );
              },
              child: const Text(
                'Войти в аккаунт',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Авторизуйтесь для доступа ко всем функциям',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  Widget _buildDecorativeLine() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: DECORATIVE_LINE_WIDTH,
          height: DECORATIVE_LINE_HEIGHT,
          child: DecoratedBox(
            decoration: BoxDecoration(color: DECORATIVE_LINE_COLOR),
          ),
        ),
      ),
    );
  }

  Widget _buildBlock({
    required String title,
    required Widget child,
    Key? key,
  }) {
    return Container(
        key: key,
        width: BLOCK_WIDTH,
        padding: const EdgeInsets.all(BLOCK_PADDING),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(BLOCK_BORDER_RADIUS),
    boxShadow: const [
    BoxShadow(
    color: Colors.black12,
    blurRadius: 8,
    offset: Offset(0, 4),
    ),
    ],
    ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    title,
    style: const TextStyle(
    fontSize: TITLE_FONT_SIZE,
    fontWeight: FontWeight.bold,
    color: TITLE_COLOR,
    ),
    ),
    const SizedBox(height: 15),
    child,
    ],
    ),
    );
  }

  Widget _unauthorizedMessage(String text) {
    return Container(
      width: BLOCK_WIDTH,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 17, color: Color(0xFF666666)),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _scrollToBlock(String query) {
    final normalizedQuery = query.toLowerCase().trim();
    for (final entry in _blockKeys.entries) {
      if (entry.key.contains(normalizedQuery)) {
        final key = entry.value;
        if (key.currentContext != null) {
          Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
        return;
      }
    }
  }

  // Обновим метод _pickImage:
  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final file = File(image.path);
        setState(() => _avatarImage = file);

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

        // Сохраняем локально
        await settingsProvider.updateUserData(avatar: file);

        // Обновляем на сервере
        if (authProvider.isAuthorized && authProvider.user != null) {
          final updatedUser = authProvider.user!.copyWith(photoBase64: base64Encode(await file.readAsBytes()));
          await authProvider.setAuthData(
            user: updatedUser,
            token: authProvider.token!,
          );

          final apiClient = ApiClient();
          apiClient.setAuthToken(authProvider.token!);
          await apiClient.updateUserProfile(updatedUser);
        }
      }
    } catch (e) {
      debugPrint('Ошибка при выборе изображения: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при загрузке изображения: $e')),
      );
    }
  }


  Future<void> _updateUserProfile(UserModel updatedUser) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final apiClient = ApiClient();
    apiClient.setAuthToken(authProvider.token!);

    try {
      final responseUser = await apiClient.updateUserProfile(updatedUser);
      await authProvider.setAuthData(
        user: responseUser,
        token: authProvider.token!,
      );
    } catch (e) {
      debugPrint('Ошибка обновления профиля: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка обновления профиля: $e')),
      );
    }
  }

  Future<void> _uploadAvatarToServer(File image) async {
    debugPrint('Начало загрузки аватарки на сервер...');
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('Аватар успешно загружен на сервер!');
  }
}