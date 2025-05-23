import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:zadachok/models/lobby/lobby_model.dart';
import 'package:zadachok/models/task/task_model.dart';
import '../api/api_client.dart';
import '../models/user/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../providers/group_provider.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;


class TaskScreenConstants {
  static const double cardElevation = 2.0;
  static const EdgeInsets cardMargin = EdgeInsets.only(left: 70, right: 20);
  static const EdgeInsets cardPadding = EdgeInsets.all(12);
  static const double taskNameFontSize = 18.0;
  static const double dateFontSize = 14.0;
  static const Color primaryColor = Color(0xFF937DF3);
  static const Color secondaryColor = Color(0xFF6E44FF);
  static const double avatarRadius = 25.0;
  static const double headerHeight = 100.0;
  static const double headerBottomRadius = 40.0;
  static const EdgeInsets headerPadding = EdgeInsets.fromLTRB(24, 15, 24, 10);
  static const double searchBarHeight = 50.0;
  static const Color searchBarColor = Color(0xFFF5F5F5);
  static const Color sortButtonColor = Color(0xFF937DF3);
  static const double searchSortWidth = 352.0;
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



  bool _isLoading = false;
  DateTime? _deadline;
  bool _isFormVisible = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
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

  Future<void> _selectDeadline(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      _showError("Проверьте заполнение полей");
      return;
    }

    // Получаем текущую дату и время
    DateTime initialDateTime = _deadline ?? DateTime.now().add(const Duration(days: 1));
    TimeOfDay initialTime = TimeOfDay.fromDateTime(initialDateTime);

