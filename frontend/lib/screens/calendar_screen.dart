import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zadachok/models/task/task_model.dart';
import 'package:zadachok/screens/tasks_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../providers/task_provider.dart';


class CalendarStyles {
  static const double headerHeight = 100.0;
  static const double monthHeaderHeight = 62.0;
  static const double calendarHeight = 240.0;
  static const double dayLabelFontSize = 25.0;
  static const double dayNumberFontSize = 25.0;
  static const double monthNameFontSize = 36.0;
  static const double yearFontSize = 40.0;
  static const double taskTitleFontSize = 18.0;
  static const double taskDescriptionFontSize = 14.0;
  static const double titleMonthCalendarSize = 23.0;

  static const Color primaryColor = Color(0xFF937DF3);
  static const Color secondaryColor = Color(0xFF6E44FF);
  static const Color monthHeaderColor = Color(0xFFCCC1FF);
  static const Color dayLabelColor = Color(0xFF937DF3);
  static const Color dayNumberColor = Color(0xFF666666);
  static const Color selectedDayColor = Colors.white;
  static const Color todayBorderColor = Color(0xFFCCC1FF);
  static const Color taskOverdueColor = Colors.red;
  static const Color taskOnTimeColor = Colors.green;
  static const Color todayMonthColor = Color(0xFFC1FFEB);

  static const BorderRadius headerBorderRadius = BorderRadius.only(
    bottomLeft: Radius.circular(40),
    bottomRight: Radius.circular(40),
  );

  static const EdgeInsets headerPadding = EdgeInsets.fromLTRB(25, 15, 24, 10);
  static const EdgeInsets calendarPadding = EdgeInsets.all(16);
  static const EdgeInsets taskCardPadding = EdgeInsets.all(12);
  static const EdgeInsets monthPickerPadding = EdgeInsets.all(16);

  static const BoxShadow headerShadow = BoxShadow(
    color: Colors.black26,
    blurRadius: 12,
    offset: Offset(0, 6),
  );

  static const BoxShadow calendarShadow = BoxShadow(
    color: Colors.black26,
    blurRadius: 12,
    offset: Offset(0, 6),
  );

