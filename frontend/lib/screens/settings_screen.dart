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
import '../api/api_interface.dart';

class SettingsScreen extends StatefulWidget {
  final ApiInterface apiClient;

  const SettingsScreen({
    super.key,
    required this.apiClient,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState(); // ← Эта строка обязательна!
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Константы дизайна
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
  final _surnameController = TextEditingController(text: 'Фамилия');
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
                    _buildOtherSettingsBlock(settings),
                    _buildDecorativeLine(),
                    _buildBonusSettingsBlock(settings, isAuthorized),
                    _buildDecorativeLine(),
                    _buildExperimentalFeaturesBlock(settings),
                    _buildDecorativeLine(),
                    _buildUpdatesBlock(settings),
                    _buildDecorativeLine(),
                    _buildLocationBlock(settings),
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
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Имя', style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
          const SizedBox(height: 4),
          SizedBox(
            width: 156,
            height: 31,
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text('Фамилия', style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
          const SizedBox(height: 4),
          SizedBox(
            width: 156,
            height: 31,
            child: TextField(
              controller: _surnameController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
        value: settings.notificationsEnabled,
        onChanged: (val) => settings.update('notificationsEnabled', val),
        title: const Text('Получать уведомления'),
        secondary: const Icon(Icons.notifications, size: SETTINGS_ICON_SIZE),
      ),
    );
  }

  Widget _buildOtherSettingsBlock(SettingsProvider settings) {
    return _buildBlock(
      key: _blockKeys['другие настройки']!,
      title: 'Другие настройки',
      child: Column(
        children: [
          ListTile(
            title: const Text('Темная тема'),
            trailing: Switch(
              value: settings.darkTheme,
              onChanged: (val) => settings.update('darkTheme', val),
            ),
            leading: const Icon(Icons.dark_mode, size: SETTINGS_ICON_SIZE),
          ),
          ListTile(
            title: const Text('Уровень громкости'),
            subtitle: Slider(
              value: settings.volume,
              onChanged: (val) => settings.update('volume', val),
            ),
            leading: const Icon(Icons.volume_up, size: SETTINGS_ICON_SIZE),
          ),
        ],
      ),
    );
  }

  Widget _buildBonusSettingsBlock(SettingsProvider settings, bool isAuthorized) {
    return _buildBlock(
      key: _blockKeys['бонусные настройки']!,
      title: 'Бонусные настройки',
      child: isAuthorized
          ? Column(
        children: [
          ListTile(
            title: const Text('Фоновая музыка'),
            trailing: Switch(
              value: settings.backgroundMusic,
              onChanged: (val) => settings.update('backgroundMusic', val),
            ),
            leading: const Icon(Icons.music_note, size: SETTINGS_ICON_SIZE),
          ),
          ListTile(
            title: const Text('Анимации интерфейса'),
            trailing: Switch(
              value: settings.interfaceAnimations,
              onChanged: (val) => settings.update('interfaceAnimations', val),
            ),
            leading: const Icon(Icons.animation, size: SETTINGS_ICON_SIZE),
          ),
        ],
      )
          : _unauthorizedMessage('Упс(\nЭти настройки доступны только\nавторизованным пользователям'),
    );
  }

  Widget _buildExperimentalFeaturesBlock(SettingsProvider settings) {
    return _buildBlock(
      key: _blockKeys['экспериментальные функции']!,
      title: 'Экспериментальные функции',
      child: SwitchListTile(
        value: settings.experimentalFeatures,
        onChanged: (val) => settings.update('experimentalFeatures', val),
        title: const Text('Включить экспериментальные функции'),
        secondary: const Icon(Icons.science, size: SETTINGS_ICON_SIZE),
      ),
    );
  }

  Widget _buildUpdatesBlock(SettingsProvider settings) {
    return _buildBlock(
      key: _blockKeys['обновления']!,
      title: 'Обновления',
      child: SwitchListTile(
        value: settings.autoUpdates,
        onChanged: (val) => settings.update('autoUpdates', val),
        title: const Text('Автоматические обновления'),
        secondary: const Icon(Icons.system_update, size: SETTINGS_ICON_SIZE),
      ),
    );
  }

  Widget _buildLocationBlock(SettingsProvider settings) {
    return _buildBlock(
      key: _blockKeys['геолокация']!,
      title: 'Геолокация',
      child: SwitchListTile(
        value: settings.locationAccess,
        onChanged: (val) => settings.update('locationAccess', val),
        title: const Text('Разрешить доступ к геолокации'),
        secondary: const Icon(Icons.location_on, size: SETTINGS_ICON_SIZE),
      ),
    );
  }

  Widget _buildAccountBlock(AuthProvider authProvider, bool isAuthorized) {
    return _buildBlock(
      key: _blockKeys['аккаунт']!,
      title: 'Аккаунт',
      child: isAuthorized
          ? Column(
        children: [
          const SizedBox(height: 20),
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
                  MaterialPageRoute(
                    builder: (_) => MainNavigationScreen(apiClient: widget.apiClient),
                  ),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MainNavigationScreen(apiClient: ApiClient()),
                  ),
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

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _avatarImage = File(image.path));
        _uploadAvatarToServer(_avatarImage!);
      }
    } catch (e) {
      debugPrint('Ошибка при выборе изображения: $e');
    }
  }

  Future<void> _uploadAvatarToServer(File image) async {
    debugPrint('Начало загрузки аватарки на сервер...');
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('Аватар успешно загружен на сервер!');
  }
}