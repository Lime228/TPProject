import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();
  bool showMonthPicker = false;

  void _selectMonth(int month) {
    setState(() {
      selectedDate = DateTime(selectedDate.year, month);
      showMonthPicker = false;
    });
  }

  List<Widget> _buildDayLabels() {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days
        .map((day) => Center(
      child: Text(
        day,
        style: const TextStyle(
          color: Color(0xFF937DF3),
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
      ),
    ))
        .toList();
  }

  List<Widget> _buildCalendarDays(DateTime month) {
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
      final isToday = DateTime.now().day == day &&
          DateTime.now().month == month.month &&
          DateTime.now().year == month.year;
      final isSelected = selectedDate.day == day &&
          selectedDate.month == month.month &&
          selectedDate.year == month.year;

      BoxDecoration decoration = const BoxDecoration();
      TextStyle textStyle =
      const TextStyle(color: Color(0xFF666666), fontSize: 25);

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
              style: BorderStyle.solid),
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
        onTap: () {
          setState(() {
            selectedDate = date;
          });
        },
        child: Container(
          alignment: Alignment.center,
          decoration: decoration,
          child: Text(
            '$day',
            style: textStyle,
          ),
        ),
      ));
    }

    return dayWidgets;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final currentYear = selectedDate.year;
    final currentMonth =
    toBeginningOfSentenceCase(DateFormat.MMMM('ru').format(selectedDate));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 0),
              Padding(
                padding: EdgeInsets.zero,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      showMonthPicker = !showMonthPicker;
                    });
                  },
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
                    padding:
                    const EdgeInsets.only(left: 24, right: 24, top: 35),
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
              ),
              const SizedBox(height: 20),
              if (!showMonthPicker) ...[
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

                  //TODO: слепить блок с календарем и с месяцев наложением в один блок
                  child: Text(
                    currentMonth,
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
                            children: _buildCalendarDays(selectedDate),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Заглушка для задач
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        Text(
                          'Упс(',
                          style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF666666),
                          ),
                        ),
                        Text(
                          'Свои задачи можно просматривать',
                          style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF666666),
                          ),
                        ),
                        Text(
                          'только авторизовавшись',
                          style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //  Здесь после авторизации отобразятся карточки задач
                // TODO: если пользователь авторизован, подгрузить задачи из API и отобразить карточки:
                //  Вызов API для получения TaskByCustomerResponse
                //  Отображение списка задач с названием, дедлайном и описанием
              ] else ...[
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
                                .format(DateTime(currentYear, index + 1)));
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
