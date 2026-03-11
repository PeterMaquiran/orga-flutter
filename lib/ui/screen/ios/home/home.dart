import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- SCREEN 1: HOME WITH WEEKLY HORIZONTAL SLIDER CALENDAR ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Generate a list of dates for the current month
  List<DateTime> _generateMonthDates(DateTime date) {
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    return List.generate(daysInMonth, (i) => DateTime(date.year, date.month, i + 1));
  }

  // Split the month dates into weeks (7 days per week)
  List<List<DateTime>> _splitIntoWeeks(List<DateTime> monthDates, DateTime date) {
    List<List<DateTime>> weeks = [];
    for (var i = 0; i < monthDates.length; i += 7) {
      weeks.add(monthDates.sublist(i, i + 7 > monthDates.length ? monthDates.length : i + 7));
    }

    print("last week of the month has days:${weeks.last.length} ${weeks.last.last.day}");

    return weeks;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final monthDates = _generateMonthDates(today);
    final weeks = _splitIntoWeeks(monthDates, today);
    PageController controller = PageController();


    @override
    void initState() {
      controller.addListener(() {
        print("Current page: ${controller.page}");
      });
    }

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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Home",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              // --- Weekly Slider Calendar ---
              SizedBox(
                height: 90,
                child: PageView.builder(
                  itemCount: weeks.length,
                  controller: PageController(viewportFraction: 1),
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