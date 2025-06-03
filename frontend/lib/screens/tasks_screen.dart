import 'dart:convert';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
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

  static const Color dialogBackgroundColor = Colors.white;
  static const Color dialogPrimaryColor = Color(0xFF937DF3);
  static const Color dialogSecondaryColor = Color(0xFF6E44FF);
  static const Color dialogErrorColor = Color(0xFFE57373);
  static const Color dialogSuccessColor = Color(0xFF81C784);
  static const double dialogBorderRadius = 16.0;
  static const EdgeInsets dialogPadding = EdgeInsets.all(24.0);
  static const EdgeInsets dialogContentPadding = EdgeInsets.symmetric(vertical: 16);

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
  bool _isInitialized = false;
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
        message: message ?? 'Error occurred in TasksScreen',
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
    _safeReportEvent('tasks_screen_open');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _isInitialized = true;
        _initData();
      }
    });
  }

  Future<void> _initData() async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    await groupProvider.refreshGroupData(); // Вызовется один раз
  }

  Future<void> _refreshData() async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (groupProvider.isInGroup && authProvider.isAuthorized) {
      await taskProvider.refreshTasks();
      await groupProvider.refreshGroupData();
    }
  }

  Future<void> _loadTasks() async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (groupProvider.isInGroup && authProvider.isAuthorized) {
      taskProvider.setUser(authProvider.user!);
      taskProvider.setLobbyId(groupProvider.lobbyId);
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
              hourMinuteTextStyle: _textStyleSemiBold.copyWith(
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
                popupMenuTheme: PopupMenuThemeData(
                  color: Colors.white,
                  textStyle: _textStyleBold.copyWith(color: Colors.black),
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
  }

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
                        Text(
                          'Нет задач',
                          style: _textStyleSemiBold.copyWith(fontSize: 18, color: Colors.grey),
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
                                style: _textStyleBold.copyWith(
                                  fontSize: TaskScreenStyles.taskNameFontSize(
                                    context,
                                  ),
                                  color: TaskScreenStyles.primaryColor,
                                  decoration:
                                      task.state == 'Completed'
                                          ? TextDecoration.lineThrough
                                          : null,
                                ),
                              ),
                              // if (task.description.isNotEmpty)
                              //   Padding(
                              //     padding: EdgeInsets.only(
                              //       top:
                              //           MediaQuery.of(context).size.height *
                              //           0.005,
                              //     ),
                              //     child: Text(
                              //       task.description,
                              //       style: _textStyleSemiBold.copyWith(
                              //         fontSize: TaskScreenStyles.dateFontSize(
                              //           context,
                              //         ),
                              //         color: Colors.grey[700],
                              //       ),
                              //       maxLines: 2,
                              //       overflow: TextOverflow.ellipsis,
                              //     ),
                              //   ),
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
                                      style: _textStyleBold.copyWith(
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
                                        'До ${DateFormat('dd.MM').format(endPoint)}',
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
                                        ),
                                      ),
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
                          style: _textStyleBold.copyWith(
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
                        child: Text(
                          'Выбрать',
                          style: _textStyleBold.copyWith(
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
      await _safeReportEvent('task_add_attempt');
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

      await _safeReportEvent('task_add_success');

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
    await _safeReportEvent('task_complete_attempt');
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
      await _safeReportEvent('task_complete_success');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.isAdmin
                  ? 'Задача подтверждена'
                  : 'Задача выполнена (ожидает подтверждения)',
              style: _textStyleBold,
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
                      child: Text(
                        'Информация о группе',
                        style: _textStyleBold.copyWith(
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
                          Text('Код: ${groupProvider.groupCode}', style: _textStyleSemiBold),
                          const SizedBox(height: 10),
                          Text(
                            groupProvider.isOwner
                                ? 'Вы администратор группы'
                                : 'Вы участник группы',
                            style: _textStyleBold.copyWith(
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
                            child: const Text('Выйти из группы', style: _textStyleSemiBold),
                          ),
                          if (groupProvider.isOwner) ...[
                            const SizedBox(width: 8),
                          ],
                          if (!groupProvider.isOwner) ...[
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _showGroupMembersDialog(context);
                              },
                              child: const Text('Участники группы', style: _textStyleBold),
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
    _safeReportEvent('group_leave_attempt');
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
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
                      child: Text(
                        'Управление группой',
                        style: _textStyleBold.copyWith(
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
                            title: const Text('Управление участниками', style: _textStyleSemiBold),
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
                            title: const Text('Распустить группу', style: _textStyleSemiBold),
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
                            child: const Text('Закрыть', style: _textStyleSemiBold),
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

  Future<void> _showGroupMembersDialog(BuildContext context) async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

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
                        child: Text(
                          'Участники группы',
                          style: _textStyleSemiBold.copyWith(
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
                                  backgroundColor: Colors.white,
                                  backgroundImage: member.photoBytes != null
                                      ? MemoryImage(base64Decode(member.photoBytes!))
                                      : null,
                                  child: member.photoBytes == null
                                      ? Text(
                                    member.name.isNotEmpty ? member.name[0] : '',
                                    style: _textStyleSemiBold,
                                  )
                                      : null,
                                ),
                                title: Text(
                                  member.name,
                                  style: _textStyleBold.copyWith(fontSize: 14),
                                ),
                                subtitle: Text(
                                  member.role.isAdmin
                                      ? 'Администратор'
                                      : 'Участник',
                                  style: _textStyleSemiBold.copyWith(
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
                              child: const Text('Закрыть', style: _textStyleSemiBold),
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
            title: const Text('Распустить группу?', style: _textStyleBold),
            content: const Text(
              'Все участники будут удалены из группы. Это действие нельзя отменить.', style: _textStyleSemiBold
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Отмена', style: _textStyleSemiBold),
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
                child: Text(
                  'Распустить',
                  style: _textStyleSemiBold.copyWith(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showCreateGroupDialog() {
    _safeReportEvent('group_create_dialog_open');
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    if (groupProvider.isInGroup) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Вы уже в группе', style: _textStyleSemiBold))
      );
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
              borderRadius: BorderRadius.circular(TaskScreenStyles.dialogBorderRadius),
            ),
            elevation: 8,
            backgroundColor: TaskScreenStyles.dialogBackgroundColor,
            child: Padding(
              padding: TaskScreenStyles.dialogPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Создать группу',
                        style: _textStyleBold.copyWith(
                          fontSize: 20,
                          color: TaskScreenStyles.dialogPrimaryColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey),
                        onPressed: _isCreating ? null : () {
                          _safeReportEvent('group_create_cancel');
                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),

                  Padding(
                    padding: TaskScreenStyles.dialogContentPadding,
                    child: Column(
                      children: [
                        Icon(
                          Icons.group_add,
                          size: 64,
                          color: TaskScreenStyles.dialogPrimaryColor,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Вы создаёте новую группу',
                          style: _textStyleSemiBold.copyWith(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'После создания вы получите уникальный код для приглашения участников',
                          style: _textStyleSemiBold.copyWith(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  if (_isCreating)
                    Center(child: CircularProgressIndicator())
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: TaskScreenStyles.dialogPrimaryColor,
                              ),
                            ),
                            onPressed: () {
                              _safeReportEvent('group_create_cancel');
                              Navigator.pop(ctx);
                            },
                            child: Text(
                              'Отмена',
                              style: _textStyleSemiBold.copyWith(
                                color: TaskScreenStyles.dialogPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TaskScreenStyles.dialogPrimaryColor,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              _safeReportEvent('group_create_confirm');
                              setState(() => _isCreating = true);
                              try {
                                await groupProvider.createGroup();
                                if (mounted) {
                                  Navigator.pop(ctx);
                                  _showGroupCreatedDialog(groupProvider.groupCode);
                                }
                              } catch (e) {
                                if (mounted) {
                                  setState(() => _isCreating = false);
                                  _showError('Ошибка создания группы: ${e.toString()}');
                                }
                              }
                            },
                            child: Text(
                              'Создать',
                              style: _textStyleBold.copyWith(
                                color: Colors.white,
                              ),
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

// Добавьте этот метод для показа диалога после создания группы
  void _showGroupCreatedDialog(String? groupCode) {
    if (groupCode == null) {
      _showError('Не удалось получить код группы');
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TaskScreenStyles.dialogBorderRadius),
        ),
        elevation: 8,
        backgroundColor: TaskScreenStyles.dialogBackgroundColor,
        child: Padding(
          padding: TaskScreenStyles.dialogPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: TaskScreenStyles.dialogSuccessColor,
              ),
              SizedBox(height: 16),
              Text(
                'Группа создана!',
                style: _textStyleBold.copyWith(
                  fontSize: 20,
                  color: TaskScreenStyles.dialogPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Код для приглашения:',
                style: _textStyleSemiBold.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: TaskScreenStyles.dialogPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  groupCode,
                  style: _textStyleBold.copyWith(
                    fontSize: 24,
                    color: TaskScreenStyles.dialogPrimaryColor,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Поделитесь этим кодом с участниками, чтобы они могли присоединиться',
                style: _textStyleSemiBold.copyWith(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TaskScreenStyles.dialogPrimaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _safeReportEvent('group_created_dialog_close');
                  Navigator.pop(ctx);
                  // Копируем код в буфер обмена
                  Clipboard.setData(ClipboardData(text: groupCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Код скопирован в буфер обмена', style: _textStyleSemiBold))
                  );
                },
                child: Text(
                  'Скопировать код',
                  style: _textStyleBold.copyWith(
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

// Обновите метод _showJoinGroupDialog в tasks_screen.dart
  void _showJoinGroupDialog() {
    _safeReportEvent('group_join_dialog_open');
    bool _isJoining = false;
    String? _errorText;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TaskScreenStyles.dialogBorderRadius),
            ),
            elevation: 8,
            backgroundColor: TaskScreenStyles.dialogBackgroundColor,
            child: Padding(
              padding: TaskScreenStyles.dialogPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Присоединиться к группе',
                        style: _textStyleBold.copyWith(
                          fontSize: 20,
                          color: TaskScreenStyles.dialogPrimaryColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey),
                        onPressed: _isJoining ? null : () {
                          _safeReportEvent('group_join_cancel');
                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),

                  Padding(
                    padding: TaskScreenStyles.dialogContentPadding,
                    child: Column(
                      children: [
                        Icon(
                          Icons.group,
                          size: 64,
                          color: TaskScreenStyles.dialogPrimaryColor,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Введите код группы',
                          style: _textStyleSemiBold.copyWith(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Попросите код у администратора группы',
                          style: _textStyleSemiBold.copyWith(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  TextField(
                    controller: _joinCodeController,
                    decoration: InputDecoration(
                      labelText: 'Код группы',
                      hintText: 'Введите 6-значный код',
                      errorText: _errorText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _errorText != null
                              ? TaskScreenStyles.dialogErrorColor
                              : Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: TaskScreenStyles.dialogPrimaryColor,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    maxLength: 6,
                    textCapitalization: TextCapitalization.characters,
                    style: _textStyleSemiBold.copyWith(
                      letterSpacing: 2,
                    ),
                    onChanged: (value) {
                      if (_errorText != null) {
                        setState(() => _errorText = null);
                      }
                    },
                  ),

                  SizedBox(height: 8),

                  if (_isJoining)
                    Center(child: CircularProgressIndicator())
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: TaskScreenStyles.dialogPrimaryColor,
                              ),
                            ),
                            onPressed: () {
                              _safeReportEvent('group_join_cancel');
                              Navigator.pop(ctx);
                            },
                            child: Text(
                              'Отмена',
                              style: _textStyleSemiBold.copyWith(
                                color: TaskScreenStyles.dialogPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TaskScreenStyles.dialogPrimaryColor,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              final code = _joinCodeController.text.trim();
                              if (code.length != 6) {
                                setState(() {
                                  _errorText = 'Код должен содержать 6 символов';
                                });
                                return;
                              }

                              _safeReportEvent('group_join_attempt');
                              setState(() => _isJoining = true);

                              try {
                                final success = await Provider.of<GroupProvider>(
                                  context,
                                  listen: false,
                                ).joinGroup(code);

                                if (success && mounted) {
                                  _safeReportEvent('group_join_success');
                                  Navigator.pop(ctx);
                                  _showJoinSuccessDialog();
                                } else {
                                  setState(() {
                                    _errorText = 'Неверный код группы';
                                    _isJoining = false;
                                  });
                                }
                              } catch (e) {
                                if (mounted) {
                                  setState(() {
                                    _errorText = 'Ошибка: ${e.toString()}';
                                    _isJoining = false;
                                  });
                                }
                              }
                            },
                            child: Text(
                              'Присоединиться',
                              style: _textStyleBold.copyWith(
                                color: Colors.white,
                              ),
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

// Добавьте этот метод для показа диалога после успешного присоединения
  void _showJoinSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TaskScreenStyles.dialogBorderRadius),
        ),
        elevation: 8,
        backgroundColor: TaskScreenStyles.dialogBackgroundColor,
        child: Padding(
          padding: TaskScreenStyles.dialogPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: TaskScreenStyles.dialogSuccessColor,
              ),
              SizedBox(height: 16),
              Text(
                'Вы успешно присоединились!',
                style: _textStyleBold.copyWith(
                  fontSize: 20,
                  color: TaskScreenStyles.dialogPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Теперь вы можете участвовать в задачах группы и использовать магазин',
                style: _textStyleSemiBold.copyWith(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TaskScreenStyles.dialogPrimaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _safeReportEvent('group_join_success_close');
                  Navigator.pop(ctx);
                },
                child: Text(
                  'Продолжить',
                  style: _textStyleBold.copyWith(
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

  void _showEditTaskDialog(TaskModel task) {
    _safeReportEvent('task_edit_dialog_open');
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
                                child: Text(
                                  'Отмена',
                                  style: _textStyleBold.copyWith(color: Colors.grey),
                                ),
                              ),
                               Text(
                                'Редактировать задачу',
                                style: _textStyleBold.copyWith(
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
                                                      'Задача обновлена', style: _textStyleBold,
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
                                child: Text(
                                  'Сохранить',
                                  style: _textStyleBold.copyWith(
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
                              style: _textStyleBold.copyWith(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                              items: [
                                DropdownMenuItem<int>(
                                  value: 0,
                                  child: Text(
                                    'Для всех участников',
                                    style: _textStyleSemiBold.copyWith(color: Colors.black),
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
                                      style: _textStyleSemiBold.copyWith(color: Colors.black),
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
                              if (value == null || value.isEmpty) {
                                return 'Введите количество';
                              }
                              final num = double.tryParse(value);
                              if (num == null) return 'Введите число';
                              if (num < 0) {
                                return 'Число должно быть положительным';
                              }
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
                                    style: _textStyleSemiBold.copyWith(
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
                                  child: Text(
                                    'Выбрать',
                                    style: _textStyleBold.copyWith(
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
    _safeReportEvent('task_info_dialog_open');
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
                          child: Text(
                            'Закрыть',
                            style: _textStyleSemiBold.copyWith(color: Colors.grey),
                          ),
                        ),
                        Text(
                          'Информация о задаче',
                          style: _textStyleBold.copyWith(
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
                        style: _textStyleBold.copyWith(
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
                          style: _textStyleSemiBold.copyWith(fontSize: 14),
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
                            style: _textStyleSemiBold.copyWith(fontSize: 14),
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
                              style: _textStyleSemiBold.copyWith(
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
                              style: _textStyleSemiBold.copyWith(fontSize: 14),
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
                            style: _textStyleBold.copyWith(
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
