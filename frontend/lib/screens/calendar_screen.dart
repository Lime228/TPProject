import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zadachok/models/task/task_model.dart';
import 'package:zadachok/screens/tasks_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../providers/task_provider.dart';

class CalendarStyles {
  // Изменяем фиксированные размеры на функции, которые учитывают размер экрана
  static double headerHeight(BuildContext context) => MediaQuery.of(context).size.height * 0.12;
  static double monthHeaderHeight(BuildContext context) => MediaQuery.of(context).size.height * 0.07;
  static double calendarHeight(BuildContext context) => MediaQuery.of(context).size.height * 0.28;
  // Размеры шрифтов относительно ширины экрана
  static double dayLabelFontSize(BuildContext context) => MediaQuery.of(context).size.width * 0.06;
  static double dayNumberFontSize(BuildContext context) => MediaQuery.of(context).size.width * 0.06;
  static double monthNameFontSize(BuildContext context) => MediaQuery.of(context).size.width * 0.09;
  static double yearFontSize(BuildContext context) => MediaQuery.of(context).size.width * 0.1;
  static double taskTitleFontSize(BuildContext context) => MediaQuery.of(context).size.width * 0.045;
  static double taskDescriptionFontSize(BuildContext context) => MediaQuery.of(context).size.width * 0.035;
  static double titleMonthCalendarSize(BuildContext context) => MediaQuery.of(context).size.width * 0.055;

  // Цвета остаются без изменений
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

  static BorderRadius headerBorderRadius(BuildContext context) => BorderRadius.only(
    bottomLeft: Radius.circular(MediaQuery.of(context).size.width * 0.1),
    bottomRight: Radius.circular(MediaQuery.of(context).size.width * 0.1),
  );

  // Адаптивные отступы
  static EdgeInsets headerPadding(BuildContext context) => EdgeInsets.fromLTRB(
    MediaQuery.of(context).size.width * 0.06,
    MediaQuery.of(context).size.height * 0.02,
    MediaQuery.of(context).size.width * 0.06,
    MediaQuery.of(context).size.height * 0.01,
  );

  static EdgeInsets calendarPadding(BuildContext context) => EdgeInsets.all(MediaQuery.of(context).size.width * 0.04);
  static EdgeInsets taskCardPadding(BuildContext context) => EdgeInsets.all(MediaQuery.of(context).size.width * 0.03);
  static EdgeInsets monthPickerPadding(BuildContext context) => EdgeInsets.all(MediaQuery.of(context).size.width * 0.04);

  // Тени остаются без изменений
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
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
      height: CalendarStyles.headerHeight(context),
      decoration: BoxDecoration(
        color: CalendarStyles.primaryColor,
        borderRadius: CalendarStyles.headerBorderRadius(context),
        boxShadow: [CalendarStyles.headerShadow],
      ),
      padding: CalendarStyles.headerPadding(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${_selectedDate.year}',
            style: TextStyle(
              fontSize: CalendarStyles.yearFontSize(context),
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(
              _showYearPicker ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.white,
              size: MediaQuery.of(context).size.width * 0.1,
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
        height: CalendarStyles.monthHeaderHeight(context),
        margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
        decoration: BoxDecoration(
          color: CalendarStyles.monthHeaderColor,
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
          boxShadow: [CalendarStyles.monthHeaderShadow],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              currentMonth!,
              style: TextStyle(
                color: CalendarStyles.secondaryColor,
                fontSize: CalendarStyles.monthNameFontSize(context),
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
      height: CalendarStyles.calendarHeight(context),
      margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
      padding: CalendarStyles.calendarPadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.04),
        boxShadow: [CalendarStyles.calendarShadow],
      ),
      child: Column(
        children: [
          // Фиксированные дни недели
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buildDayLabels(),
          ),
          const SizedBox(height: 8), // Можно регулировать отступ между днями недели и числами
          // Скроллимые даты
          Expanded(
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 7,
              mainAxisSpacing: MediaQuery.of(context).size.width * 0.02,
              crossAxisSpacing: MediaQuery.of(context).size.width * 0.02,
              children: _buildCalendarDays(_selectedDate, tasks), // только числа месяца + пустые ячейки
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
        style: TextStyle(
          color: CalendarStyles.dayLabelColor,
          fontWeight: FontWeight.bold,
          fontSize: CalendarStyles.dayLabelFontSize(context),
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
      child: Container(
        padding: EdgeInsets.only(left: 0, bottom: MediaQuery.of(context).size.width * 0.02),
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
                fontSize: CalendarStyles.dayNumberFontSize(context),
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (hasTasks)
              Positioned(
                top: 0.1,
                right: MediaQuery.of(context).size.width * 0.01,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.02,
                  height: MediaQuery.of(context).size.width * 0.02,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    final tasks = Provider.of<TaskProvider>(context).tasks;
    final filteredTasks = tasks.where((t) {
      final deadline = _safeParseDate(t.endPoint);
      return deadline != null && DateUtils.isSameDay(_selectedDate, deadline);
    }).toList();

    if (filteredTasks.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: Text('Нет задач на выбранную дату'),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.35,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
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
      height: MediaQuery.of(context).size.height * 0.12,
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
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
                                style: TextStyle(
                                  fontSize: TaskScreenStyles.taskNameFontSize(
                                    context,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  color: TaskScreenStyles.primaryColor,
                                  decoration:
                                  task.state == 'Completed'
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                                    style: TextStyle(
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
                                        style: TextStyle(
                                          fontSize: TaskScreenStyles.dateFontSize(context) * 0.9,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    if (endPoint != null)
                                      Text(
                                        'До ${DateFormat('dd.MM').format(
                                            endPoint)}',
                                        style: TextStyle(
                                          fontSize: TaskScreenStyles
                                              .dateFontSize(context) * 0.9,
                                          color: isOverdue
                                              ? Colors.red[400]
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    Text(
                                      DateFormat('HH:mm').format(
                                          endPoint!),
                                      style: TextStyle(
                                        fontSize: TaskScreenStyles
                                            .dateFontSize(context) * 0.9,
                                        color: isOverdue
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
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.025),
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
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.03,
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
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.06),
            Icon(
              auth.isAuthorized ? Icons.group : Icons.lock,
              size: MediaQuery.of(context).size.width * 0.15,
              color: const Color(0xFF937DF3),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          ],
        ),
      ),
    );
  }

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
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$currentYear',
                    style: TextStyle(
                      fontSize: CalendarStyles.yearFontSize(context),
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _showYearPicker ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: MediaQuery.of(context).size.width * 0.12,
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
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  crossAxisCount: 3,
                  childAspectRatio: 1.1,
                  mainAxisSpacing: MediaQuery.of(context).size.width * 0.01,
                  crossAxisSpacing: MediaQuery.of(context).size.width * 0.01,
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
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
        color: isSelectedMonth ? CalendarStyles.secondaryColor.withOpacity(0.5) : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
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
                fontSize: CalendarStyles.titleMonthCalendarSize(context),
                fontWeight: FontWeight.bold,
                color: isCurrentMonth
                    ? CalendarStyles.todayMonthColor
                    : (isSelectedMonth ? Colors.white : Colors.white.withOpacity(0.8)),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.005),
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
                fontSize: MediaQuery.of(context).size.width * 0.025,
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