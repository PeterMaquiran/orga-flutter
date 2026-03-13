import 'package:flutter/material.dart';
import '../../../../shared/theme/appColors.dart';

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
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40), // space to balance the icon
              ValueListenableBuilder<DateTime>(
                valueListenable: focusedDate,
                builder: (context, date, _) {
                  final String yearStr = date.year != today.year ? ", ${date.year}" : "";
                  final String month = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][date.month - 1];
                  return Text("$month ${date.day}$yearStr", style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 18));
                },
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black.withOpacity(0.05),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {},
                  icon: const Icon(
                    Icons.add,
                    size: 23,
                    color: Colors.blueGrey,
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 70,
          child: PageView.builder(
            controller: controller,
            onPageChanged: (i) => focusedDate.value = _getWeekForIndex(i, today).last,
            itemBuilder: (context, index) {
              final week = _getWeekForIndex(index, today);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
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
        color: isToday ? AppColors.tertiary.withOpacity(0.05) : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isToday ? AppColors.secondary.withOpacity(0.1) : Colors.white.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][date.weekday % 7],
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isToday ? AppColors.tertiary : Colors.black54)),
          const SizedBox(height: 4),
          Text(date.day.toString(),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isToday ? AppColors.tertiary : AppColors.background.withOpacity(0.3))),
        ],
      ),
    );
  }
}