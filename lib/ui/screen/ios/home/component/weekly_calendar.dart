import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InfiniteWeeklyCalendar extends StatelessWidget {
  const InfiniteWeeklyCalendar({super.key});

  static const int _virtualCenter = 10000;

  List<DateTime> _getWeekForIndex(int index, DateTime today) {
    final int weekOffset = index - _virtualCenter;
    final DateTime firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final DateTime startOfTargetWeek = firstDayOfWeek.add(Duration(days: weekOffset * 7));
    return List.generate(7, (i) => startOfTargetWeek.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final PageController controller = PageController(initialPage: _virtualCenter);
    final ValueNotifier<DateTime> focusedDate = ValueNotifier(_getWeekForIndex(_virtualCenter, today).last);
    final Color iconColor = CupertinoColors.secondaryLabel.resolveFrom(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF3C3C43).withValues(alpha: 0.12),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  child: Icon(
                    CupertinoIcons.chart_bar_alt_fill,
                    size: 22,
                    color: iconColor,
                  ),
                ),
              ),
              ValueListenableBuilder<DateTime>(
                valueListenable: focusedDate,
                builder: (context, date, _) {
                  final String yearStr = date.year != today.year ? ', ${date.year}' : '';
                  final String month = [
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sep',
                    'Oct',
                    'Nov',
                    'Dec',
                  ][date.month - 1];
                  return Text(
                    '$month ${date.day}$yearStr',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      letterSpacing: -0.41,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  );
                },
              ),
              Container(
                width: 100,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFF3C3C43).withValues(alpha: 0.12),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        child: Icon(
                          CupertinoIcons.add,
                          size: 22,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        child: Icon(
                          CupertinoIcons.slider_horizontal_3,
                          size: 22,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: week.map((date) {
                  final isToday =
                      date.day == today.day && date.month == today.month && date.year == today.year;
                  return _buildDayCard(context, date, isToday);
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayCard(BuildContext context, DateTime date, bool isToday) {
    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final label = labels[date.weekday % 7];
    final active = CupertinoColors.activeBlue.resolveFrom(context);
    final labelColor = CupertinoColors.label.resolveFrom(context);
    final tertiary = CupertinoColors.tertiaryLabel.resolveFrom(context);

    return Container(
      width: 48,
      decoration: BoxDecoration(
        color: isToday
            ? active.withValues(alpha: 0.05)
            : CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.06,
              color: isToday ? active : tertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date.day.toString(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.08,
              color: isToday ? active : labelColor,
            ),
          ),
        ],
      ),
    );
  }
}
