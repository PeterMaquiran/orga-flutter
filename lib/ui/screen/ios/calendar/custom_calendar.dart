import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'calendar_date_utils.dart';

const List<String> kOrgaMonthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// Month grid with prev/next, weekday headers, in/out month days.
class OrgaMonthCalendar extends StatelessWidget {
  const OrgaMonthCalendar({
    super.key,
    required this.displayedMonth,
    required this.selected,
    required this.onSelectDay,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  final DateTime displayedMonth;
  final DateTime selected;
  final ValueChanged<DateTime> onSelectDay;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final y = displayedMonth.year;
    final m = displayedMonth.month;
    final daysInMonth = DateUtils.getDaysInMonth(y, m);
    final offset = DateUtils.firstDayOffset(y, m, loc);
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);

    final List<DateTime> cells = [];
    final prevMonthLastDay = DateTime(y, m, 0).day;

    // 1️⃣ Previous month days for offset
    for (int i = 0; i < offset; i++) {
      final day = prevMonthLastDay - offset + i + 1;
      cells.add(DateTime(y, m - 1, day));
    }

    // 2️⃣ Current month days
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(y, m, d));
    }

    // 3️⃣ Calculate exact rows & trailing days
    final totalCells = cells.length;
    final rowCount = (totalCells / 7).ceil();
    final targetCellCount = rowCount * 7;
    for (int i = 0; i < targetCellCount - totalCells; i++) {
      cells.add(DateTime(y, m + 1, i + 1));
    }

    // Colors
    final labelColor = CupertinoColors.label.resolveFrom(context);
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);
    final active = CupertinoColors.activeBlue.resolveFrom(context);

    const double gridRowExtent = 35;
    final int gridRows = cells.length ~/ 7;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Month header with prev/next (tight vertical insets — CupertinoButton defaults add a lot of top air)
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 2),
          child: Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: onPrevMonth,
                child: Icon(
                  CupertinoIcons.chevron_left,
                  size: 20,
                  color: active,
                ),
              ),
              Expanded(
                child: Text(
                  '${kOrgaMonthNames[m - 1]} $y',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.41,
                    color: labelColor,
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: onNextMonth,
                child: Icon(
                  CupertinoIcons.chevron_right,
                  size: 20,
                  color: active,
                ),
              ),
            ],
          ),
        ),
        // Weekday headers — minimal gap above the number grid
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              for (int i = 0; i < 7; i++)
                Expanded(
                  child: Center(
                    child: Text(
                      loc.narrowWeekdays[(i + loc.firstDayOfWeekIndex) % 7],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.06,
                        color: secondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: gridRows * gridRowExtent,
          child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
              mainAxisExtent: gridRowExtent,
            ),
            itemCount: cells.length,
            itemBuilder: (context, index) {
              final date = cells[index];
              final inMonth = date.month == m && date.year == y;
              final isSelected = DateUtils.isSameDay(date, selected);
              final isToday = DateUtils.isSameDay(date, todayDay);

              return _MonthDayCell(
                date: date,
                inMonth: inMonth,
                isSelected: isSelected,
                isToday: isToday,
                onTap: () => onSelectDay(OrgaCalendarDateUtils.dateOnly(date)),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MonthDayCell extends StatelessWidget {
  const _MonthDayCell({
    required this.date,
    required this.inMonth,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final bool inMonth;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = CupertinoColors.activeBlue.resolveFrom(context);
    final label = CupertinoColors.label.resolveFrom(context);
    final tertiary = CupertinoColors.tertiaryLabel.resolveFrom(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected ? active.withValues(alpha: 0.18) : Colors.transparent,
          shape: BoxShape.circle,
          border: isToday && !isSelected
              ? Border.all(color: active.withValues(alpha: 0.55), width: 1)
              : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              letterSpacing: -0.35,
              color: inMonth
                  ? (isSelected ? active : label)
                  : tertiary.withValues(alpha: 0.55),
            ),
          ),
        ),
      ),
    );
  }
}