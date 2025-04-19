import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zadachok/models/task/task_model.dart';
import 'package:zadachok/providers/task_provider.dart';
import 'package:intl/intl.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _deadline;

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _addTask() async {
    if (!_formKey.currentState!.validate() || _deadline == null) return;

    final newTask = TaskModel(
      name: _titleController.text,
      description: _descController.text,
      startPoint: DateTime.now().toString(),
      endPoint: _deadline!.toString(),
      reward: 0, // Можно добавить поле для ввода награды
      customerId: 1, // Заменить на реальный ID пользователя
      state: 'Pending',
    );

    final success = await Provider.of<TaskProvider>(context, listen: false)
        .addTask(newTask);

    if (success && mounted) {
      _titleController.clear();
      _descController.clear();
      setState(() => _deadline = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.tasks;

    return Scaffold(
      appBar: AppBar(title: const Text('Мои задачи')),
      body: Column(
        children: [
          // Форма добавления
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Название задачи'),
                    validator: (v) => v!.isEmpty ? 'Введите название' : null,
                  ),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Описание'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(_deadline == null
                          ? 'Не выбран дедлайн'
                          : 'Дедлайн: ${DateFormat('dd.MM.yyyy').format(_deadline!)}'),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _selectDate(context),
                        child: const Text('Выбрать дату'),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _addTask,
                    child: const Text('Добавить задачу'),
                  ),
                ],
              ),
            ),
          ),
          // Список задач
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (ctx, i) => _buildTaskCard(tasks[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    final deadline = DateTime.parse(task.endPoint);
    final isOverdue = deadline.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(task.name, style: const TextStyle(fontSize: 18))),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => Provider.of<TaskProvider>(context, listen: false)
                      .deleteTask(task.id),
                ),
              ],
            ),
            if (task.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(task.description),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Создано: ${DateFormat('dd.MM.yyyy').format(DateTime.parse(task.startPoint))}'),
                const Spacer(),
                Text(
                  'Дедлайн: ${DateFormat('dd.MM.yyyy').format(deadline)}',
                  style: TextStyle(color: isOverdue ? Colors.red : Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }
}