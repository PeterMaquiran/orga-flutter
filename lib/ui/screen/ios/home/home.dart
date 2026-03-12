import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- SCREEN 1: HOME WITH WEEKLY HORIZONTAL SLIDER CALENDAR ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});


  String _getMonthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }

  // Generate a list of dates for the current month
  List<DateTime> _generateMonthDates(DateTime date) {
    final daysInMonth = date.day;
    return List.generate(daysInMonth, (i) => DateTime(date.year, date.month, i + 1));
  }

  // Split the month dates into weeks (7 days per week)
  List<List<DateTime>> _splitIntoWeeks(List<DateTime> monthDates, DateTime date) {

    List<List<DateTime>> weeks = [];

    if(monthDates.first.weekday != 1) { // add messing days on the first week
      final PrewMonth = DateTime(date.year, date.month , 0); // last day of preview month
      var daysOfMonth = _generateMonthDates(PrewMonth);
      monthDates.insertAll(0, daysOfMonth.sublist(daysOfMonth.length  - ( monthDates.first.weekday  + 7 -1) ));
    } else {
      final PrewMonth = DateTime(date.year, date.month , 0); // last day of preview month
      var daysOfMonth = _generateMonthDates(PrewMonth);
      monthDates.insertAll(0, daysOfMonth.sublist(daysOfMonth.length  - ( 7 ) )); // add the whole week of the last month
    }

    for (var i = 0; i < monthDates.length; i += 7) {
      weeks.add(monthDates.sublist(i, i + 7 > monthDates.length ? monthDates.length : i + 7));
    }

    final nextMonth = DateTime(date.year, date.month+2, 0);
    var nextMonthDays =_generateMonthDates(nextMonth);
    var daysInLastWeekOfMonth = weeks.last.length;

    if(weeks.last.length >= 1 && weeks.last.length < 7) {
      weeks.last.addAll(nextMonthDays.take(7 - weeks.last.length )); // complete the week
      weeks.add(nextMonthDays.sublist((daysInLastWeekOfMonth -1), (daysInLastWeekOfMonth -1)+7)); // add first week of the month
    } else {
      weeks.add(nextMonthDays.sublist(0, 7)); // add first week of the next month
    }

    return weeks;
  }

  @override
  Widget build(BuildContext context) {

    final today = DateTime.now();
    final monthDates = _generateMonthDates(today);
    final weeks = _splitIntoWeeks(monthDates, today);

    int? weekIndex = weeks.indexWhere((week) =>
        week.any((date) =>
        date.year == DateTime.now().year &&
            date.month == DateTime.now().month &&
            date.day == DateTime.now().day
        )
    );

    PageController controller = PageController();
    controller = PageController(initialPage: weekIndex);
    // Notifier para o último dia da semana visível
    final ValueNotifier<DateTime> focusedDate = ValueNotifier(weeks[weekIndex].last);
    controller.addListener(() {
      print("Current page: ${controller.page!.round() + 1} ${weeks.length}");
      int currentPage = controller.page!.round();
      if (currentPage >= 0 && currentPage < weeks.length) {
        // Atualiza apenas o Notifier, sem resetar o BuildContext
        focusedDate.value = weeks[currentPage].last;
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF), Color(0xFFDEE2E6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Home",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    today.toIso8601String(),
                    style: TextStyle(fontWeight: FontWeight.w300),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Empurra os itens para as bordas
                  children: [
                    const Icon(
                      Icons.arrow_back_ios_new_rounded, // Seta mais linear/moderna
                      size: 22,
                    ),
                    // O Widget que atualiza sozinho
                    ValueListenableBuilder<DateTime>(
                      valueListenable: focusedDate,
                      builder: (context, date, _) {
                        return Text(
                          "${_getMonthName(date.month)} ${date.day}",
                          style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 18),
                        );
                      },
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 22,
                    ),
                  ],
                ),
              ),

              //const SizedBox(height: 20),

              // --- Weekly Slider Calendar ---
              SizedBox(
                height: 90,
                child: PageView.builder(
                  itemCount: weeks.length,
                  controller: controller,
                  itemBuilder: (context, weekIndex) {
                    final week = weeks[weekIndex];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: week.map((date) {
                          final isToday = date.day == today.day;

                          return Container(
                            width: 50,
                            decoration: BoxDecoration(
                              color: isToday
                                  ? Colors.blueAccent.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.2), width: 0.5),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                                  [date.weekday % 7],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isToday ? Colors.blueAccent : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  date.day.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isToday ? Colors.blueAccent : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}