import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../routes/main_navigation.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(text: 'Имя');
  final TextEditingController _surnameController = TextEditingController(text: 'Фамилия');
  final ImagePicker _picker = ImagePicker();
  File? _avatarImage;



  final Map<String, int> _taskStatistics = {
    'Пн': 3,
    'Вт': 7,
    'Ср': 3,
    'Чт': 8,
    'Пт': 6,
    'Сб': 4,
    'Вс': 2,
  };

  final Map<String, GlobalKey<State<StatefulWidget>>> _blockKeys = {
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

  Widget _decorativeLine() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 20),
    child: Center(
      child: SizedBox(
        width: 250,
        height: 2,
        child: DecoratedBox(
          decoration: BoxDecoration(color: Color(0xFFCCC1FF)),
        ),
      ),
    ),
  );

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _avatarImage = File(image.path);
        });
        _uploadAvatarToServer(_avatarImage!);
      }
    } catch (e) {
      print('Ошибка при выборе изображения: $e');
    }
  }

  Future<void> _uploadAvatarToServer(File image) async {
    print('Начало загрузки аватарки на сервер...');
    await Future.delayed(const Duration(seconds: 1));
    print('Аватар успешно загружен на сервер!');
  }

  @override
  Widget build(BuildContext context) {

    final settings = Provider.of<SettingsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isAuthorized = authProvider.isAuthorized;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                    color: Color(0xFF6E44FF),
                  ),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () => _scrollToBlock(_searchController.text),
                  child: Container(
                    width: 352,
                    height: 27,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC1FFEB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Color(0xFF6E44FF), size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF6E44FF)),
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
                ),
                const SizedBox(height: 15),

                _buildBlock(
                  key: _blockKeys['личные данные']!,
                  title: 'Личные данные',
                  child: authProvider.isAuthorized
                      ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey,
                            backgroundImage: _avatarImage != null
                                ? FileImage(_avatarImage!)
                                : null,
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
                                  color: Color(0xFF6E44FF),
                                ),
                                child: const Icon(Icons.add, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 30),
                      Expanded(
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
                      ),
                    ],
                  )
                      : _unauthorizedMessage('Упс(\nЛичные данные можно просматривать\nтолько авторизовавшись'),
                ),

                _decorativeLine(),

                _buildBlock(
                  key: _blockKeys['статистика']!,
                  title: 'Статистика',
                  child: authProvider.isAuthorized
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
                                      color: const Color(0xFF6E44FF),
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
                ),

                _decorativeLine(),

                _buildBlock(
                  key: _blockKeys['уведомления']!,
                  title: 'Уведомления',
                  child: SwitchListTile(
                    value: settings.notificationsEnabled,
                    onChanged: (val) => settings.update('notificationsEnabled', val),
                    title: const Text('Получать уведомления'),
                  ),
                ),

                _decorativeLine(),

                _buildBlock(
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
                      ),
                      ListTile(
                        title: const Text('Уровень громкости'),
                        subtitle: Slider(
                          value: settings.volume,
                          onChanged: (val) => settings.update('volume', val),
                        ),
                      ),

                    ],
                  ),
                ),

                _decorativeLine(),

                _buildBlock(
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
                      ),
                      ListTile(
                        title: const Text('Анимации интерфейса'),
                        trailing: Switch(
                          value: settings.interfaceAnimations,
                          onChanged: (val) => settings.update('interfaceAnimations', val),
                        ),
                      ),

                    ],
                  )
                      : _unauthorizedMessage('Упс(\nЭти настройки доступны только\nавторизованным пользователям'),
                ),

                _decorativeLine(),

                _buildBlock(
                  key: _blockKeys['экспериментальные функции']!,
                  title: 'Экспериментальные функции',
                  child: SwitchListTile(
                    value: settings.experimentalFeatures,
                    onChanged: (val) => settings.update('experimentalFeatures', val),
                    title: const Text('Включить экспериментальные функции'),
                  ),

                ),

                _decorativeLine(),

                _buildBlock(
                  key: _blockKeys['обновления']!,
                  title: 'Обновления',
                  child: SwitchListTile(
                    value: settings.autoUpdates,
                    onChanged: (val) => settings.update('autoUpdates', val),
                    title: const Text('Автоматические обновления'),
                  ),

                ),

                _decorativeLine(),

                _buildBlock(
                  key: _blockKeys['геолокация']!,
                  title: 'Геолокация',
                  child: SwitchListTile(
                    value: settings.locationAccess,
                    onChanged: (val) => settings.update('locationAccess', val),
                    title: const Text('Разрешить доступ к геолокации'),
                  ),

                ),

                _decorativeLine(),

                _buildBlock(
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
                            Navigator.of(context).pushNamed('/login');
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _unauthorizedMessage(String text) {
    return Container(
      width: 352,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 17, color: Color(0xFF666666)),
        textAlign: TextAlign.center,
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
      width: 352,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6E44FF)),

          ),
        const SizedBox(height: 15),
          child,
          ],
    ),
    );
  }
}