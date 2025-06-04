import 'dart:convert';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
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
import '../services/notification_service.dart';

const TextStyle _textStyleSemiBold = TextStyle(
  fontFamily: 'Inter',
  fontWeight: FontWeight.w600, // SemiBold
);

const TextStyle _textStyleBold = TextStyle(
  fontFamily: 'Inter',
  fontWeight: FontWeight.w700, // Bold
);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _nameController = TextEditingController(text: 'Имя');
  final _birthDateController = TextEditingController(text: 'ДД.ММ.ГГГГ');
  final _picker = ImagePicker();
  String? _avatarBytes;


  double get blockWidth => MediaQuery.of(context).size.width * 0.9;
  double get blockPadding => MediaQuery.of(context).size.width * 0.04;
  double get blockBorderRadius => MediaQuery.of(context).size.width * 0.035;
  double get titleFontSize => MediaQuery.of(context).size.width * 0.065;
  double get avatarRadius => MediaQuery.of(context).size.width * 0.12;
  double get settingsIconSize => MediaQuery.of(context).size.width * 0.06;
  double get decorativeLineWidth => MediaQuery.of(context).size.width * 0.7;
  double get decorativeLineHeight => MediaQuery.of(context).size.height * 0.002;

  static const Color titleColor = Color(0xFF6E44FF);
  static const Color decorativeLineColor = Color(0xFFCCC1FF);

  final Map<String, GlobalKey> _blockKeys = {
    'личные данные': GlobalKey(),
    'статистика': GlobalKey(),
    'уведомления': GlobalKey(),
    'аккаунт': GlobalKey(),
  };

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
        message: message ?? 'Error occurred in SettingsScreen',
        errorDescription: AppMetricaErrorDescription(
          (error is Exception ? error : Exception(error.toString())) as StackTrace,
        ),
      );
    } catch (e) {
      debugPrint('Ошибка отправки ошибки в AppMetrica: $e');
    }
  }

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

      if (user.birthdayDate != null) {
        _birthDateController.text =
        '${user.birthdayDate!.day.toString().padLeft(2, '0')}.'
            '${user.birthdayDate!.month.toString().padLeft(2, '0')}.'
            '${user.birthdayDate!.year}';
      }

      await settingsProvider.loadSettings();
      if (user.photoBytes != null && user.photoBytes!.isNotEmpty) {
        setState(() => _avatarBytes = user.photoBytes);
        await settingsProvider.updateUserData(avatarBytes: user.photoBytes!);
      } else {
        setState(() => _avatarBytes = null);
        await settingsProvider.updateUserData(avatarBytes: '');
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
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Настройки',
                    style: _textStyleBold.copyWith(
                      fontSize: titleFontSize * 1.4,
                      color: const Color(0xFF937DF3),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  _buildSearchField(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  _buildPersonalDataBlock(authProvider, isAuthorized),
                  _buildDecorativeLine(),
                  _buildStatisticsBlock(authProvider, isAuthorized),
                  _buildDecorativeLine(),
                  _buildNotificationsBlock(authProvider, settings, isAuthorized),
                  _buildDecorativeLine(),
                  _buildAccountBlock(authProvider, isAuthorized),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return GestureDetector(
      onTap: () {
        _safeReportEvent('settings_search', attributes: {'query': _searchController.text});
        _scrollToBlock(_searchController.text);
      },
      child: Container(
        width: blockWidth,
        height: MediaQuery.of(context).size.height * 0.045,
        decoration: BoxDecoration(
          color: const Color(0xFFC1FFEB),
          borderRadius: BorderRadius.circular(blockBorderRadius),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.03,
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: titleColor,
              size: MediaQuery.of(context).size.width * 0.05,
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  color: titleColor,
                ),
                decoration: InputDecoration(
                  hintText: 'Поиск',
                  border: InputBorder.none,
                  isDense: true,
                  hintStyle: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                  ),
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
          SizedBox(width: MediaQuery.of(context).size.width * 0.07),
          _buildNameFields(),
        ],
      )
          : _unauthorizedMessage('Упс(\nЛичные данные можно просматривать\nтолько авторизовавшись'),
    );
  }

  Widget _buildAvatar() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;


    final avatar = (user != null && user.photoBytes != null && user.photoBytes!.isNotEmpty)
        ? user.photoBytes
        : null;

    return Stack(
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: Colors.grey[200],
          backgroundImage: avatar != null
              ? MemoryImage(base64Decode(avatar))
              : null,
          child: avatar == null
              ? Icon(
            Icons.person,
            size: avatarRadius * 0.8,
            color: Colors.grey[600],
          )
              : null,
        ),
        if (authProvider.isAuthorized)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                _safeReportEvent('settings_avatar_change');
                _pickImage();
              },
              child: Container(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.015),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF937DF3),
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.width * 0.05,
                ),
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
          Text(
            'Имя',
            style: _textStyleSemiBold.copyWith(
              fontSize: MediaQuery.of(context).size.width * 0.035,
              color: const Color(0xFF666666),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(blockBorderRadius),
              boxShadow:  [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: MediaQuery.of(context).size.width * 0.015,
                  offset: Offset(0, MediaQuery.of(context).size.height * 0.005),
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
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.04,
                  vertical: MediaQuery.of(context).size.height * 0.015,
                ),
                border: InputBorder.none,
                hintText: 'Введите имя',
                hintStyle: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
              ),
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.04,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Text(
            'Дата рождения',
            style: _textStyleSemiBold.copyWith(
              fontSize: MediaQuery.of(context).size.width * 0.035,
              color: const Color(0xFF666666),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(blockBorderRadius),
              boxShadow:  [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: MediaQuery.of(context).size.width * 0.015,
                  offset: Offset(0, MediaQuery.of(context).size.height * 0.005),
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
                      

                      if (month < 1 || month > 12) {
                        throw Exception('Неверный месяц');
                      }
                      

                      final daysInMonth = DateTime(year, month + 1, 0).day;
                      if (day < 1 || day > daysInMonth) {
                        throw Exception('Неверный день месяца');
                      }
                      
                      final newDate = DateTime(year, month, day);

                      debugPrint('User entered date: $value');
                      debugPrint('Parsed DateTime: $newDate');

                      final updatedUser = authProvider.user!.copyWith(birthdayDate: newDate);
                      await _updateUserProfile(updatedUser);

                      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
                      await settingsProvider.updateUserData(birthDate: value);
                    }
                  } catch (e) {
                    debugPrint('Ошибка формата даты: $e. Input: $value');
                  }
                }
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.04,
                  vertical: MediaQuery.of(context).size.height * 0.015,
                ),
                border: InputBorder.none,
                hintText: 'ДД.ММ.ГГГГ',
                hintStyle: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  color: Colors.grey[400],
                ),
              ),
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.04,
              ),
              keyboardType: TextInputType.datetime,
            ),
          ),
          if (authProvider.isAuthorized) ...[
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF937DF3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(blockBorderRadius),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.015,
                  ),
                ),
                onPressed: () {
                  _safeReportEvent('settings_save_changes');
                  _updateAllFields();
                },
                child: Text(
                  'Сохранить изменения',
                  style: _textStyleSemiBold.copyWith(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsBlock(AuthProvider authProvider, bool isAuthorized) {
    Map<String, int> _buildTaskStatistics() {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final stats = <String, int>{
        'Пн': 0, 'Вт': 0, 'Ср': 0, 'Чт': 0, 'Пт': 0, 'Сб': 0, 'Вс': 0,
      };

      if (authProvider.user == null) return stats;

      final completedTasks = taskProvider.tasks.where((task) =>
      task.state == 2 && task.customerId == authProvider.user!.id).toList();

      for (final task in completedTasks) {
        final endPoint = task.deadline;
        if (endPoint != null) {
          final dayName = _getDayOfWeekName(endPoint.weekday);
          stats[dayName] = (stats[dayName] ?? 0) + 1;
        }
      }

      return stats;
    }

    return _buildBlock(
      key: _blockKeys['статистика']!,
      title: 'Статистика',
      child: isAuthorized
          ? Column(
        children: [
          Text(
            'Количество выполненных заданий по дням',
            style: _textStyleSemiBold.copyWith(
              fontSize: MediaQuery.of(context).size.width * 0.04,
              color: const Color(0xFF666666),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.03,
              ),
              child: Consumer<TaskProvider>(
                builder: (context, taskProvider, child) {
                  final stats = _buildTaskStatistics();
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: stats.entries.map((entry) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.08,
                            height: entry.value * MediaQuery.of(context).size.height * 0.02,
                            decoration: BoxDecoration(
                              color: titleColor,
                              borderRadius: BorderRadius.circular(blockBorderRadius),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                          Text(
                            entry.key,
                            style: _textStyleSemiBold.copyWith(
                              fontSize: MediaQuery.of(context).size.width * 0.035,
                            ),
                          ),
                          Text(
                            entry.value.toString(),
                            style: _textStyleSemiBold.copyWith(
                              fontSize: MediaQuery.of(context).size.width * 0.035,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      )
          : _unauthorizedMessage('Упс(\nСтатистику можно просматривать\nтолько авторизовавшись'),
    );
  }

  Widget _buildNotificationsBlock(AuthProvider authProvider, SettingsProvider settings, bool isAuthorized) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final notificationService = NotificationService();

    return _buildBlock(
      key: _blockKeys['уведомления']!,
      title: 'Уведомления',
      child: Column(
        children: [
          SwitchListTile(
            value: settings.notificationsEnabled,
            onChanged: (val) {
              _safeReportEvent('settings_notifications_toggle', attributes: {'enabled': val});
              settings.update('notificationsEnabled', val);
              notificationService.setNotificationsEnabled(val);

              if (authProvider.token != null) {
                notificationService.setAuthToken(authProvider.token);
              }
            },
            title: Text('Получать уведомления'),
            activeColor: const Color(0xFF937DF3),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.06,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF937DF3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(blockBorderRadius),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                _safeReportEvent('settings_test_notification');
                if (authProvider.token == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Требуется авторизация'),
                      backgroundColor: const Color(0xFF937DF3),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),),
                  );
                  return;
                }

                final activeTasks = taskProvider.tasks.where((t) => t.state == 0).toList();
                if (activeTasks.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Нет активных задач!'),
                      backgroundColor: const Color(0xFF937DF3),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),),
                  );
                  return;
                }

                final task = activeTasks.last;
                await notificationService.showTaskNotification(task: task);
              },
              child: Text(
                'Отправить тестовое уведомление',
                style: _textStyleSemiBold.copyWith(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
              ),
            ),
          ),
        ],
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
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.06,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(blockBorderRadius),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: TextButton(
              onPressed: () async {
                _safeReportEvent('settings_refresh_data');
                try {

                  await authProvider.refreshUserData();
                  

                  try {
                    await groupProvider.loadGroupData();
                    if (groupProvider.isInGroup) {
                      await Future.wait([
                        groupProvider.refreshGroupData(),
                        taskProvider.refreshTasks(),
                        shopProvider.refreshProducts(),
                      ]);
                    }
                  } catch (e) {
                    debugPrint('Некритичная ошибка при обновлении дополнительных данных: $e');
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Данные успешно обновлены',
                        style: _textStyleSemiBold,
                      ),
                      backgroundColor: const Color(0xFF937DF3),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Ошибка обновления данных пользователя',
                        style: _textStyleSemiBold,
                      ),
                      backgroundColor: const Color(0xFF937DF3),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
              child: Text(
                'Обновить данные',
                style: _textStyleBold.copyWith(
                  color: Colors.blue,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.015),
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.06,
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(blockBorderRadius),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: TextButton(
              onPressed: () {
                _safeReportEvent('settings_logout');
                authProvider.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                      (route) => false,
                );
              },
              child: Text(
                'Выйти из аккаунта',
                style: _textStyleBold.copyWith(
                  color: Colors.red,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.015),
          Text(
            'После выхода потребуется повторная авторизация',
            style: _textStyleSemiBold.copyWith(
              color: Colors.grey,
              fontSize: MediaQuery.of(context).size.width * 0.03,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      )
          : Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.06,
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(blockBorderRadius),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: TextButton(
              onPressed: () {
                _safeReportEvent('settings_login_prompt');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                );
              },
              child: Text(
                'Войти в аккаунт',
                style: _textStyleBold.copyWith(
                  color: Colors.green,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.015),
          Text(
            'Авторизуйтесь для доступа ко всем функциям',
            style: _textStyleSemiBold.copyWith(
              color: Colors.grey,
              fontSize: MediaQuery.of(context).size.width * 0.03,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeLine() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.03),
      child: Center(
        child: SizedBox(
          width: decorativeLineWidth,
          height: decorativeLineHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(color: decorativeLineColor),
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
      width: blockWidth,
      padding: EdgeInsets.all(blockPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(blockBorderRadius),
        boxShadow:  [
          BoxShadow(
            color: Colors.black12,
            blurRadius: MediaQuery.of(context).size.width * 0.015,
            offset: Offset(0, MediaQuery.of(context).size.height * 0.005),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: _textStyleBold.copyWith(
              fontSize: titleFontSize,
              color: const Color(0xFF937DF3),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          child,
        ],
      ),
    );
  }

  Widget _unauthorizedMessage(String text) {
    return Container(
      width: blockWidth,
      alignment: Alignment.center,
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
      child: Text(
        text,
        style: _textStyleSemiBold.copyWith(
          fontSize: MediaQuery.of(context).size.width * 0.04,
          color: const Color(0xFF666666),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getDayOfWeekName(int weekday) {
    switch (weekday) {
      case 1: return 'Пн';
      case 2: return 'Вт';
      case 3: return 'Ср';
      case 4: return 'Чт';
      case 5: return 'Пт';
      case 6: return 'Сб';
      case 7: return 'Вс';
      default: return '';
    }
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
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);

        setState(() => _avatarBytes = base64Image);

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        if (authProvider.isAuthorized && authProvider.token != null && authProvider.user != null) {
          try {
            await authProvider.updateUserPhoto(base64Image);
            await settingsProvider.updateUserData(avatarBytes: base64Image);


            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Аватар успешно обновлен', style: _textStyleSemiBold),
                backgroundColor: const Color(0xFF937DF3),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } catch (e) {
            debugPrint('Ошибка при обновлении аватара: $e');

            setState(() => _avatarBytes = authProvider.user?.photoBytes);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка при обновлении аватара', style: _textStyleSemiBold),
                backgroundColor: const Color(0xFF937DF3),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        } else {
          setState(() => _avatarBytes = null);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Требуется авторизация', style: _textStyleSemiBold),
              backgroundColor: const Color(0xFF937DF3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Ошибка при выборе изображения: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при загрузке изображения: ${e.toString()}', style: _textStyleSemiBold),
          backgroundColor: const Color(0xFF937DF3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _updateUserProfile(UserModel updatedUser) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.token == null) {
      debugPrint('Токен авторизации отсутствует');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Требуется авторизация', style: _textStyleSemiBold),
          backgroundColor: const Color(0xFF937DF3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

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
        SnackBar(content: Text('Ошибка обновления профиля', style: _textStyleSemiBold),
          backgroundColor: const Color(0xFF937DF3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      rethrow;
    }
  }

  Future<void> _updateAllFields() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthorized || authProvider.user == null) return;

    try {
      DateTime? birthDate;
      final dateText = _birthDateController.text.trim();
      
      debugPrint('=== Обновление данных пользователя ===');
      debugPrint('Обработка даты рождения: $dateText');
      
      if (dateText.isEmpty) {
        debugPrint('Дата рождения не указана');
      } else {
        try {
          final dateParts = dateText.split('.');
          if (dateParts.length == 3) {
            final day = int.parse(dateParts[0]);
            final month = int.parse(dateParts[1]);
            final year = int.parse(dateParts[2]);
            

            if (month < 1 || month > 12) {
              throw Exception('Неверный месяц');
            }
            

            final daysInMonth = DateTime(year, month + 1, 0).day;
            if (day < 1 || day > daysInMonth) {
              throw Exception('Неверный день месяца');
            }
            
            birthDate = DateTime(year, month, day);
            debugPrint('Дата успешно преобразована в DateTime: $birthDate');
            debugPrint('Дата в ISO8601: ${birthDate.toIso8601String()}');
          } else {
            throw Exception('Неверный формат даты');
          }
        } catch (e) {
          debugPrint('Ошибка парсинга даты: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Неверный формат даты. Используйте ДД.ММ.ГГГГ'),
              backgroundColor: const Color(0xFF937DF3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          return;
        }
      }

      final updatedUser = authProvider.user!.copyWith(
        name: _nameController.text,
        birthdayDate: birthDate,
      );

      debugPrint('Отправка обновленных данных пользователя:');
      debugPrint('- Имя: ${updatedUser.name}');
      debugPrint('- Дата рождения: ${updatedUser.birthdayDate}');
      debugPrint('- Дата рождения в ISO8601: ${updatedUser.birthdayDate?.toIso8601String()}');

      await _updateUserProfile(updatedUser);

      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      await settingsProvider.updateUserData(
        name: _nameController.text,
        birthDate: _birthDateController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Данные успешно сохранены', style: _textStyleSemiBold),
          backgroundColor: const Color(0xFF937DF3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),),
      );
    } catch (e) {
      debugPrint('Ошибка сохранения данных: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сохранения: $e', style: _textStyleSemiBold),
          backgroundColor: const Color(0xFF937DF3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),),
      );
    }
  }
}