import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:zadachok/models/task/task_model.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../providers/group_provider.dart';


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
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {

  late final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController();
  late final _descController = TextEditingController();
  late final _groupNameController = TextEditingController();
  late final _joinCodeController = TextEditingController();
  late final _rewardController = TextEditingController(text: '0');


  bool _isLoading = false;
  DateTime? _deadline;
  bool _isFormVisible = false;

  @override
  void dispose() {
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

    if (!authProvider.isAuthenticated) {
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
                settingsProvider.userName ?? authProvider.user?.name ?? 'Гость',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => _handlePopupSelection(value, context),
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'info',
                child: Text('Информация о группе'),
              ),
            ],
          ),
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
            Text(
              'Задачи доступны только для участников групп',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Создайте новую группу или вступите в существующую, чтобы получить доступ к задачам',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _showCreateGroupDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: TaskScreenConstants.secondaryColor,
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
                style: TextStyle(color: TaskScreenConstants.secondaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildTasksList() {
    final tasks = Provider.of<TaskProvider>(context).tasks;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tasks.length,
      itemBuilder: (ctx, i) => _buildTaskCard(tasks[i]),
    );
  }


  Widget _buildTaskCard(TaskModel task) {
    final theme = Theme.of(context);
    final startPoint = _safeParseDate(task.startPoint);
    final endPoint = _safeParseDate(task.endPoint);
    final isOverdue = endPoint != null && endPoint.isBefore(DateTime.now());
    final groupProvider = Provider.of<GroupProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return Container(
      height: 96,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [

          InkWell(
            onTap: () => _completeTask(taskProvider, task.id),
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.state == 'Completed'
                      ? Colors.green
                      : theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              child: task.state == 'Completed'
                  ? const Icon(Icons.check, size: 20, color: Colors.green)
                  : null,
            ),
          ),

          Expanded(
            child: InkWell(
              onTap: () => _showEditTaskDialog(task),
              borderRadius: BorderRadius.circular(12),
              child: Card(
                elevation: TaskScreenConstants.cardElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: TaskScreenConstants.cardPadding,
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  task.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    decoration: task.state == 'Completed'
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (task.state == 'Completed')
                                const Icon(Icons.verified,
                                    color: Colors.green,
                                    size: 16),
                            ],
                          ),

                          if (task.description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                task.description,
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          const Spacer(),

                          Row(
                            children: [
                              if (startPoint != null)
                                Text(
                                  DateFormat('dd.MM.yyyy').format(startPoint),
                                  style: theme.textTheme.labelSmall,
                                ),
                              const Spacer(),
                              if (endPoint != null)
                                Text(
                                  DateFormat('dd.MM.yyyy').format(endPoint),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isOverdue ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),

                      if (task.reward > 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: _buildRewardBadge(task.reward),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildRewardBadge(double reward) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: Colors.amber),
          const SizedBox(width: 2),
          Text(
            reward.toStringAsFixed(reward.truncateToDouble() == reward ? 0 : 1),
            style: const TextStyle(fontSize: 12, color: Colors.amber),
          ),
        ],
      ),
    );
  }


  Widget _buildTaskForm() {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Название задачи'),
                validator: (value) =>
                value?.isEmpty ?? true ? 'Введите название задачи' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Описание'),
              ),
              TextFormField(
                controller: _rewardController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Количество звёзд'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите количество';
                  if (double.tryParse(value) == null) return 'Введите число';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _deadline == null
                          ? 'Выберите дедлайн'
                          : 'Дедлайн: ${DateFormat('dd.MM.yyyy').format(_deadline!)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDeadline(context),
                    child: const Text('Выбрать дату'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _validateAndAddTask(),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Создать задачу'),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget? _buildAddTaskButton() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final group = Provider.of<GroupProvider>(context, listen: false);

    if (!auth.isAuthenticated || !group.isInGroup) return null;

    if (!group.isOwner) {
      return FloatingActionButton(
        onPressed: () => _showNonOwnerSnackbar(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.grey,
        tooltip: 'Доступно только администратору',
      );
    }

    return FloatingActionButton(
      onPressed: () => setState(() => _isFormVisible = !_isFormVisible),
      backgroundColor: TaskScreenConstants.primaryColor,
      child: Icon(_isFormVisible ? Icons.close : Icons.add),
    );
  }


  Future<void> _selectDeadline(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      _showError("Проверьте заполнение полей");
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() => _deadline = picked);
    }
  }

  void _validateAndAddTask() {
    if (_formKey.currentState!.validate()) {
      _addTask();
    }
  }

  Future<void> _addTask() async {
    if (_deadline == null) {
      _showError("Выберите дедлайн для задачи");
      return;
    }

    final newTask = TaskModel(
      name: _titleController.text.trim(),
      description: _descController.text.trim(),
      endPoint: _deadline!.toIso8601String(),
      startPoint: DateTime.now().toIso8601String(),
      reward: double.parse(_rewardController.text),
      customerId: 1,
      state: 'Pending',
    );

    try {
      setState(() => _isLoading = true);
      final success = await Provider.of<TaskProvider>(context, listen: false)
          .addTask(newTask, context);

      if (success && mounted) {
        _resetForm();
      }
    } catch (e) {
      if (mounted) _showError("Ошибка: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descController.clear();
    _rewardController.clear();
    setState(() {
      _deadline = null;
      _isFormVisible = false;
    });
  }

  Future<void> _completeTask(TaskProvider taskProvider, int taskId) async {
    await taskProvider.completeTask(taskId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Задача завершена')),
      );
    }
  }

  DateTime? _safeParseDate(String dateString) {
    try {
      return dateString.isNotEmpty ? DateTime.parse(dateString) : null;
    } catch (e) {
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
              leading: const Icon(Icons.edit),
              title: const Text('Изменить название группы'),
              onTap: () {
                Navigator.pop(ctx);
                _showChangeGroupNameDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Управление участниками'),
              onTap: () {
                Navigator.pop(ctx);
                _showGroupMembersDialog(context);
              },
            ),
            ListTile(
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

  void _showChangeGroupNameDialog(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final controller = TextEditingController(text: groupProvider.groupName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Изменить название группы'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Новое название',
            hintText: 'Введите новое название группы',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().length >= 3) {
                groupProvider.updateGroupName(controller.text.trim());
                Navigator.pop(ctx);
                _showError('Название группы изменено');
              } else {
                _showError('Минимум 3 символа');
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showGroupMembersDialog(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Участники группы'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: groupProvider.members.length,
            itemBuilder: (context, index) {
              final member = groupProvider.members[index];
              return ListTile(
                title: Text(member.name),
                trailing: groupProvider.isOwner && member.role != GroupRole.owner
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
  }

  void _removeMember(
      BuildContext ctx, GroupProvider groupProvider, GroupMember member) {
    groupProvider.removeMember(member.name);
    Navigator.pop(ctx);
    _showError('${member.name} удален из группы');

    if (member.name == groupProvider.currentUser?.name) {
      groupProvider.leaveGroup();
    }
  }

  void _confirmGroupDisband(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Распустить группу?'),
        content: const Text(
            'Все участники будут удалены из группы. Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<GroupProvider>(context, listen: false).disbandGroup();
              Navigator.pop(ctx);
              _showError('Группа распущена');
            },
            child: const Text('Распустить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog() {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final TextEditingController nameController = TextEditingController();

    if (groupProvider.isInGroup) {
      _showError('Вы уже в группе');
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Создать группу'),
        content: TextField(
          controller: nameController,
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
                final name = nameController.text.trim();
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
              _joinCodeController.clear();
            },
            child: const Text("Вступить"),
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
                reward: double.tryParse(_editRewardController.text) ?? task.reward,
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