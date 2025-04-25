import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zadachok/models/task/task_model.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/group_provider.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  static const double CARD_ELEVATION = 2.0;
  static const EdgeInsets CARD_MARGIN = EdgeInsets.only(left: 70, right: 20);
  static const EdgeInsets CARD_PADDING = EdgeInsets.all(12);
  static const double TASK_NAME_FONT_SIZE = 18.0;
  static const double DATE_FONT_SIZE = 14.0;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _groupNameController = TextEditingController();
  final _joinCodeController = TextEditingController();
  final _rewardController = TextEditingController(text: '0');

  bool _isLoading = false;

  DateTime? _deadline;
  bool _isFormVisible = false;

  Future<void> _selectDeadline(BuildContext context) async {
    print('Кнопка нажата!'); // Проверим, вызывается ли метод

    if (!_formKey.currentState!.validate()) { // Убедитесь, что форма валидна
      print('Форма не валидна!');
      _showError("Проверьте заполнение полей");
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _addTask() async { // Убираем параметр
    if (!_formKey.currentState!.validate()) return;
    if (_deadline == null) {
      _showError("Выберите дедлайн для задачи");
      return;
    }

    final newTask = TaskModel(
      name: _titleController.text.trim(),
      description: _descController.text.trim(),
      endPoint: _deadline!.toIso8601String(),
      startPoint: DateTime.now().toIso8601String(),
      reward: double.parse(_rewardController.text), // Берем значение из контроллера
      customerId: 1,
      state: 'Pending',
    );

    try {
      setState(() => _isLoading = true);
      final success = await Provider.of<TaskProvider>(context, listen: false)
          .addTask(newTask, context);

      if (success && mounted) {
        _titleController.clear();
        _descController.clear();
        _rewardController.clear(); // Очищаем и reward
        setState(() {
          _deadline = null;
          _isFormVisible = false;
        });
      }
    } catch (e) {
      if (mounted) _showError("Ошибка: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showCreateGroupDialog() {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final TextEditingController nameController = TextEditingController();

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
                  onPressed: () {
                    groupProvider.removeMember(member.name);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${member.name} удален из группы')),
                    );

                    // Если удалили текущего пользователя
                    if (member.name == groupProvider.currentUser?.name) {
                      groupProvider.leaveGroup();
                    }
                  },
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
  Widget _buildUnauthorizedView() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 64,
                color: Colors.orange
            ),
            const SizedBox(height: 20),
            const Text(
              'Доступ ограничен',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Для работы с задачами необходимо авторизоваться',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              icon: const Icon(Icons.login),
              label: const Text('Войти в систему'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('Ещё нет аккаунта? Зарегистрируйтесь'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = Provider.of<TaskProvider>(context).tasks;
    final groupProvider = Provider.of<GroupProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAuthenticated) {
      return _buildUnauthorizedView();
    }

    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<GroupProvider>(context, listen: false).leaveGroup();
      });
      return _buildUnauthorizedView();
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
        title: const Text('Мои задачи'),
        actions: [
          if (!groupProvider.isInGroup) ...[
            IconButton(
              onPressed: () => _showGroupMembersDialog(context),
              icon: const Icon(Icons.people),
            ),
            IconButton(
                onPressed: _showCreateGroupDialog,
                icon: const Icon(Icons.group_add)
            ),
            IconButton(
                onPressed: _showJoinGroupDialog,
                icon: const Icon(Icons.group)
            ),
          ] else ...[
            IconButton(
              onPressed: () {
                // Показываем информацию о группе
                _showGroupInfoDialog(context);
              },
              icon: const Icon(Icons.info_outline),
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (groupProvider.isInGroup)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text(
                        "Группа: ${groupProvider.groupName}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Код: ${groupProvider.groupCode}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: groupProvider.isInGroup
                    ? _buildTasksList(tasks)
                    : _buildNoGroupView(),
              ),
            ],
          ),
          if (groupProvider.isInGroup && groupProvider.isOwner)
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(duration: Duration(milliseconds: 100),
                // ... ваша существующая анимация ...
              ),
            ),
          if (_isFormVisible && groupProvider.isOwner)
            Positioned(
              bottom: 80, // Отступ от нижнего края
              left: 20,
              right: 20,
              child: _buildTaskForm(),
            ),
        ],

      ),
      floatingActionButton: _buildAddTaskButton(),
    );
  }



  Widget _buildNoGroupView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Вы не состоите в группе'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _showCreateGroupDialog,
            child: const Text('Создать группу'),
          ),
        ],
      ),
    );
  }

  void _showGroupInfoDialog(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
          // Обновленная кнопка выхода
          TextButton(
            onPressed: () async {
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
                Navigator.pop(ctx); // Закрываем диалог информации
                await groupProvider.leaveGroup(); // Используем leaveGroup вместо clearUserFromGroup

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Вы вышли из группы')),
                  );
                }
              }
            },
            child: const Text('Выйти из группы'),
          ),

          // Дополнительные действия для админа
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
    );
  }



  void _showGroupManagementMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Название группы изменено')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Минимум 3 символа')),
                );
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _confirmGroupDisband(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Распустить группу?'),
        content: const Text('Все участники будут удалены из группы. Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<GroupProvider>(context, listen: false).disbandGroup();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Группа распущена')),
              );
            },
            child: const Text('Распустить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget? _buildAddTaskButton() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final group = Provider.of<GroupProvider>(context, listen: false);

    if (!auth.isAuthenticated || !group.isInGroup) return null;

    // Для обычных участников показываем неактивную кнопку с подсказкой
    if (!group.isOwner) {
      return FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Только администратор может добавлять задачи')),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.grey, // Серый цвет для неактивной кнопки
        tooltip: 'Доступно только администратору',
      );
    }

    // Для администратора обычная кнопка
    return FloatingActionButton(
      onPressed: () {
        if (_isFormVisible) {
          setState(() => _isFormVisible = false);
        } else {
          setState(() => _isFormVisible = true);
        }
      },
      child: Icon(_isFormVisible ? Icons.close : Icons.add),
    );
  }

  Widget _buildTaskForm() {

    return Card(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название задачи';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Описание'),
              ),
              TextFormField(
                controller: _rewardController, // Используем контроллер
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
                onPressed: _isLoading ? null : () {
                  if (_formKey.currentState!.validate()) {
                    _addTask(); // Теперь без параметра
                  }
                },
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


  Widget _buildTasksList(List<TaskModel> tasks) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (ctx, i) => _buildTaskCard(tasks[i]),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    debugPrint('Отображение задачи: ${task.name}, reward: ${task.reward}');
    final startPoint = _safeParseDate(task.startPoint);
    final endPoint = _safeParseDate(task.endPoint);
    final isOverdue = endPoint != null && endPoint.isBefore(DateTime.now());
    final groupProvider = Provider.of<GroupProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(task.id.toString()),
      direction: groupProvider.isOwner ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Удалить задачу?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        }
        return false;
      },
      onDismissed: (_) => taskProvider.deleteTask(task.id),
      child: Container(
        height: 96,
        margin: const EdgeInsets.only(left: 16, right: 20, top: 8, bottom: 8),
        child: Row(
          children: [
            InkWell(
              onTap: () async {
                await taskProvider.completeTask(task.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Задача завершена')),
                  );
                }
              },
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
                    ? Icon(Icons.check, size: 20, color: Colors.green)
                    : null,
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () => _showEditTaskDialog(task),
                borderRadius: BorderRadius.circular(12),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
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
                                  const Icon(Icons.verified, color: Colors.green, size: 16),
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
                        // Добавляем звёздочки в правый верхний угол
                        if (task.reward > 0)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
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
                                    task.reward.toStringAsFixed(task.reward.truncateToDouble() == task.reward ? 0 : 1),
                                    style: const TextStyle(fontSize: 12, color: Colors.amber),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Функция безопасного парсинга даты
  DateTime? _safeParseDate(String dateString) {
    try {
      return dateString.isNotEmpty ? DateTime.parse(dateString) : null;
    } catch (e) {
      return null; // Возвращаем null, если произошла ошибка при парсинге
    }
  }


// Диалог редактирования задачи
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


  Future<void> _deleteTask(int taskId) async {
    await Provider.of<TaskProvider>(context, listen: false).deleteTask(taskId);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _groupNameController.dispose();
    _joinCodeController.dispose();
    _rewardController.dispose(); // Добавляем очистку reward контроллера
    super.dispose();
  }
}
