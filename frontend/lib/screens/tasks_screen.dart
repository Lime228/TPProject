import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:zadachok/models/lobby/lobby_model.dart';
import 'package:zadachok/models/task/task_model.dart';
import 'package:zadachok/providers/shop_provider.dart';
import '../api/api_client.dart';
import '../models/user/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../providers/group_provider.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

const TextStyle _textStyleSemiBold = TextStyle(
  fontFamily: 'Inter',
  fontWeight: FontWeight.w600, // SemiBold
);

const TextStyle _textStyleBold = TextStyle(
  fontFamily: 'Inter',
  fontWeight: FontWeight.w700, // Bold
);

class TaskScreenStyles {
  // Responsive sizes based on screen dimensions
  static double cardElevation(BuildContext context) => 2.0;

  static EdgeInsets cardMargin(BuildContext context) => EdgeInsets.only(
    left: MediaQuery.of(context).size.width * 0.18,
    right: MediaQuery.of(context).size.width * 0.05,
  );

  static EdgeInsets cardPadding(BuildContext context) =>
      EdgeInsets.all(MediaQuery.of(context).size.width * 0.03);

  static double taskNameFontSize(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.045;

  static double dateFontSize(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.035;
  static const Color primaryColor = Color(0xFF937DF3);
  static const Color secondaryColor = Color(0xFF6E44FF);

  static double avatarRadius(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.07;

  static double headerHeight(BuildContext context) =>
      MediaQuery.of(context).size.height * 0.12;

  static double headerBottomRadius(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.1;

  static EdgeInsets headerPadding(BuildContext context) => EdgeInsets.fromLTRB(
    MediaQuery.of(context).size.width * 0.06,
    MediaQuery.of(context).size.height * 0.02,
    MediaQuery.of(context).size.width * 0.06,
    MediaQuery.of(context).size.height * 0.01,
  );

  static double searchBarHeight(BuildContext context) =>
      MediaQuery.of(context).size.height * 0.06;
  static const Color searchBarColor = Color(0xFFF5F5F5);
  static const Color sortButtonColor = Color(0xFF937DF3);

  static double searchSortWidth(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.9;

  // Shadows and borders
  static BoxShadow cardShadow(BuildContext context) => BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 6,
    offset: const Offset(0, 3),
  );

  static BorderRadius cardBorderRadius(BuildContext context) =>
      BorderRadius.circular(MediaQuery.of(context).size.width * 0.03);

  static BorderRadius headerBorderRadius(BuildContext context) =>
      BorderRadius.only(
        bottomLeft: Radius.circular(MediaQuery.of(context).size.width * 0.1),
        bottomRight: Radius.circular(MediaQuery.of(context).size.width * 0.1),
      );
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int? _selectedMemberId;
  late final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController();
  late final _descController = TextEditingController();
  late final _groupNameController = TextEditingController();
  late final _joinCodeController = TextEditingController();
  late final _rewardController = TextEditingController(text: '0');
  final _searchController = TextEditingController();

  DateTime? _editDeadline;

  bool _isLoading = false;
  DateTime? _deadline;
  bool _isFormVisible = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _refreshData() async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (groupProvider.isInGroup && authProvider.isAuthorized) {
      await taskProvider.refreshTasks();
    }
  }

  Future<void> _loadTasks() async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (groupProvider.isInGroup && authProvider.isAuthorized) {
      taskProvider.setUser(authProvider.user!);
      taskProvider.setLobbyId(groupProvider.lobbyId);
      await taskProvider.refreshTasks();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final groupProvider = Provider.of<GroupProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isAuthorized && groupProvider.isInGroup) {
      _loadTasks();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _groupNameController.dispose();
    _joinCodeController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  Future<DateTime?> _selectDeadline(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      _showError("Проверьте заполнение полей");
      return null;
    }

    // Получаем текущую дату и время
    DateTime initialDateTime =
        _deadline ?? DateTime.now().add(const Duration(days: 1));
    TimeOfDay initialTime = TimeOfDay.fromDateTime(initialDateTime);

    // Сначала выбираем дату
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(data: _datePickerTheme, child: child!);
      },
    );

    if (pickedDate == null) return null; // Пользователь отменил выбор даты

    // Затем выбираем время
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: _datePickerTheme.copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: TaskScreenStyles.primaryColor,
              hourMinuteColor: TaskScreenStyles.primaryColor.withOpacity(0.1),
              dayPeriodTextColor: TaskScreenStyles.primaryColor,
              dayPeriodColor: TaskScreenStyles.primaryColor.withOpacity(0.1),
              dialHandColor: TaskScreenStyles.primaryColor,
              dialBackgroundColor: TaskScreenStyles.primaryColor.withOpacity(
                0.1,
              ),
<<<<<<< HEAD
              hourMinuteTextStyle: _textStyleSemiBold.copyWith(
=======
              hourMinuteTextStyle: const TextStyle(
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );

    if (pickedTime != null && mounted) {
      // Комбинируем выбранную дату и время и возвращаем
      return DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    }
    return null;
  }

  Future<void> _initData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    if (authProvider.isAuthorized) {
      if (!groupProvider.isInGroup) {
        await groupProvider.loadGroupData();
      }

      if (groupProvider.isInGroup) {
        await _loadTasks();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);

    if (!authProvider.isAuthorized) {
      return _buildUnauthorizedView();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildProfileHeader(context),
          Expanded(child: _buildMainContent()),
        ],
      ),
      floatingActionButton: _buildAddTaskButton(),
    );
  }