    // Сначала выбираем дату
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: _datePickerTheme,
          child: child!,
        );
      },
    );

    if (pickedDate == null) return; // Пользователь отменил выбор даты

    // Затем выбираем время
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: _datePickerTheme.copyWith(
            // Стилизация TimePicker аналогично DatePicker
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: TaskScreenConstants.primaryColor,
              hourMinuteColor: TaskScreenConstants.primaryColor.withOpacity(0.1),
              dayPeriodTextColor: TaskScreenConstants.primaryColor,
              dayPeriodColor: TaskScreenConstants.primaryColor.withOpacity(0.1),
              dialHandColor: TaskScreenConstants.primaryColor,
              dialBackgroundColor: TaskScreenConstants.primaryColor.withOpacity(0.1),
              hourMinuteTextStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              // Фиксируем ориентацию для TimePicker
              alwaysUse24HourFormat: true,
            ),
            child: child!,
          ),
        );
      },
    );

    if (pickedTime != null && mounted) {
      // Комбинируем выбранную дату и время
      setState(() {
        _deadline = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
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
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _groupNameController.dispose();
    _joinCodeController.dispose();
    _rewardController.dispose();
    super.dispose();
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
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
      floatingActionButton: _buildAddTaskButton(),
    );
  }





  Widget _buildMainContent() {
    final groupProvider = Provider.of<GroupProvider>(context);

    return Column(
      children: [
        if (_isFormVisible && groupProvider.isOwner)
          _buildTaskForm(),
        Expanded(
          child: groupProvider.isInGroup
              ? _buildTasksList()
              : _buildNoGroupView(),
        ),
      ],
    );
  }



  Widget _buildProfileHeader(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: TaskScreenConstants.headerHeight,
      decoration: BoxDecoration(
        color: TaskScreenConstants.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(TaskScreenConstants.headerBottomRadius),
          bottomRight: Radius.circular(TaskScreenConstants.headerBottomRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: TaskScreenConstants.headerPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: TaskScreenConstants.avatarRadius,
                backgroundColor: Colors.white,
                backgroundImage: settingsProvider.avatarImage != null
                    ? FileImage(settingsProvider.avatarImage!)
                    : null,
                child: settingsProvider.avatarImage == null
                    ? Icon(Icons.person,
                    color: theme.colorScheme.secondary,
                    size: TaskScreenConstants.avatarRadius)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                authProvider.user!.name ?? 'Гость',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Theme(
            data: Theme.of(context).copyWith(
              popupMenuTheme: const PopupMenuThemeData(
                color: Colors.white,
                textStyle: TextStyle(color: Colors.black),
              ),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) => _handlePopupSelection(value, context),
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'info',
                  child: Text('Информация о группе'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _handlePopupSelection(String value, BuildContext context) {
    if (value == 'info') {
      _showGroupInfoDialog(context);
    }
  }


  Widget _buildUnauthorizedView() {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 64,
                  color: theme.colorScheme.error),
              const SizedBox(height: 20),
              Text(
                'Доступ ограничен',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Для работы с задачами необходимо авторизоваться',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                icon: const Icon(Icons.login),
                label: const Text('Войти в систему'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Ещё нет аккаунта? Зарегистрируйтесь'),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildNoGroupView() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group_add,
              size: 64,
              color: TaskScreenConstants.primaryColor,
            ),
            const SizedBox(height: 20),
            const Text(
              'Задачи доступны только для участников групп',
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
                backgroundColor: TaskScreenConstants.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Создать группу',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: _showJoinGroupDialog,
              child: Text(
                'Вступить в существующую группу',
                style: TextStyle(color: TaskScreenConstants.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndSortBar() {
    return Container(
      width: TaskScreenConstants.searchSortWidth,
      height: 27,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 168,
            height: 27,
            decoration: BoxDecoration(
              color: TaskScreenConstants.sortButtonColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: PopupMenuButton<String>(
              color: Colors.white,
              offset: const Offset(0, 30),
              onSelected: (value) {
                Provider.of<TaskProvider>(context, listen: false)
                    .sortTasks(option: value);
              },
              itemBuilder: (context) => [
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
                ),
              ],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.sort, color: Colors.white, size: 16),
                  SizedBox(width: 5),
                  Text('Сортировка',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
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
                  const Icon(Icons.search,
                      color: TaskScreenConstants.primaryColor, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                          fontSize: 12,
                          color: TaskScreenConstants.primaryColor),
                      decoration: const InputDecoration(
                        hintText: 'Поиск задач...',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (value) {
                        Provider.of<TaskProvider>(context, listen: false)
                            .searchTasks(value);
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close,
                        color: Colors.grey[600], size: 16),
                    onPressed: () {
                      _searchController.clear();
                      Provider.of<TaskProvider>(context, listen: false)
                          .resetFilters();
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
        _buildSearchAndSortBar(),
        Expanded(
          child: Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              if (taskProvider.isLoadingTasks) {
                return const Center(child: CircularProgressIndicator());
              }

              final authProvider = Provider.of<AuthProvider>(context);
              final isAdmin = authProvider.user?.role.isAdmin ?? false;

              final tasksToShow = isAdmin
                  ? taskProvider.filteredTasks
                  : taskProvider.filteredTasks.where((task) => task.customerId == authProvider.user?.id).toList();

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: tasksToShow.length,
                itemBuilder: (ctx, i) => _buildTaskCard(tasksToShow[i]),
              );
            },
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
      orElse: () => UserModel(
        id: 0,
        name: 'Не назначено',
        email: '',
        login: '',
      ),
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
      borderColor = TaskScreenConstants.primaryColor;
    }


    return Container(
      height: 96,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Кнопка выполнения
          InkWell(
            onTap: () => _completeTask(taskProvider, task.id),
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2),
              ),
              child: statusIcon != null
                  ? Icon(statusIcon, size: 20, color: borderColor)
                  : null,
            ),
          ),

          // Остальная часть карточки
          Expanded(
            child: InkWell(
              onTap: () => _showEditTaskDialog(task),
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      color: task.state == 2
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
                    width: 100,
                    child: ClipPath(
                      clipper: _DiagonalClipper(),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
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
                    padding: const EdgeInsets.all(12),
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
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: TaskScreenConstants.primaryColor,
                                  decoration: task.state == 'Completed'
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (task.description.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    task.description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
                                    if (endPoint != null)
                                      Text(
                                        'До ${DateFormat('dd.MM.yyyy HH:mm').format(endPoint)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isOverdue
                                              ? Colors.red[400]
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    if (startPoint != null)
                                      Text(
                                        'С ${DateFormat('dd.MM.yyyy HH:mm').format(startPoint)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (task.customerId != 0)
                                Positioned(
                                    bottom: 8,
                                    left: 8,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Для: ${groupProvider.members.firstWhere((m) => m.id == task.customerId, orElse: () => UserModel(id: 0, name: 'Неизвестно', email: '', login: '')).name}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: TaskScreenConstants.primaryColor,
                                        ),
                                      ),
                                    ),
                                ),
                              if (task.reward > 0)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: _buildRewardBadge(task.reward),
                                ),
                              if (task.state == 'Completed')
                                const Positioned(
                                  bottom: 20,
                                  right: 0,
                                  child: Icon(
                                    Icons.verified,
                                    color: Colors.white,
                                    size: 16,
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: Colors.amber),
          const SizedBox(width: 2),
          Text(
            reward.toStringAsFixed(reward.truncateToDouble() == reward ? 0 : 1),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTaskForm() {
    final theme = Theme.of(context);
    final group = Provider.of<GroupProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (_selectedMemberId == null) {
      _selectedMemberId = auth.user?.id;
    }


    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
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
                    child: const Text(
                      'Отмена',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const Text(
                    'Новая задача',
                    style: TextStyle(
                      color: TaskScreenConstants.primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _validateAndAddTask,
                    child: const Text(
                      'Готово',
                      style: TextStyle(
                        color: TaskScreenConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),


              _buildRoundedTextField(
                controller: _titleController,
                labelText: 'Название задачи',
                validator: (value) =>
                value?.isEmpty ?? true ? 'Введите название задачи' : null,
              ),
              const SizedBox(height: 16),


              _buildRoundedTextField(
                controller: _descController,
                labelText: 'Описание',
                maxLines: 3,
              ),
              const SizedBox(height: 16),


              DropdownButtonFormField<int>(
                value: _selectedMemberId,
                decoration: InputDecoration(
                  labelText: 'Назначить участнику',
                  hintText: 'Оставить для всех',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem<int>(
                    value: null,
                    child: Text('Для всех участников'),
                  ),
                  ...group.members.map((member) {
                    return DropdownMenuItem<int>(
                      value: member.id,
                      child: Text(member.name),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMemberId = value;
                  });
                },
              ),
              const SizedBox(height: 16),


              _buildRoundedTextField(
                controller: _rewardController,
                labelText: 'Количество звёзд',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите количество';
                  final num = double.tryParse(value);
                  if (num == null) return 'Введите число';
                  if (num < 0) return 'Число должно быть положительным';
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _deadline == null
                            ? 'Выберите дедлайн'
                            : 'Дедлайн: ${DateFormat('dd.MM.yyyy HH:mm').format(_deadline!)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: _deadline == null
                              ? Colors.grey[600]
                              : Colors.black,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _selectDeadline(context),
                      child: const Text(
                        'Выбрать',
                        style: TextStyle(color: TaskScreenConstants.primaryColor),
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

    if (!group.isOwner) {
      return FloatingActionButton(
        onPressed: _showNonOwnerSnackbar,
        child: const Icon(Icons.add),
        backgroundColor: Colors.grey,
        tooltip: 'Доступно только администратору',
      );
    }

    return FloatingActionButton(
      onPressed: _showAddTaskDialog,
      backgroundColor: TaskScreenConstants.primaryColor,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  final ThemeData _datePickerTheme = ThemeData.light().copyWith(
      colorScheme: const ColorScheme.light(
        primary: TaskScreenConstants.primaryColor,
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
          now.minute
      );

      // Проверяем, что дедлайн установлен
      if (_deadline == null) {
        _showError("Пожалуйста, установите дедлайн");
        return;
      }

      final newTask = TaskModel(
        name: _titleController.text.trim(),
        description: _descController.text.trim(),
        endPoint: _deadline!.toUtc().toIso8601String(), // Сохраняем дедлайн как UTC
        startPoint: currentDateTime.toUtc().toIso8601String(), // Текущее время как UTC
        reward: int.tryParse(_rewardController.text) ?? 0,
        customerId: customerId,
        state: 0,
      );

      try {
        setState(() => _isLoading = true);
        final success = await Provider.of<TaskProvider>(context, listen: false)
            .addTask(task: newTask, lobbyId: groupProvider.lobbyId);

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
    showDialog(
      context: context,
      builder: (context) => _buildTaskForm(),
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


      final newState = authProvider.isAdmin ? 2 : 1; // Админ сразу подтверждает (2), пользователь - отмечает выполнение (1)
      final updatedTask = task.copyWith(state: newState);
      await taskProvider.updateTask(updatedTask);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
              authProvider.isAdmin
                  ? 'Задача подтверждена'
                  : 'Задача выполнена (ожидает подтверждения)'
          )),
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

  void _showNonOwnerSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Только администратор может добавлять задачи')),
    );
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

    showDialog(
      context: context,
      builder: (ctx) => Theme(
        data: Theme.of(context).copyWith(
          dialogTheme: DialogTheme(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
        ),
        child: AlertDialog(

          title: const Text('Информация о группе'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Название: ${groupProvider.groupName}'),
              Text('Код: ${groupProvider.groupCode}'),
              const SizedBox(height: 10),
              Text(
                groupProvider.isOwner
                    ? 'Вы администратор группы'
                    : 'Вы участник группы',
                style: TextStyle(
                  color: groupProvider.isOwner ? Colors.green : Colors.blue,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => _handleLeaveGroup(ctx, groupProvider),
              child: const Text('Выйти из группы'),
            ),
            if (groupProvider.isOwner)
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showGroupManagementMenu(context);
                },
                child: const Text('Управление'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLeaveGroup(
      BuildContext ctx, GroupProvider groupProvider) async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
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
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              tileColor: Colors.white,
              leading: const Icon(Icons.people),
              title: const Text('Управление участниками'),
              onTap: () {
                Navigator.pop(ctx);
                _showGroupMembersDialog(context);
              },
            ),
            ListTile(
              tileColor: Colors.white,
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Распустить группу'),
              onTap: () {
                Navigator.pop(ctx);
                _confirmGroupDisband(context);
              },
            ),
          ],
        ),
      ),
    );
  }



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
      // 1. Обновляем данные группы с сервера
      await groupProvider.refreshGroupData();

      // 2. Получаем свежий список участников
      final currentMembers = groupProvider.members;

      // Закрываем индикатор загрузки
      Navigator.of(context).pop();

      // 3. Показываем диалог с участниками
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Участники группы'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: currentMembers.length,
              itemBuilder: (context, index) {
                final member = currentMembers[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(member.name[0]),
                  ),
                  title: Text(member.name),
                  subtitle: Text(member.role.isAdmin ? 'Администратор' : 'Участник'),
                  trailing: groupProvider.isOwner &&
                      !member.role.isAdmin &&
                      member.id != authProvider.user?.id
                      ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeMember(ctx, groupProvider, member),
                  )
                      : null,
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
    } catch (e) {
      // Закрываем индикатор загрузки в случае ошибки
      Navigator.of(context).pop();
      _showError('Ошибка загрузки участников: ${e.toString()}');
    }
  }

  Future<void> _removeMember(
      BuildContext ctx, GroupProvider groupProvider, UserModel member) async {
    try {
      // Используем API клиент через GroupProvider
      final apiClient = ApiClient();
      apiClient.setAuthToken(Provider.of<AuthProvider>(context, listen: false).token!);

      await apiClient.lobbyRemoveUser(groupProvider.lobbyId, member.id);

      // Обновляем локальное состояние через публичные методы
      final updatedMembers = groupProvider.members.where((m) => m.id != member.id).toList();
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
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Распустить группу?'),
        content: const Text(
            'Все участники будут удалены из группы. Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
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
            child: const Text('Распустить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog() {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    if (groupProvider.isInGroup) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вы уже в группе')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Создать новую группу"),
        content: const Text("Нажмите 'Создать' для генерации группы с уникальным кодом"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Отмена"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await groupProvider.createGroup();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Группа создана! Код: ${groupProvider.groupCode}')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка: ${e.toString()}')),
                );
              }
            },
            child: const Text("Создать"),
          ),
        ],
      ),
    );
  }

  void _showJoinGroupDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Вступить в группу"),
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
            child: const Text("Отмена"),
          ),
          TextButton(
            onPressed: () async {
              final code = _joinCodeController.text.trim();
              if (code.length != 6) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text("Код должен содержать 6 символов")),
                );
                return;
              }

              final success = await Provider.of<GroupProvider>(context, listen: false)
                  .joinGroup(code);

              if (success && mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Вы успешно присоединились!")),
                );
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text("Ошибка присоединения")),
                );
              }
            },
            child: const Text("Присоединиться"),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(TaskModel task) {
    final _editTitleController = TextEditingController(text: task.name);
    final _editDescController = TextEditingController(text: task.description);
    final _editRewardController = TextEditingController(text: task.reward.toString());
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Редактировать задачу'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _editTitleController,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            TextField(
              controller: _editDescController,
              decoration: const InputDecoration(labelText: 'Описание'),
            ),
            TextField(
              controller: _editRewardController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Количество звёзд'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              final updatedTask = task.copyWith(
                name: _editTitleController.text,
                description: _editDescController.text,
                reward: int.tryParse(_editRewardController.text) ?? task.reward,
              );
              await taskProvider.updateTask(updatedTask);
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
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