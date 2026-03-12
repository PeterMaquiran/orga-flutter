import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Starting point for the infinite calculation
  static const int _virtualCenter = 10000;

  // Calculates the week based on the PageView index
  List<DateTime> _getWeekForIndex(int index, DateTime today) {
    int weekOffset = index - _virtualCenter;

    // Finds the first day of the current week (Monday)
    // Use (today.weekday % 7) if you want the week to start on Sunday
    DateTime firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));

    // Calculates the start of the target week
    DateTime startOfTargetWeek = firstDayOfWeek.add(Duration(days: weekOffset * 7));

    return List.generate(7, (i) => startOfTargetWeek.add(Duration(days: i)));
  }

  String _getMonthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final PageController controller = PageController(initialPage: _virtualCenter);

    // Notifier for the top text (Initializes with the last day of the current week)
    final ValueNotifier<DateTime> focusedDate = ValueNotifier(_getWeekForIndex(_virtualCenter, today).last);

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
              const SizedBox(height: 10),

              // --- HEADER WITH ARROWS AND DATE ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                    ),
                    ValueListenableBuilder<DateTime>(
                      valueListenable: focusedDate,
                      builder: (context, date, _) {
                        final int currentYear = DateTime.now().year;
                        // Condition: only show year if it's not the current one
                        final String yearString = date.year != currentYear ? ", ${date.year}" : "";

                        return Text(
                          "${_getMonthName(date.month)} ${date.day}$yearString",
                          style: const TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 18,
                            letterSpacing: 0.5,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      onPressed: () => controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 22),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // --- INFINITE WEEKLY CALENDAR SLIDER ---
              SizedBox(
                height: 90,
                child: PageView.builder(
                  controller: controller,
                  onPageChanged: (index) {
                    // Update the top header with the last day of the visible week
                    focusedDate.value = _getWeekForIndex(index, today).last;
                  },
                  itemBuilder: (context, index) {
                    final week = _getWeekForIndex(index, today);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: week.map((date) {
                          final isToday = date.day == today.day &&
                              date.month == today.month &&
                              date.year == today.year;

                          return _buildDayCard(date, isToday);
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

  // Day Card Widget (Glassmorphism Visual)
  Widget _buildDayCard(DateTime date, bool isToday) {
    return Container(
      width: 48,
      decoration: BoxDecoration(
        color: isToday ? Colors.blueAccent.withOpacity(0.2) : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday ? Colors.blueAccent.withOpacity(0.3) : Colors.white.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][date.weekday % 7],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isToday ? Colors.blueAccent : Colors.black54,
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
  }
}