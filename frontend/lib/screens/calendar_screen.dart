import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zadachok/models/task/task_model.dart';
import '../providers/task_provider.dart';
import 'tasks_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();
  bool showMonthPicker = false;

  DateTime? get date => null;

  void _selectMonth(int month) {
    setState(() {
      selectedDate = DateTime(selectedDate.year, month);
      showMonthPicker = false;
    });
  }

  // Метод для проверки, есть ли задачи на выбранную дату
  bool _hasTasksForDate(DateTime date, List<TaskModel> tasks) {
    return tasks.any((task) =>
    task.endPoint != null && DateUtils.isSameDay(DateTime.parse(task.endPoint), date)
    );
  }

  List<Widget> _buildDayLabels() {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days.map((day) => Center(
      child: Text(
        day,
        style: const TextStyle(
          color: Color(0xFF937DF3),
          fontWeight: FontWeight.bold,
          fontSize: 25,
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

    for (int i = 0; i < startWeekday; i++) {
      dayWidgets.add(Container());
    }

    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(month.year, month.month, day);
      final isToday = DateUtils.isSameDay(DateTime.now(), date);
      final isSelected = DateUtils.isSameDay(selectedDate, date);
      final hasTasks = _hasTasksForDate(date, tasks);

      BoxDecoration decoration = const BoxDecoration();
      TextStyle textStyle = const TextStyle(
        color: Color(0xFF666666),
        fontSize: 25,
      );

      if (isToday && !isSelected) {
        decoration = BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Color(0xFFCCC1FF), width: 2),
        );
        textStyle = const TextStyle(
          color: Color(0xFFCCC1FF),
          fontWeight: FontWeight.bold,
          fontSize: 25,
        );
      } else if (isSelected) {
        decoration = BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Color(0xFFCCC1FF),
            width: 2,
            style: BorderStyle.solid,
          ),
        );
        textStyle = const TextStyle(
          color: Color(0xFF666666),
          fontWeight: FontWeight.bold,
          fontSize: 25,
        );
      } else if (isToday && isSelected) {
        decoration = const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFCCC1FF),
        );
        textStyle = const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 25,
        );
      }

      dayWidgets.add(GestureDetector(
        onTap: () => setState(() => selectedDate = date),
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
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ));
    }

    return dayWidgets;
  }

  Widget _buildTaskList(List<TaskModel> tasks) {
    final tasksForSelectedDate = tasks.where((task) =>
    task.endPoint != null && DateUtils.isSameDay(DateTime.parse(task.endPoint), date)
    ).toList();

    if (tasksForSelectedDate.isEmpty) {
      return const Center(
        child: Text(
          'Нет задач на выбранную дату',
          style: TextStyle(
            fontSize: 17,
            color: Color(0xFF666666),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: tasksForSelectedDate.length,
      itemBuilder: (context, index) {
        final task = tasksForSelectedDate[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6E44FF),
                  ),
                ),
                const SizedBox(height: 4),
                if (task.description != null) Text(task.description!),
                const SizedBox(height: 8),
                Text(
                  'Дедлайн: ${DateFormat('dd.MM.yyyy').format(DateTime.parse(task.endPoint))}',
                  style: TextStyle(
                    color: DateTime.parse(task.endPoint).isBefore(DateTime.now())
                        ? Colors.red
                        : Colors.grey,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = Provider.of<TaskProvider>(context).tasks;
    final screenWidth = MediaQuery.of(context).size.width;
    final currentYear = selectedDate.year;
    final currentMonth = toBeginningOfSentenceCase(
        DateFormat.MMMM('ru').format(selectedDate)
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // Заголовок с годом
              GestureDetector(
                onTap: () => setState(() => showMonthPicker = !showMonthPicker),
                child: Container(
                  width: screenWidth,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF937DF3),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 35),
                  alignment: Alignment.centerLeft,
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
                        showMonthPicker
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

              if (!showMonthPicker) ...[
                // Месяц и календарь
                Container(
                  width: 352,
                  height: 62,
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.only(left: 16),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCC1FF),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
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
                  height: 242,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: const Offset(0, 6),
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
                            children: _buildCalendarDays(selectedDate, tasks),
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
              ] else ...[
                // Выбор месяца
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: List.generate(12, (index) {
                        final monthName = toBeginningOfSentenceCase(
                            DateFormat.MMMM('ru')
                                .format(DateTime(currentYear, index + 1))
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
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}