  Widget _buildMainContent() {
    final groupProvider = Provider.of<GroupProvider>(context);

    return Column(
      children: [
        Expanded(
          child:
              groupProvider.isInGroup ? _buildTasksList() : _buildNoGroupView(),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);
    final groupProvider = Provider.of<GroupProvider>(context);

    return Container(
      width: double.infinity,
      height: TaskScreenStyles.headerHeight(context),
      decoration: BoxDecoration(
        color: TaskScreenStyles.primaryColor,
        borderRadius: TaskScreenStyles.headerBorderRadius(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: TaskScreenStyles.headerPadding(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: TaskScreenStyles.avatarRadius(context),
                backgroundColor: Colors.white,
                backgroundImage:
                    authProvider.user?.photoBytes != null &&
                            authProvider.user!.photoBytes!.isNotEmpty
                        ? MemoryImage(
                          base64Decode(authProvider.user!.photoBytes!),
                        )
                        : null,
                child:
                    authProvider.user?.photoBytes == null ||
                            authProvider.user!.photoBytes!.isEmpty
                        ? Icon(
                          Icons.person,
                          color: theme.colorScheme.secondary,
                          size: TaskScreenStyles.avatarRadius(context),
                        )
                        : null,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.03),
              Text(
                authProvider.user!.name ?? 'Гость',
                style: _textStyleBold.copyWith(
                  color: Colors.white,
                  fontSize: theme.textTheme.titleLarge?.fontSize,
                ),
              ),
            ],
          ),

          if (groupProvider.isInGroup)
            Theme(
              data: Theme.of(context).copyWith(
<<<<<<< HEAD
                popupMenuTheme: PopupMenuThemeData(
                  color: Colors.white,
                  textStyle: _textStyleBold.copyWith(color: Colors.black),
=======
                popupMenuTheme: const PopupMenuThemeData(
                  color: Colors.white,
                  textStyle: TextStyle(color: Colors.black),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                ),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
              ),
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0), // Скругление углов
                ),
<<<<<<< HEAD
                elevation: 4,
                // Тень
                color: Colors.white,
                // Фон меню
                onSelected: (value) => _handlePopupSelection(value, context),
                itemBuilder:
                    (context) => [
                      PopupMenuItem<String>(
                        value: 'info',
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: TaskScreenStyles.primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Информация о группе',
                              style: _textStyleSemiBold.copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      if (groupProvider
                          .isOwner) // Дополнительные пункты для админа
                        PopupMenuItem<String>(
                          value: 'manage',
                          child: Row(
                            children: [
                              Icon(
                                Icons.settings,
                                color: TaskScreenStyles.secondaryColor,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Управление группой',
                                style: _textStyleSemiBold.copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                    ],
              ),
=======
                elevation: 4, // Тень
                color: Colors.white, // Фон меню
                onSelected: (value) => _handlePopupSelection(value, context),
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'info',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: TaskScreenStyles.primaryColor),
                        const SizedBox(width: 12),
                        const Text(
                          'Информация о группе',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  if (groupProvider.isOwner) // Дополнительные пункты для админа
                    PopupMenuItem<String>(
                      value: 'manage',
                      child: Row(
                        children: [
                          Icon(Icons.settings, color: TaskScreenStyles.secondaryColor),
                          const SizedBox(width: 12),
                          const Text(
                            'Управление группой',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                ],
              )
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
            ),
        ],
      ),
    );
  }

  void _handlePopupSelection(String value, BuildContext context) {
    if (value == 'info') {
      _showGroupInfoDialog(context);
    }
    if (value == 'manage') {
      _showGroupManagementMenu(context);
    }
<<<<<<< HEAD
  }

=======

  }

>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
  Widget _buildUnauthorizedView() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: MediaQuery.of(context).size.width * 0.2,
                color: Colors.orange,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Text(
                'Доступ ограничен',
                style: _textStyleBold.copyWith(
                  fontSize: MediaQuery.of(context).size.width * 0.06,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Text(
                'Для работы с задачами необходимо авторизоваться',
                style: _textStyleSemiBold.copyWith(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                icon: Icon(
                  Icons.login,
                  size: MediaQuery.of(context).size.width * 0.05,
                ),
                label: Text(
                  'Войти в систему',
                  style: _textStyleBold.copyWith(
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.06,
                    vertical: MediaQuery.of(context).size.height * 0.015,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: Text(
                  'Ещё нет аккаунта? Зарегистрируйтесь',
                  style: _textStyleSemiBold.copyWith(
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoGroupView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group_add,
              size: MediaQuery.of(context).size.width * 0.2,
              color: TaskScreenStyles.primaryColor,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Text(
              'Задачи доступны только для участников групп',
              style: _textStyleBold.copyWith(
                fontSize: MediaQuery.of(context).size.width * 0.05,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Text(
              'Создайте новую группу или вступите в существующую, чтобы получить доступ к магазину',
              style: _textStyleSemiBold.copyWith(
                fontSize: MediaQuery.of(context).size.width * 0.04,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            ElevatedButton(
              onPressed: _showCreateGroupDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: TaskScreenStyles.primaryColor,
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.06,
                  vertical: MediaQuery.of(context).size.height * 0.015,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.width * 0.03,
                  ),
                ),
              ),
              child: Text(
                'Создать группу',
                style: _textStyleBold.copyWith(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            TextButton(
              onPressed: _showJoinGroupDialog,
              child: Text(
                'Вступить в существующую группу',
                style: _textStyleBold.copyWith(
                  color: TaskScreenStyles.primaryColor,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndSortBar() {
    return Container(
      width: TaskScreenStyles.searchSortWidth(context),
      height: MediaQuery.of(context).size.height * 0.04,
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.height * 0.04,
            decoration: BoxDecoration(
              color: TaskScreenStyles.sortButtonColor,
              borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width * 0.03,
              ),
            ),
            child: PopupMenuButton<String>(
              color: Colors.white,
              offset: const Offset(0, 30),
              onSelected: (value) {
                Provider.of<TaskProvider>(
                  context,
                  listen: false,
                ).sortTasks(option: value);
              },
              itemBuilder:
                  (context) => [
<<<<<<< HEAD
                     PopupMenuItem<String>(
                      value: 'date',
                      child: Text('По дате окончания', style: _textStyleSemiBold),
                    ),
                     PopupMenuItem<String>(
                      value: 'completed',
                      child: Text('Только выполненные', style: _textStyleSemiBold),
                    ),
                     PopupMenuItem<String>(
                      value: 'pending',
                      child: Text('Только невыполненные', style: _textStyleSemiBold),
                    ),
                     PopupMenuItem<String>(
                      value: 'default',
                      child: Text('Обычная сортировка', style: _textStyleSemiBold),
=======
                    const PopupMenuItem<String>(
                      value: 'date',
                      child: Text('По дате окончания'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'completed',
                      child: Text('Только выполненные'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'pending',
                      child: Text('Только невыполненные'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'default',
                      child: Text('Обычная сортировка'),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                    ),
                  ],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sort,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.width * 0.04,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                  Text(
                    'Сортировка',
                    style: _textStyleSemiBold.copyWith(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.04,
              decoration: BoxDecoration(
                color: const Color(0xFFC1FFEB),
                borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.width * 0.03,
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: TaskScreenStyles.primaryColor,
                    size: MediaQuery.of(context).size.width * 0.04,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: _textStyleSemiBold.copyWith(
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                        color: TaskScreenStyles.primaryColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Поиск задач...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        Provider.of<TaskProvider>(
                          context,
                          listen: false,
                        ).searchTasks(value);
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey[600],
                      size: MediaQuery.of(context).size.width * 0.04,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      Provider.of<TaskProvider>(
                        context,
                        listen: false,
                      ).resetFilters();
                      FocusScope.of(context).unfocus();
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

  Widget _buildTasksList() {
    return Column(
      children: [
        Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            return taskProvider.filteredTasks.isNotEmpty
                ? _buildSearchAndSortBar()
                : const SizedBox.shrink();
          },
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                final authProvider = Provider.of<AuthProvider>(context);
                final isAdmin = authProvider.user?.role.isAdmin ?? false;

                final tasksToShow =
                    isAdmin
                        ? taskProvider.filteredTasks
                        : taskProvider.filteredTasks
                            .where(
                              (task) =>
                                  task.customerId == authProvider.user?.id,
                            )
                            .toList();

                if (tasksToShow.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.task_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
<<<<<<< HEAD
                        Text(
                          'Нет задач',
                          style: _textStyleSemiBold.copyWith(fontSize: 18, color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: _refreshData,
                          child: const Text('Обновить', style: _textStyleBold),
=======
                        const Text(
                          'Нет задач',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: _refreshData,
                          child: const Text('Обновить'),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.01,
                  ),
                  itemCount: tasksToShow.length,
                  itemBuilder: (ctx, i) => _buildTaskCard(tasksToShow[i]),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    final theme = Theme.of(context);
    final startPoint = _safeParseDate(task.startPoint);
    final endPoint = _safeParseDate(task.endPoint);
    final isOverdue = endPoint != null && endPoint.isBefore(DateTime.now());
    final groupProvider = Provider.of<GroupProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context);

    final assignedUser = groupProvider.members.firstWhere(
      (user) => user.id == task.customerId,
      orElse:
          () => UserModel(id: 0, name: 'Не назначено', email: '', login: ''),
    );

    Color borderColor;
    IconData? statusIcon;

    if (task.state == 2) {
      borderColor = Colors.green;
      statusIcon = Icons.check;
    } else if (task.state == 1) {
      borderColor = Colors.orange;
      statusIcon = Icons.error_outline;
    } else {
      borderColor = TaskScreenStyles.primaryColor;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.12,
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      child: Row(
        children: [
          // Complete task button
          InkWell(
            onTap: () => _completeTask(taskProvider, task.id),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.08,
              height: MediaQuery.of(context).size.width * 0.08,
              margin: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.03,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2),
              ),
              child:
                  statusIcon != null
                      ? Icon(
                        statusIcon,
                        size: MediaQuery.of(context).size.width * 0.05,
                        color: borderColor,
                      )
                      : null,
            ),
          ),
          // Task card content
          Expanded(
            child: InkWell(
              onTap: () => _showEditTaskDialog(task),
              borderRadius: TaskScreenStyles.cardBorderRadius(context),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: TaskScreenStyles.cardBorderRadius(context),
                      boxShadow: [TaskScreenStyles.cardShadow(context)],
                      color:
                          task.state == 2
                              ? const Color(0xFFD9FFF3)
                              : task.state == 1
                              ? const Color(0xFFFFF3E0)
                              : Colors.white,
                    ),
                  ),

                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: ClipPath(
                      clipper: _DiagonalClipper(),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: TaskScreenStyles.cardBorderRadius(
                            context,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              const Color(0xFFCCC1FF).withOpacity(0.7),
                              const Color(0xFF6E44FF),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6E44FF).withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: const Offset(-5, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width * 0.03,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                task.name,
<<<<<<< HEAD
                                style: _textStyleBold.copyWith(
                                  fontSize: TaskScreenStyles.taskNameFontSize(
                                    context,
                                  ),
=======
                                style: TextStyle(
                                  fontSize: TaskScreenStyles.taskNameFontSize(
                                    context,
                                  ),
                                  fontWeight: FontWeight.bold,
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                                  color: TaskScreenStyles.primaryColor,
                                  decoration:
                                      task.state == 'Completed'
                                          ? TextDecoration.lineThrough
                                          : null,
                                ),
                              ),
                              if (task.description.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(
                                    top:
                                        MediaQuery.of(context).size.height *
                                        0.005,
                                  ),
                                  child: Text(
                                    task.description,
<<<<<<< HEAD
                                    style: _textStyleSemiBold.copyWith(
=======
                                    style: TextStyle(
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                                      fontSize: TaskScreenStyles.dateFontSize(
                                        context,
                                      ),
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              if (task.customerId != 0)
                                Padding(
                                  padding: EdgeInsets.only(
                                    top:
                                        MediaQuery.of(context).size.height *
                                        0.005,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                          0.02,
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                          0.003,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width *
                                            0.03,
                                      ),
                                    ),
                                    child: Text(
                                      'Для: ${groupProvider.members.firstWhere((m) => m.id == task.customerId, orElse: () => UserModel(id: 0, name: 'Неизвестно', email: '', login: '')).name}',
<<<<<<< HEAD
                                      style: _textStyleBold.copyWith(
=======
                                      style: TextStyle(
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                                        fontSize:
                                            TaskScreenStyles.dateFontSize(
                                              context,
                                            ) *
                                            0.8,
                                        color: TaskScreenStyles.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        Expanded(
                          flex: 3,
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (startPoint != null)
                                      Text(
                                        'С ${DateFormat('dd.MM').format(startPoint)}',
                                        style: _textStyleSemiBold.copyWith(
                                          fontSize: TaskScreenStyles.dateFontSize(context) * 0.9,
                                          color: Colors.white,
                                        ),
                                      ),
                                    if (endPoint != null)
                                      Text(
<<<<<<< HEAD
                                        'До ${DateFormat('dd.MM').format(endPoint)}',
                                        style: _textStyleBold.copyWith(
                                          fontSize:
                                              TaskScreenStyles.dateFontSize(
                                                context,
                                              ) *
                                              0.9,
=======
                                        'До ${DateFormat('dd.MM.yyyy HH:mm').format(endPoint)}',
                                        style: TextStyle(
                                          fontSize:
                                              TaskScreenStyles.dateFontSize(
                                                context,
                                              ),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                                          color:
                                              isOverdue
                                                  ? Colors.red[400]
                                                  : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
<<<<<<< HEAD
                                    Text(
                                      DateFormat('HH:mm').format(endPoint!),
                                      style: _textStyleBold.copyWith(
                                        fontSize:
                                            TaskScreenStyles.dateFontSize(
                                              context,
                                            ) *
                                            0.9,
                                        color:
                                            isOverdue
                                                ? Colors.red[400]
                                                : Colors.white,
                                        fontWeight: FontWeight.bold,
=======
                                    if (startPoint != null)
                                      Text(
                                        'С ${DateFormat('dd.MM.yyyy HH:mm').format(startPoint)}',
                                        style: TextStyle(
                                          fontSize:
                                              TaskScreenStyles.dateFontSize(
                                                context,
                                              ) *
                                              0.8,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (task.reward > 0)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: _buildRewardBadge(task.reward),
                                ),
                              if (task.state == 'Completed')
                                Positioned(
                                  bottom:
                                      MediaQuery.of(context).size.height *
                                      0.025,
                                  right: 0,
                                  child: Icon(
                                    Icons.verified,
                                    color: Colors.white,
                                    size:
                                        MediaQuery.of(context).size.width *
                                        0.04,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardBadge(int reward) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.015,
        vertical: MediaQuery.of(context).size.height * 0.002,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(
          MediaQuery.of(context).size.width * 0.025,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: MediaQuery.of(context).size.width * 0.04,
            color: Colors.amber,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.005),
          Text(
            reward.toStringAsFixed(reward.truncateToDouble() == reward ? 0 : 1),
            style: _textStyleBold.copyWith(
              fontSize: MediaQuery.of(context).size.width * 0.03,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String labelText, {String? hintText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: InputBorder.none,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }

  Widget _buildTaskForm() {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authProvider.user?.role.isAdmin ?? false;

    // Для обычных пользователей всегда устанавливаем их ID
    if (!isAdmin) {
      _selectedMemberId = authProvider.user?.id;
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Отмена',
                        style: _textStyleBold.copyWith(color: Colors.grey),
                      ),
                    ),
                    Text(
                      'Новая задача',
                      style: _textStyleBold.copyWith(
                        color: TaskScreenStyles.primaryColor,
                        fontSize: 18,
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : _validateAndAddTask,
                      child: Text(
                        'Готово',
                        style: _textStyleSemiBold.copyWith(
                          color: TaskScreenStyles.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildRoundedTextField(
                  controller: _titleController,
                  labelText: 'Название задачи',
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? 'Введите название задачи'
                              : null,
                ),
                const SizedBox(height: 16),

                _buildRoundedTextField(
                  controller: _descController,
                  labelText: 'Описание',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Показываем выбор участника только для админов
                if (isAdmin) ...[
                  Container(
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
                    child: DropdownButtonFormField<int>(
                      value: _selectedMemberId,
                      decoration: InputDecoration(
                        labelText: 'Назначить участнику',
                        hintText: 'Оставить для всех',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      items: [
                        DropdownMenuItem<int>(
                          value: null,
                          child: Text('Для всех участников', style: _textStyleSemiBold),
                        ),
                        ...groupProvider.members.map((member) {
                          return DropdownMenuItem<int>(
                            value: member.id,
                            child: Text(member.name, style: _textStyleSemiBold),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedMemberId = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildRoundedTextField(
                    controller: _rewardController,
                    labelText: 'Количество звёзд',
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Введите количество';
                      final num = double.tryParse(value);
                      if (num == null) return 'Введите число';
                      if (num < 0) return 'Число должно быть положительным';
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _deadline == null
                              ? 'Выберите дедлайн'
                              : 'Дедлайн: ${DateFormat('dd.MM.yyyy HH:mm').format(_deadline!)}',
<<<<<<< HEAD
                          style: _textStyleBold.copyWith(
=======
                          style: TextStyle(
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                            fontSize: 14,
                            color:
                                _deadline == null
                                    ? Colors.grey[600]
                                    : Colors.black,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final newDeadline = await _selectDeadline(context);
                          if (newDeadline != null) {
                            setState(() {
                              _deadline = newDeadline;
                            });
                          }
                        },
<<<<<<< HEAD
                        child: Text(
                          'Выбрать',
                          style: _textStyleBold.copyWith(
=======
                        child: const Text(
                          'Выбрать',
                          style: TextStyle(
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                            color: TaskScreenStyles.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
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

  Widget? _buildAddTaskButton() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final group = Provider.of<GroupProvider>(context, listen: false);

    if (!auth.isAuthorized || !group.isInGroup) return null;

    return FloatingActionButton(
      backgroundColor: TaskScreenStyles.primaryColor,
      onPressed: () => _showAddTaskDialog(),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  final ThemeData _datePickerTheme = ThemeData.light().copyWith(
    colorScheme: const ColorScheme.light(
      primary: TaskScreenStyles.primaryColor,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
    ),
    dialogBackgroundColor: Colors.white,
    dialogTheme: const DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
    ),
  );

  void _validateAndAddTask() {
    if (_formKey.currentState!.validate()) {
      _addTask();
    }
  }

  Future<void> _addTask() async {
    if (_formKey.currentState!.validate()) {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final customerId = _selectedMemberId ?? 0;

      // Получаем текущую дату и время с учетом часового пояса
      final now = DateTime.now();
      final currentDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute,
      );

      // Проверяем, что дедлайн установлен
      if (_deadline == null) {
        _showError("Пожалуйста, установите дедлайн");
        return;
      }

      final newTask = TaskModel(
        name: _titleController.text.trim(),
        description: _descController.text.trim(),
        endPoint: _deadline!.toIso8601String(),
        // Сохраняем дедлайн как UTC
        startPoint: currentDateTime.toIso8601String(),
        // Текущее время как UTC
        reward: int.tryParse(_rewardController.text) ?? 0,
        customerId: customerId,
        state: 0,
      );

      try {
        setState(() => _isLoading = true);
        final success = await Provider.of<TaskProvider>(
          context,
          listen: false,
        ).addTask(task: newTask, lobbyId: groupProvider.lobbyId);

        if (success && mounted) {
          _resetForm();
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) _showError("Ошибка: ${e.toString()}");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descController.clear();
    _rewardController.clear();
    setState(() {
      _deadline = null;
      _selectedMemberId = null;
      _isFormVisible = false;
    });
  }

  void _showAddTaskDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // важно для правильного отображения
      backgroundColor: Colors.transparent, // прозрачный фон
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom:
                  MediaQuery.of(
                    context,
                  ).viewInsets.bottom, // Учитываем клавиатуру
            ),
            child: _buildTaskForm(),
          ),
    );
  }

  Future<void> _completeTask(TaskProvider taskProvider, int taskId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    try {
      final task = taskProvider.tasks.firstWhere((t) => t.id == taskId);

      if (task.customerId != 0 &&
          task.customerId != authProvider.user?.id &&
          !authProvider.isAdmin) {
        _showError("Вы не можете выполнить эту задачу");
        return;
      }

      final newState =
          authProvider.isAdmin
              ? 2
              : 1; // Админ сразу подтверждает (2), пользователь - отмечает выполнение (1)
      final updatedTask = task.copyWith(state: newState);
      await taskProvider.updateTask(updatedTask);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.isAdmin
                  ? 'Задача подтверждена'
                  : 'Задача выполнена (ожидает подтверждения)',
<<<<<<< HEAD
              style: _textStyleBold,
=======
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError("Ошибка при завершении задачи: ${e.toString()}");
      }
    }
  }

  DateTime? _safeParseDate(String dateString) {
    try {
      if (dateString.isEmpty) return null;
      final date = DateTime.parse(dateString);
      return date.toLocal(); // Конвертируем UTC в локальное время
    } catch (e) {
      debugPrint('Ошибка парсинга даты: $e');
      return null;
    }
  }

<<<<<<< HEAD
=======
  void _showNonOwnerSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Только администратор может добавлять задачи'),
      ),
    );
  }

>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showGroupInfoDialog(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    if (!groupProvider.isInGroup) {
      _showError('Вы не состоите в группе');
      return;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Закрыть информацию о группе',
      // Добавлено обязательное поле
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
<<<<<<< HEAD
                      child: Text(
                        'Информация о группе',
                        style: _textStyleBold.copyWith(
=======
                      child: const Text(
                        'Информация о группе',
                        style: TextStyle(
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
<<<<<<< HEAD
                          Text('Код: ${groupProvider.groupCode}', style: _textStyleSemiBold),
=======
                          Text('Код: ${groupProvider.groupCode}'),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                          const SizedBox(height: 10),
                          Text(
                            groupProvider.isOwner
                                ? 'Вы администратор группы'
                                : 'Вы участник группы',
<<<<<<< HEAD
                            style: _textStyleBold.copyWith(
=======
                            style: TextStyle(
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                              color:
                                  groupProvider.isOwner
                                      ? Colors.green
                                      : Colors.blue,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed:
                                () => _handleLeaveGroup(ctx, groupProvider),
<<<<<<< HEAD
                            child: const Text('Выйти из группы', style: _textStyleSemiBold),
                          ),
                          if (groupProvider.isOwner) ...[
                            const SizedBox(width: 8),
=======
                            child: const Text('Выйти из группы'),
                          ),
                          if (groupProvider.isOwner) ...[
                            const SizedBox(width: 8),

>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                          ],
                          if (!groupProvider.isOwner) ...[
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _showGroupMembersDialog(context);
                              },
<<<<<<< HEAD
                              child: const Text('Участники группы', style: _textStyleBold),
=======
                              child: const Text('Участники группы'),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1.0),
            end: const Offset(0, 0),
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

  Future<void> _handleLeaveGroup(
    BuildContext ctx,
    GroupProvider groupProvider,
  ) async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
<<<<<<< HEAD
            title: const Text('Подтверждение', style: _textStyleBold,),
            content: const Text('Вы уверены, что хотите выйти из группы?', style: _textStyleSemiBold),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Отмена', style: _textStyleBold,),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child:  Text('Выйти', style: _textStyleBold.copyWith(color: Colors.red)),
=======
            title: const Text('Подтверждение'),
            content: const Text('Вы уверены, что хотите выйти из группы?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Выйти', style: TextStyle(color: Colors.red)),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
              ),
            ],
          ),
    );

    if (shouldLeave == true) {
      Navigator.pop(ctx);
      await groupProvider.leaveGroup();
      if (mounted) {
        _showError('Вы вышли из группы');
      }
    }
  }

  void _showGroupManagementMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Закрыть меню управления группой',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
<<<<<<< HEAD
                      child: Text(
                        'Управление группой',
                        style: _textStyleBold.copyWith(
=======
                      child: const Text(
                        'Управление группой',
                        style: TextStyle(
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.people,
                              color: TaskScreenStyles.primaryColor,
                            ),
<<<<<<< HEAD
                            title: const Text('Управление участниками', style: _textStyleSemiBold),
=======
                            title: const Text('Управление участниками'),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                            onTap: () {
                              Navigator.pop(ctx);
                              _showGroupMembersDialog(context);
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
<<<<<<< HEAD
                            title: const Text('Распустить группу', style: _textStyleSemiBold),
=======
                            title: const Text('Распустить группу'),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                            onTap: () {
                              Navigator.pop(ctx);
                              _confirmGroupDisband(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
<<<<<<< HEAD
                            child: const Text('Закрыть', style: _textStyleSemiBold),
=======
                            child: const Text('Закрыть'),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
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
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1.0),
            end: const Offset(0, 0),
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

<<<<<<< HEAD
=======
  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      leading: Icon(icon, color: color ?? Colors.blue[600]),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
  Future<void> _showGroupMembersDialog(BuildContext context) async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Показываем индикатор загрузки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await groupProvider.refreshGroupData();
      final currentMembers = groupProvider.members;
      Navigator.of(context).pop();

      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Закрыть список участников',
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (ctx, anim1, anim2) {
          return Align(
            alignment: Alignment.topCenter,
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
<<<<<<< HEAD
                        child:  Text(
                          'Участники группы',
                          style: _textStyleSemiBold.copyWith(
=======
                        child: const Text(
                          'Участники группы',
                          style: TextStyle(
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(16),
                          itemCount: currentMembers.length,
                          itemBuilder: (context, index) {
                            final member = currentMembers[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  radius: 20,
<<<<<<< HEAD
                                  child: Text(member.name[0], style: _textStyleSemiBold,),
                                ),
                                title: Text(
                                  member.name,
                                  style:  _textStyleBold.copyWith(fontSize: 14),
=======
                                  child: Text(member.name[0]),
                                ),
                                title: Text(
                                  member.name,
                                  style: const TextStyle(fontSize: 14),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                                ),
                                subtitle: Text(
                                  member.role.isAdmin
                                      ? 'Администратор'
                                      : 'Участник',
<<<<<<< HEAD
                                  style: _textStyleSemiBold.copyWith(
=======
                                  style: TextStyle(
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                                    fontSize: 12,
                                    color:
                                        member.role.isAdmin
                                            ? Colors.green
                                            : Colors.grey[600],
                                  ),
                                ),
                                trailing:
                                    groupProvider.isOwner &&
                                            !member.role.isAdmin &&
                                            member.id != authProvider.user?.id
                                        ? IconButton(
                                          icon: const Icon(
                                            Icons.delete,

                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed:
                                              () => _removeMember(
                                                ctx,
                                                groupProvider,
                                                member,
                                              ),
                                        )
                                        : null,
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
<<<<<<< HEAD
                              child: const Text('Закрыть', style: _textStyleSemiBold),
=======
                              child: const Text('Закрыть'),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
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
        },
        transitionBuilder: (ctx, anim1, anim2, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1.0),
              end: const Offset(0, 0),
            ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
            child: child,
          );
        },
      );
    } catch (e) {
      Navigator.of(context).pop();
      _showError('Ошибка загрузки участников: ${e.toString()}');
    }
  }

  Future<void> _removeMember(
    BuildContext ctx,
    GroupProvider groupProvider,
    UserModel member,
  ) async {
    try {
      // Используем API клиент через GroupProvider
      final apiClient = ApiClient();
      apiClient.setAuthToken(
        Provider.of<AuthProvider>(context, listen: false).token!,
      );

      await apiClient.lobbyRemoveUser(groupProvider.lobbyId, member.id);

      // Обновляем локальное состояние через публичные методы
      final updatedMembers =
          groupProvider.members.where((m) => m.id != member.id).toList();
      // Нужно добавить метод setMembers в GroupProvider или обновить другим способом
      // Например, через загрузку обновленных данных:
      await groupProvider.loadGroupData();

      Navigator.pop(ctx);
      _showError('${member.name} удален из группы');

      // Если удаляем себя - выходим из группы
      if (member.id == groupProvider.currentUser?.id) {
        await groupProvider.leaveGroup();
      }
    } catch (e) {
      _showError('Ошибка удаления участника: ${e.toString()}');
    }
  }

  void _confirmGroupDisband(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
<<<<<<< HEAD
            title: const Text('Распустить группу?', style: _textStyleBold),
            content: const Text(
              'Все участники будут удалены из группы. Это действие нельзя отменить.', style: _textStyleSemiBold
=======
            title: const Text('Распустить группу?'),
            content: const Text(
              'Все участники будут удалены из группы. Это действие нельзя отменить.',
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
<<<<<<< HEAD
                child: const Text('Отмена', style: _textStyleSemiBold),
=======
                child: const Text('Отмена'),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
              ),
              TextButton(
                onPressed: () async {
                  try {
                    // Используем метод disbandGroup, который уже содержит всю логику
                    await groupProvider.disbandGroup();

                    Navigator.pop(ctx);
                    _showError('Группа распущена');
                  } catch (e) {
                    _showError('Ошибка распускания группы: ${e.toString()}');
                  }
                },
<<<<<<< HEAD
                child: Text(
                  'Распустить',
                  style: _textStyleSemiBold.copyWith(color: Colors.red),
=======
                child: const Text(
                  'Распустить',
                  style: TextStyle(color: Colors.red),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                ),
              ),
            ],
          ),
    );
  }

  void _showCreateGroupDialog() {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    groupProvider.refreshGroupData();

    if (groupProvider.isInGroup) {
      ScaffoldMessenger.of(
        context,
<<<<<<< HEAD
      ).showSnackBar(const SnackBar(content: Text('Вы уже в группе', style: _textStyleSemiBold,)));
=======
      ).showSnackBar(const SnackBar(content: Text('Вы уже в группе')));
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
      return;
    }

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
<<<<<<< HEAD
            title: const Text("Создать новую группу", style: _textStyleBold),
            content: const Text(
              "Нажмите 'Создать' для генерации группы с уникальным кодом",
                style: _textStyleSemiBold
=======
            title: const Text("Создать новую группу"),
            content: const Text(
              "Нажмите 'Создать' для генерации группы с уникальным кодом",
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
<<<<<<< HEAD
                child: const Text("Отмена", style: _textStyleSemiBold),
=======
                child: const Text("Отмена"),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await groupProvider.createGroup();
                    await groupProvider.isInGroup;
                    await groupProvider.authProvider!.refreshAll(
                      groupProvider,
                      taskProvider,
                      shopProvider,
                    );
                    await groupProvider.authProvider!.refreshUserData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Группа создана! Код: ${groupProvider.groupCode}',
<<<<<<< HEAD
                            style: _textStyleSemiBold
=======
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                        ),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка: ${e.toString()}')),
                    );
                  }
                },
<<<<<<< HEAD
                child: const Text("Создать", style: _textStyleBold),
=======
                child: const Text("Создать"),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
              ),
            ],
          ),
    );
  }

  void _showJoinGroupDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
<<<<<<< HEAD
            title: const Text("Вступить в группу", style: _textStyleBold),
=======
            title: const Text("Вступить в группу"),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
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
<<<<<<< HEAD
                child: const Text("Отмена", style: _textStyleBold),
=======
                child: const Text("Отмена"),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
              ),
              TextButton(
                onPressed: () async {
                  final code = _joinCodeController.text.trim();
                  if (code.length != 6) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
<<<<<<< HEAD
                        content: Text("Код должен содержать 6 символов", style: _textStyleSemiBold),
=======
                        content: Text("Код должен содержать 6 символов"),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
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
<<<<<<< HEAD
                        content: Text("Вы успешно присоединились!", style: _textStyleSemiBold),
=======
                        content: Text("Вы успешно присоединились!"),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(ctx).showSnackBar(
<<<<<<< HEAD
                      const SnackBar(content: Text("Ошибка присоединения", style: _textStyleSemiBold)),
                    );
                  }
                },
                child: const Text("Присоединиться", style: _textStyleBold),
=======
                      const SnackBar(content: Text("Ошибка присоединения")),
                    );
                  }
                },
                child: const Text("Присоединиться"),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
              ),
            ],
          ),
    );
  }

  void _showEditTaskDialog(TaskModel task) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authProvider.user?.role.isAdmin ?? false;

    if (!isAdmin) {
      // Для обычного пользователя показываем только информацию о задаче
      _showTaskInfoDialog(task);
      return;
    }

    // Оригинальный код для админа
    final _editTitleController = TextEditingController(text: task.name);
    final _editDescController = TextEditingController(text: task.description);
    final _editRewardController = TextEditingController(
      text: task.reward.toString(),
    );
    DateTime? deadline = _safeParseDate(task.endPoint);
    int? selectedMemberId = task.customerId;
    final _editFormKey = GlobalKey<FormState>();
    bool isEditing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _editFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
<<<<<<< HEAD
                                child: Text(
                                  'Отмена',
                                  style: _textStyleBold.copyWith(color: Colors.grey),
                                ),
                              ),
                               Text(
                                'Редактировать задачу',
                                style: _textStyleBold.copyWith(
=======
                                child: const Text(
                                  'Отмена',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              const Text(
                                'Редактировать задачу',
                                style: TextStyle(
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                                  color: TaskScreenStyles.primaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed:
                                    isEditing
                                        ? null
                                        : () async {
                                          if (_editFormKey.currentState!
                                              .validate()) {
                                            setModalState(
                                              () => isEditing = true,
                                            );
                                            try {
                                              final updatedTask = task.copyWith(
                                                name:
                                                    _editTitleController.text
                                                        .trim(),
                                                description:
                                                    _editDescController.text
                                                        .trim(),
                                                reward:
                                                    int.tryParse(
                                                      _editRewardController
                                                          .text,
                                                    ) ??
                                                    task.reward,
                                                customerId: selectedMemberId,
                                                endPoint:
                                                    deadline
                                                        ?.toUtc()
                                                        .toIso8601String() ??
                                                    task.endPoint,
                                              );

                                              await Provider.of<TaskProvider>(
                                                context,
                                                listen: false,
                                              ).updateTask(updatedTask);

                                              if (mounted) {
                                                Navigator.of(context).pop();
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
<<<<<<< HEAD
                                                      'Задача обновлена', style: _textStyleBold,
=======
                                                      'Задача обновлена',
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                                                    ),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (mounted) {
                                                _showError(
                                                  'Ошибка обновления: ${e.toString()}',
                                                );
                                              }
                                            } finally {
                                              if (mounted) {
                                                setModalState(
                                                  () => isEditing = false,
                                                );
                                              }
                                            }
                                          }
                                        },
<<<<<<< HEAD
                                child: Text(
                                  'Сохранить',
                                  style: _textStyleBold.copyWith(
=======
                                child: const Text(
                                  'Сохранить',
                                  style: TextStyle(
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                                    color: TaskScreenStyles.primaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildRoundedTextField(
                            controller: _editTitleController,
                            labelText: 'Название задачи',
                            validator:
                                (value) =>
                                    value?.isEmpty ?? true
                                        ? 'Введите название задачи'
                                        : null,
                          ),
                          const SizedBox(height: 16),

                          _buildRoundedTextField(
                            controller: _editDescController,
                            labelText: 'Описание',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),

                          Container(
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
                            child: DropdownButtonFormField<int>(
                              value: selectedMemberId,
                              decoration: InputDecoration(
                                labelText: 'Назначить участнику',
                                hintText: 'Оставить для всех',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Color(0xFF937DF3),
                                    width: 2,
                                  ),
                                ),
                              ),
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              menuMaxHeight: 300,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF937DF3),
                              ),
<<<<<<< HEAD
                              style: _textStyleBold.copyWith(
=======
                              style: TextStyle(
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                                color: Colors.black,
                                fontSize: 16,
                              ),
                              items: [
                                DropdownMenuItem<int>(
                                  value: 0,
                                  child: Text(
                                    'Для всех участников',
<<<<<<< HEAD
                                    style: _textStyleSemiBold.copyWith(color: Colors.black),
=======
                                    style: TextStyle(color: Colors.black),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                                  ),
                                ),
                                ...Provider.of<GroupProvider>(
                                  context,
                                  listen: false,
                                ).members.map((member) {
                                  return DropdownMenuItem<int>(
                                    value: member.id,
                                    child: Text(
                                      member.name,
<<<<<<< HEAD
                                      style: _textStyleSemiBold.copyWith(color: Colors.black),
=======
                                      style: TextStyle(color: Colors.black),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                                    ),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                setModalState(() {
                                  selectedMemberId = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildRoundedTextField(
                            controller: _editRewardController,
                            labelText: 'Количество звёзд',
                            validator: (value) {
<<<<<<< HEAD
                              if (value == null || value.isEmpty) {
                                return 'Введите количество';
                              }
                              final num = double.tryParse(value);
                              if (num == null) return 'Введите число';
                              if (num < 0) {
                                return 'Число должно быть положительным';
                              }
=======
                              if (value == null || value.isEmpty)
                                return 'Введите количество';
                              final num = double.tryParse(value);
                              if (num == null) return 'Введите число';
                              if (num < 0)
                                return 'Число должно быть положительным';
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    deadline == null
                                        ? 'Выберите дедлайн'
                                        : 'Дедлайн: ${DateFormat('dd.MM.yyyy HH:mm').format(deadline!)}',
<<<<<<< HEAD
                                    style: _textStyleSemiBold.copyWith(
=======
                                    style: TextStyle(
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                                      fontSize: 14,
                                      color:
                                          deadline == null
                                              ? Colors.grey[600]
                                              : Colors.black,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final newDeadline = await _selectDeadline(
                                      context,
                                    );
                                    if (newDeadline != null) {
                                      setModalState(() {
                                        deadline = newDeadline;
                                      });
                                    }
                                  },
<<<<<<< HEAD
                                  child: Text(
                                    'Выбрать',
                                    style: _textStyleBold.copyWith(
=======
                                  child: const Text(
                                    'Выбрать',
                                    style: TextStyle(
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                                      color: TaskScreenStyles.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isEditing)
                            const Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showTaskInfoDialog(TaskModel task) {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final theme = Theme.of(context);
    final assignedUser = groupProvider.members.firstWhere(
      (user) => user.id == task.customerId,
      orElse:
          () => UserModel(id: 0, name: 'Не назначено', email: '', login: ''),
    );

    final startPoint = _safeParseDate(task.startPoint);
    final endPoint = _safeParseDate(task.endPoint);
    final isOverdue = endPoint != null && endPoint.isBefore(DateTime.now());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
<<<<<<< HEAD
                          child: Text(
                            'Закрыть',
                            style: _textStyleSemiBold.copyWith(color: Colors.grey),
=======
                          child: const Text(
                            'Закрыть',
                            style: TextStyle(color: Colors.grey),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                          ),
                        ),
                        Text(
                          'Информация о задаче',
<<<<<<< HEAD
                          style: _textStyleBold.copyWith(
=======
                          style: TextStyle(
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                            color: TaskScreenStyles.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 60), // Для выравнивания
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Название задачи
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[100],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        task.name,
<<<<<<< HEAD
                        style: _textStyleBold.copyWith(
=======
                        style: TextStyle(
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Описание
                    if (task.description.isNotEmpty) ...[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          task.description,
<<<<<<< HEAD
                          style: _textStyleSemiBold.copyWith(fontSize: 14),
=======
                          style: const TextStyle(fontSize: 14),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Назначено
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[100],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Назначено: ${assignedUser.name}',
<<<<<<< HEAD
                            style: _textStyleSemiBold.copyWith(fontSize: 14),
=======
                            style: const TextStyle(fontSize: 14),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Дедлайн
                    if (endPoint != null) ...[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isOverdue ? Colors.red[50] : Colors.grey[100],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 20,
                              color: isOverdue ? Colors.red : Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Дедлайн: ${DateFormat('dd.MM.yyyy HH:mm').format(endPoint)}',
<<<<<<< HEAD
                              style: _textStyleSemiBold.copyWith(
=======
                              style: TextStyle(
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                                fontSize: 14,
                                color: isOverdue ? Colors.red : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Награда
                    if (task.reward > 0) ...[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.amber[50],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 20, color: Colors.amber),
                            const SizedBox(width: 8),
                            Text(
                              'Награда: ${task.reward} звёзд',
<<<<<<< HEAD
                              style: _textStyleSemiBold.copyWith(fontSize: 14),
=======
                              style: const TextStyle(fontSize: 14),
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Статус
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color:
                            task.state == 2
                                ? Colors.green[50]
                                : task.state == 1
                                ? Colors.orange[50]
                                : Colors.blue[50],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            task.state == 2
                                ? Icons.check_circle_outline
                                : task.state == 1
                                ? Icons.hourglass_top
                                : Icons.access_time,
                            size: 20,
                            color:
                                task.state == 2
                                    ? Colors.green
                                    : task.state == 1
                                    ? Colors.orange
                                    : Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Статус: ${task.state == 2
                                ? 'Выполнено'
                                : task.state == 1
                                ? 'Ожидает подтверждения'
                                : 'В процессе'}',
<<<<<<< HEAD
                            style: _textStyleBold.copyWith(
=======
                            style: TextStyle(
>>>>>>> 1ff228d5ea909ee1302341b26d7a53116d30ba17
                              fontSize: 14,
                              color:
                                  task.state == 2
                                      ? Colors.green
                                      : task.state == 1
                                      ? Colors.orange
                                      : Colors.blue,
                            ),
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
      },
    );
  }
}

class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.3, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
