// calendar_screen.dart (полная версия)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zadachok/models/task/task_model.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../providers/task_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Константы дизайна
  static const double HEADER_HEIGHT = 100.0;
  static const Color HEADER_COLOR = Color(0xFF937DF3);
  static const BorderRadius HEADER_BORDER_RADIUS = BorderRadius.only(
    bottomLeft: Radius.circular(40),
    bottomRight: Radius.circular(40),
  );
  static const double MONTH_LABEL_HEIGHT = 62.0;
  static const Color MONTH_LABEL_COLOR = Color(0xFFCCC1FF);
  static const double CALENDAR_HEIGHT = 242.0;
  static const double DAY_LABEL_FONT_SIZE = 25.0;
  static const Color DAY_LABEL_COLOR = Color(0xFF937DF3);
  static const double DAY_FONT_SIZE = 25.0;
  static const Color DAY_COLOR = Color(0xFF666666);
  static const Color SELECTED_DAY_COLOR = Color(0xFF6E44FF);
  static const Color TODAY_COLOR = Color(0xFFCCC1FF);
  static const double TASK_INDICATOR_SIZE = 8.0;

  DateTime _selectedDate = DateTime.now();
  bool _showMonthPicker = false;

  void _selectMonth(int month) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, month);
      _showMonthPicker = false;
    });
  }



  bool _hasTasksForDate(DateTime date, List<TaskModel> tasks) {
    return tasks.any((task) {
      final deadline = task.deadline;
      return DateUtils.isSameDay(date, deadline);
    });
  }



  List<Widget> _buildDayLabels() {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days.map((day) => Center(
      child: Text(
        day,
        style: const TextStyle(
          color: DAY_LABEL_COLOR,
          fontWeight: FontWeight.bold,
          fontSize: DAY_LABEL_FONT_SIZE,
        ),
      ),
    )).toList();
  }

  List<Widget> _buildCalendarDays(DateTime month, List<TaskModel> tasks) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final startWeekday = (firstDayOfMonth.weekday + 6) % 7;
    final totalDays = lastDayOfMonth.day;
    final List<Widget> dayWidgets = [];

    // Пустые ячейки для начала месяца
    for (int i = 0; i < startWeekday; i++) {
      dayWidgets.add(Container());
    }

    // Дни месяца
    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(month.year, month.month, day);
      final isToday = DateUtils.isSameDay(DateTime.now(), date);
      final isSelected = DateUtils.isSameDay(_selectedDate, date);
      final hasTasks = _hasTasksForDate(date, tasks);

      dayWidgets.add(_buildDayCell(day, isToday, isSelected, hasTasks, date));
    }

    return dayWidgets;
  }

  Widget _buildDayCell(
      int day,
      bool isToday,
      bool isSelected,
      bool hasTasks,
      DateTime date
      ) {
    BoxDecoration decoration = const BoxDecoration();
    TextStyle textStyle = const TextStyle(
      color: DAY_COLOR,
      fontSize: DAY_FONT_SIZE,
    );

    if (isToday && !isSelected) {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: TODAY_COLOR, width: 2),
      );
      textStyle = const TextStyle(
        color: TODAY_COLOR,
        fontWeight: FontWeight.bold,
        fontSize: DAY_FONT_SIZE,
      );
    } else if (isSelected) {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: SELECTED_DAY_COLOR, width: 2),
      );
    } else if (isToday && isSelected) {
      decoration = const BoxDecoration(
        shape: BoxShape.circle,
        color: SELECTED_DAY_COLOR,
      );
      textStyle = const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: DAY_FONT_SIZE,
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = date),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            decoration: decoration,
            child: Text('$day', style: textStyle),
          ),
          if (hasTasks) Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: TASK_INDICATOR_SIZE,
              height: TASK_INDICATOR_SIZE,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<TaskModel> tasks) {
    final tasksForSelectedDate = tasks.where((task) {
      final deadline = _safeParseDate(task.endPoint); // Используем endPoint вместо deadline
      return deadline != null && DateUtils.isSameDay(_selectedDate, deadline);
    }).toList();

    if (tasksForSelectedDate.isEmpty) {
      return const Center(
        child: Text('Нет задач на выбранную дату'),
      );
    }

    return ListView.builder(
      itemCount: tasksForSelectedDate.length,
      itemBuilder: (context, index) {
        final task = tasksForSelectedDate[index];
        final deadline = _safeParseDate(task.endPoint); // Используем endPoint
        final createdAt = _safeParseDate(task.startPoint); // Используем startPoint
        final isOverdue = deadline != null && deadline.isBefore(DateTime.now());

        return Container(
          margin: const EdgeInsets.only(left: 16, right: 20, top: 8, bottom: 8),
          child: Card(
            elevation: 2,
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
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Добавляем отображение звёздочек
                          if (task.reward > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, size: 16, color: Colors.amber),
                                  const SizedBox(width: 2),
                                  Text(
                                    task.reward.toStringAsFixed(task.reward.truncateToDouble() == task.reward ? 0 : 1),
                                    style: const TextStyle(fontSize: 12, color: Colors.amber),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      if (task.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            task.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Создано: ${createdAt != null ? DateFormat('dd.MM.yyyy').format(createdAt) : "неизвестно"}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const Spacer(),
                          Text(
                            'Дедлайн: ${deadline != null ? DateFormat('dd.MM.yyyy').format(deadline) : "неизвестно"}',
                            style: TextStyle(
                              fontSize: 14,
                              color: isOverdue ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// Безопасный парсинг даты
  DateTime? _safeParseDate(dynamic date) {
    try {
      if (date is DateTime) return date;
      if (date is String && date.isNotEmpty) return DateTime.parse(date);
    } catch (_) {}
    return null;
  }


  Widget _buildMonthPicker(int currentYear) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: List.generate(12, (index) {
            final monthName = toBeginningOfSentenceCase(
                DateFormat.MMMM('ru').format(DateTime(currentYear, index + 1))
            );
            return GestureDetector(
              onTap: () => _selectMonth(index + 1),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  monthName!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildUnauthorizedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Упс! Нужно авторизоваться', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: Text('Войти'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotInGroupView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Вы не состоите в группе', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/groups'),
            child: Text('Присоединиться к группе'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);
    final tasks = Provider.of<TaskProvider>(context).tasks;
    final currentYear = _selectedDate.year;
    final currentMonth = toBeginningOfSentenceCase(
        DateFormat.MMMM('ru').format(_selectedDate)
    );

    if (!authProvider.isAuthenticated) {
      return _buildUnauthorizedView();
    }

    if (!groupProvider.isInGroup) {
      return _buildNotInGroupView();
    }


    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
            children: [
            // Заголовок с годом
            GestureDetector(
            onTap: () => setState(() => _showMonthPicker = !_showMonthPicker),
    child: Container(
    width: double.infinity,
    height: HEADER_HEIGHT,
    decoration: BoxDecoration(
    color: HEADER_COLOR,
    borderRadius: HEADER_BORDER_RADIUS,
    boxShadow: const [
    BoxShadow(
    color: Colors.black26,
    blurRadius: 12,
    offset: Offset(0, 6),
    ),
    ],
    ),
    padding: const EdgeInsets.only(left: 24, right: 24, top: 35),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text(
    '$currentYear',
    style: const TextStyle(
    color: Colors.white,
    fontSize: 50,
    fontWeight: FontWeight.w600,
    ),
    ),
    Icon(
    _showMonthPicker
    ? Icons.keyboard_arrow_up
        : Icons.keyboard_arrow_down,
    color: Colors.white,
    size: 36,
    ),
    ],
    ),
    ),
    ),
    const SizedBox(height: 20),
    _showMonthPicker
    ? _buildMonthPicker(currentYear)
        : Expanded(
    child: Column(
    children: [
    // Месяц и календарь
    Container(
    width: 352,
    height: MONTH_LABEL_HEIGHT,
    padding: const EdgeInsets.only(left: 16),
    decoration: BoxDecoration(
    color: MONTH_LABEL_COLOR,
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
    BoxShadow(
    color: Colors.black12,
    blurRadius: 10,
    offset: Offset(0, 5),
    ),
    ],
    ),
    child: Text(
    currentMonth!,
    style: const TextStyle(
    color: Color(0xFF6E44FF),
    fontSize: 36,
    fontWeight: FontWeight.bold,
    ),
    ),
    ),
    const SizedBox(height: 12),
    Container(
    width: 352,
    height: CALENDAR_HEIGHT,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
    BoxShadow(
    color: Colors.black26,
    blurRadius: 12,
    offset: Offset(0, 6),
    ),
    ],
    ),
    child: Column(
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: _buildDayLabels(),
    ),
    const SizedBox(height: 8),
    Expanded(
    child: SingleChildScrollView(
    child: GridView.count(
    shrinkWrap: true,
    crossAxisCount: 7,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    physics: const NeverScrollableScrollPhysics(),
    children: _buildCalendarDays(_selectedDate, tasks),
    ),
    ),
    ),
    ],
    ),
    ),
    const SizedBox(height: 20),
    // Список задач на выбранную дату
    Expanded(
    child: _buildTaskList(tasks),
    ),
    ],
    ),
    ),
    ],
    ),
    );
  }
}