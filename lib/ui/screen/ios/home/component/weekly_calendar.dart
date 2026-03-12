import 'package:flutter/material.dart';

// --- EXTRACTED CALENDAR COMPONENT ---
class InfiniteWeeklyCalendar extends StatelessWidget {
  const InfiniteWeeklyCalendar({super.key});

  static const int _virtualCenter = 10000;

  List<DateTime> _getWeekForIndex(int index, DateTime today) {
    int weekOffset = index - _virtualCenter;
    DateTime firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));
    DateTime startOfTargetWeek = firstDayOfWeek.add(Duration(days: weekOffset * 7));
    return List.generate(7, (i) => startOfTargetWeek.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final PageController controller = PageController(initialPage: _virtualCenter);
    final ValueNotifier<DateTime> focusedDate = ValueNotifier(_getWeekForIndex(_virtualCenter, today).last);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
              ),
              ValueListenableBuilder<DateTime>(
                valueListenable: focusedDate,
                builder: (context, date, _) {
                  final String yearStr = date.year != today.year ? ", ${date.year}" : "";
                  final String month = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][date.month - 1];
                  return Text("$month ${date.day}$yearStr", style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 18));
                },
              ),
              IconButton(
                onPressed: () => controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 22),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 90,
          child: PageView.builder(
            controller: controller,
            onPageChanged: (i) => focusedDate.value = _getWeekForIndex(i, today).last,
            itemBuilder: (context, index) {
              final week = _getWeekForIndex(index, today);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: week.map((date) {
                    final isToday = date.day == today.day && date.month == today.month && date.year == today.year;
                    return _buildDayCard(date, isToday);
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayCard(DateTime date, bool isToday) {
    return Container(
      width: 48,
      decoration: BoxDecoration(
        color: isToday ? Colors.blueAccent.withOpacity(0.2) : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isToday ? Colors.blueAccent.withOpacity(0.3) : Colors.white.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][date.weekday % 7],
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isToday ? Colors.blueAccent : Colors.black54)),
          const SizedBox(height: 4),
          Text(date.day.toString(),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isToday ? Colors.blueAccent : Colors.black87)),
        ],
      ),
    );
  }
}