  static const BoxShadow monthHeaderShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 10,
    offset: Offset(0, 5),
  );
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {

  DateTime _selectedDate = DateTime.now();
  bool _showYearPicker = false;

  Widget _buildYearPickerOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: _showYearPicker
            ? Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(6),
          child: _buildYearPicker(),
        )
            : const SizedBox(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildMainContent(),
          if (_showYearPicker) _buildYearPickerOverlay(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [

        _buildYearHeader(),
        const SizedBox(height: 12),


        Expanded(
          child: _buildCalendarContentWithAuthCheck(),
        ),
      ],
    );
  }

  Widget _buildCalendarContentWithAuthCheck() {
    final auth = Provider.of<AuthProvider>(context);
    final group = Provider.of<GroupProvider>(context);

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMonthHeader(),
            _buildCalendarGrid(),
            const SizedBox(height: 12),
            auth.isAuthorized && group.isInGroup
                ? _buildTaskList()
                : _buildUnauthorizedTaskMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildYearHeader() {
    return Container(
      width: double.infinity,
      height: CalendarStyles.headerHeight,
      decoration: BoxDecoration(
        color: CalendarStyles.primaryColor,
        borderRadius: CalendarStyles.headerBorderRadius,
        boxShadow: [CalendarStyles.headerShadow],
      ),
      padding: CalendarStyles.headerPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${_selectedDate.year}',
            style: const TextStyle(
              fontSize: CalendarStyles.yearFontSize,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(
              _showYearPicker ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 40,
            ),
            onPressed: () => setState(() => _showYearPicker = !_showYearPicker),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    final currentMonth = toBeginningOfSentenceCase(DateFormat.MMMM('ru').format(_selectedDate));

    return GestureDetector(
      onTap: () => setState(() {
        _showYearPicker = false;
      }),
      child: Container(
        height: CalendarStyles.monthHeaderHeight,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: CalendarStyles.monthHeaderColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [CalendarStyles.monthHeaderShadow],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              currentMonth!,
              style: const TextStyle(
                color: CalendarStyles.secondaryColor,
                fontSize: CalendarStyles.monthNameFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final tasks = Provider.of<TaskProvider>(context).tasks;

    return Container(
      height: CalendarStyles.calendarHeight,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      // margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: CalendarStyles.calendarPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [CalendarStyles.calendarShadow],
      ),
      child: Column(
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buildDayLabels(),
          ),


          Expanded(
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: _buildCalendarDays(_selectedDate, tasks),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDayLabels() {
    const days = ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'];
    return days.map((day) => Center(
      child: Text(
        day,
        style: const TextStyle(
          color: CalendarStyles.dayLabelColor,
          fontWeight: FontWeight.bold,
          fontSize: CalendarStyles.dayLabelFontSize,
        ),
      ),
    )).toList();
  }

  List<Widget> _buildCalendarDays(DateTime month, List<TaskModel> tasks) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final startOffset = (firstDay.weekday + 6) % 7;
    final daysInMonth = lastDay.day;

    return [
      for (int i = 0; i < startOffset; i++) Container(),
      for (int day = 1; day <= daysInMonth; day++)
        _buildDayCell(
          day: day,
          date: DateTime(month.year, month.month, day),
          tasks: tasks,
        ),
    ];
  }

  Widget _buildDayCell({
    required int day,
    required DateTime date,
    required List<TaskModel> tasks,
  }) {
    final isToday = DateUtils.isSameDay(DateTime.now(), date);
    final isSelected = DateUtils.isSameDay(_selectedDate, date);
    final hasTasks = tasks.any((t) => DateUtils.isSameDay(date, _safeParseDate(t.endPoint)));

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = date),
      // child: Transform.translate(
      // offset: Offset(0, -35), // ← Сдвиг по X и Y //вот тут короче надо пофиксить
      child: Container(
        padding: EdgeInsets.only(left: 0, bottom: 7),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Color(0xFFCCC1FF) : null,
          border: Border.all(
            color: isToday
                ? (isSelected ? Colors.white : CalendarStyles.todayBorderColor)
                : Colors.transparent,
            width: 0,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                color: isSelected ? CalendarStyles.selectedDayColor : CalendarStyles.dayNumberColor,
                fontSize: CalendarStyles.dayNumberFontSize,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (hasTasks)
              Positioned(
                top: 0.1,
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
          ],),
        ),
      // ),
    );
  }

  Widget _buildTaskList() {
    final tasks = Provider.of<TaskProvider>(context).tasks;
    final filteredTasks = tasks.where((t) {
      final deadline = _safeParseDate(t.endPoint);
      return deadline != null && DateUtils.isSameDay(_selectedDate, deadline);
    }).toList();

    if (filteredTasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Нет задач на выбранную дату'),
      );
    }

    return SizedBox(
      height: 300,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredTasks.length,
        itemBuilder: (context, i) => _buildTaskCard(filteredTasks[i]),
      ),
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



          Expanded(
            child: InkWell(
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
                      color: task.state == 'Completed'
                          ? const Color(0xFFD9FFF3)
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
                                        'До ${DateFormat('dd.MM').format(endPoint)}',
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
                                        'С ${DateFormat('dd.MM').format(startPoint)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withOpacity(0.8),
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
          const Icon(Icons.star, size: 16, color: Colors.amber),
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

  Widget _buildUnauthorizedTaskMessage() {
    final auth = Provider.of<AuthProvider>(context);
    final group = Provider.of<GroupProvider>(context);

    String message;
    if (!auth.isAuthorized) {
      message = 'Для просмотра задач необходимо авторизоваться';
    } else if (!group.isInGroup) {
      message = 'Только находясь в группе можно просматривать задачи';
    } else {
      message = 'Нет доступа к задачам';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Icon(
              auth.isAuthorized ? Icons.group : Icons.lock,
              size: 64,
              color: const Color(0xFF937DF3),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildYearPicker() {
    final currentYear = _selectedDate.year;
    final monthNames = DateFormat.MMMM('ru');
    final now = DateTime.now();

    return Material(
      key: const ValueKey('year_picker'),
      elevation: 8,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: CalendarStyles.primaryColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$currentYear',
                    style: const TextStyle(
                      fontSize: CalendarStyles.yearFontSize,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _showYearPicker ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 50,
                    ),
                    onPressed: () => setState(() {
                      _showYearPicker = !_showYearPicker;
                    }),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  crossAxisCount: 3,
                  childAspectRatio: 1.1,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  children: List.generate(12, (index) {
                    final month = index + 1;
                    final monthName = toBeginningOfSentenceCase(
                      monthNames.format(DateTime(currentYear, month)),
                    );
                    final isCurrentMonth = month == now.month && currentYear == now.year;

                    return _buildMonthPicker(
                      monthName: monthName!,
                      year: currentYear,
                      month: month,
                      isCurrentMonth: isCurrentMonth,
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthPicker({
    required String monthName,
    required int year,
    required int month,
    required bool isCurrentMonth,
  }) {
    final isSelectedMonth = _selectedDate.month == month && _selectedDate.year == year;

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelectedMonth ? CalendarStyles.secondaryColor.withOpacity(0.5) : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          setState(() {
            _selectedDate = DateTime(year, month);
            _showYearPicker = false;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              monthName,
              style: TextStyle(
                fontSize: CalendarStyles.titleMonthCalendarSize,
                fontWeight: FontWeight.bold,
                color: isCurrentMonth
                    ? CalendarStyles.todayMonthColor
                    : (isSelectedMonth ? Colors.white : Colors.white.withOpacity(0.8)),
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: _buildMiniCalendar(year, month),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCalendar(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final startOffset = (firstDay.weekday + 6) % 7;
    final daysInMonth = lastDay.day;

    final currentDate = DateTime.now();
    final currentMonth = currentDate.month;
    final currentYear = currentDate.year;

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 1,
      padding: EdgeInsets.zero,
      mainAxisSpacing: 0,
      crossAxisSpacing: 0,
      shrinkWrap: true,
      children: [
        for (int i = 0; i < startOffset; i++) const SizedBox(),
        for (int day = 1; day <= daysInMonth; day++)
          Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 9,
                color: (month == currentMonth && year == currentYear)
                    ? CalendarStyles.todayMonthColor
                    : Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  DateTime? _safeParseDate(dynamic date) {
    try {
      if (date is DateTime) return date;
      if (date is String && date.isNotEmpty) return DateTime.parse(date);
    } catch (_) {}
    return null;
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
