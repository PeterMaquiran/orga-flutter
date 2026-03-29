import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Utilities for date handling
class OrgaCalendarDateUtils {
  /// Returns a DateTime without time
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Returns start of the week according to locale
  static DateTime startOfWeek(DateTime date, MaterialLocalizations loc) {
    final weekday = date.weekday; // 1 = Mon, 7 = Sun
    return date.subtract(Duration(days: weekday % 7));
  }

  /// Difference in weeks between two dates
  static int weekDifference(DateTime from, DateTime to, MaterialLocalizations loc) {
    final diff = dateOnly(to).difference(dateOnly(from)).inDays;
    return (diff / 7).floor();
  }
}

const List<String> _monthNames = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];

/// Custom calendar with week/month toggle
class OrgaWeekMonthCalendar extends StatefulWidget {
  const OrgaWeekMonthCalendar({
    super.key,
    required this.selected,
    required this.onDateChanged,
    this.monthViewNotifier,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onDateChanged;

  /// External notifier to control week/month view
  final ValueNotifier<bool>? monthViewNotifier;

  @override
  State<OrgaWeekMonthCalendar> createState() => _OrgaWeekMonthCalendarState();
}

class _OrgaWeekMonthCalendarState extends State<OrgaWeekMonthCalendar> {
  static const int _virtualCenter = 10000;
  static const Duration _kTransition = Duration(milliseconds: 400);

  late PageController _pageController;
  late PageController _monthPageController;
  late DateTime _selected;
  late DateTime _displayedMonth;
  late DateTime _monthAnchor;
  late bool _monthView;
  int _monthPageIndex = _virtualCenter;
  bool _didAlignWeekPage = false;

  @override
  void initState() {
    super.initState();
    _selected = OrgaCalendarDateUtils.dateOnly(widget.selected);
    _displayedMonth = DateTime(_selected.year, _selected.month);
    _monthAnchor = _displayedMonth;
    _monthView = widget.monthViewNotifier?.value ?? false;

    // Listen for external monthView changes
    widget.monthViewNotifier?.addListener(() {
      if (!mounted) return;
      setState(() => _monthView = widget.monthViewNotifier!.value);
      if (!_monthView) _jumpToSelectedWeek();
    });

    _pageController = PageController(initialPage: _virtualCenter);
    _monthPageController = PageController(initialPage: _virtualCenter);
  }

  void _jumpToSelectedWeek() {
    final loc = MaterialLocalizations.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _pageController.jumpToPage(_pageForSelected(loc));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didAlignWeekPage) return;
    _didAlignWeekPage = true;
    _jumpToSelectedWeek();
  }

  @override
  void didUpdateWidget(OrgaWeekMonthCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = OrgaCalendarDateUtils.dateOnly(widget.selected);
    if (next != _selected) {
      setState(() {
        _selected = next;
        _displayedMonth = DateTime(_selected.year, _selected.month);
      });
      if (!_monthView) _jumpToSelectedWeek();
      _syncMonthPage(animate: false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _monthPageController.dispose();
    super.dispose();
  }

  DateTime _monthForPage(int index) {
    final offset = index - _virtualCenter;
    return DateTime(_monthAnchor.year, _monthAnchor.month + offset);
  }

  int _pageForMonth(DateTime month) {
    return _virtualCenter +
        (month.year - _monthAnchor.year) * 12 +
        (month.month - _monthAnchor.month);
  }

  void _syncMonthPage({required bool animate}) {
    if (!_monthPageController.hasClients) return;
    final target = _pageForMonth(_displayedMonth);
    _monthPageIndex = target;
    if (animate) {
      _monthPageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _monthPageController.jumpToPage(target);
    }
  }

  void _goToMonth(int delta) {
    final next = DateTime(_displayedMonth.year, _displayedMonth.month + delta);
    setState(() {
      _displayedMonth = next;
      _monthPageIndex = _pageForMonth(next);
    });
    if (_monthPageController.hasClients) {
      _monthPageController.animateToPage(
        _monthPageIndex,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  List<DateTime> _weekDaysForPage(int index, MaterialLocalizations loc) {
    final today = DateTime.now();
    final anchorWeekStart = OrgaCalendarDateUtils.startOfWeek(
      OrgaCalendarDateUtils.dateOnly(today),
      loc,
    );
    final offset = index - _virtualCenter;
    final weekStart = anchorWeekStart.add(Duration(days: offset * 7));
    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  int _pageForSelected(MaterialLocalizations loc) {
    return _virtualCenter +
        OrgaCalendarDateUtils.weekDifference(
          DateTime.now(),
          _selected,
          loc,
        );
  }

  void _emit(DateTime d) {
    final day = OrgaCalendarDateUtils.dateOnly(d);
    setState(() => _selected = day);
    widget.onDateChanged(day);
  }

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final today = DateTime.now();
    const days = ["S", "M", "T", "W", "T", "F", "S"];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Weekday header
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              final isSunday = day == "S";
              return SizedBox(
                width: 35,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSunday
                        ? CupertinoColors.activeBlue.resolveFrom(context)
                        : CupertinoColors.tertiaryLabel.resolveFrom(context),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Week/Month toggle
        // Padding(
        //   padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
        //   child: CupertinoSlidingSegmentedControl<bool>(
        //     groupValue: _monthView,
        //     children: const {
        //       false: Padding(
        //         padding: EdgeInsets.symmetric(vertical: 10),
        //         child: Text('Week'),
        //       ),
        //       true: Padding(
        //         padding: EdgeInsets.symmetric(vertical: 10),
        //         child: Text('Month'),
        //       ),
        //     },
        //     onValueChanged: (v) {
        //       if (v != null) _setMonthView(v);
        //     },
        //   ),
        // ),
        // Calendar views
        ClipRect(
          child: AnimatedCrossFade(
            duration: _kTransition,
            reverseDuration: _kTransition,
            sizeCurve: Curves.easeInOutCubicEmphasized,
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeInCubic,
            alignment: Alignment.topCenter,
            crossFadeState:
            _monthView ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: _WeekStrip(
              today: today,
              selected: _selected,
              pageController: _pageController,
              weekDaysForPage: (i) => _weekDaysForPage(i, loc),
              onWeekPageChanged: (i) {
                final week = _weekDaysForPage(i, loc);
                DateTime match;
                try {
                  match = week.firstWhere((d) => d.weekday == _selected.weekday);
                } catch (_) {
                  match = week.first;
                }
                final day = OrgaCalendarDateUtils.dateOnly(match);
                if (day == _selected) return;
                _emit(day);
              },
              onDayTap: _emit,
            ),
            secondChild: OrgaMonthCalendar(
              displayedMonth: _displayedMonth,
              selected: _selected,
              monthPageController: _monthPageController,
              onSelectDay: (d) {
                _emit(d);
                final pickedMonth = DateTime(d.year, d.month);
                if (pickedMonth != _displayedMonth) {
                  setState(() => _displayedMonth = pickedMonth);
                  _syncMonthPage(animate: true);
                }
              },
              onPageChanged: (i) {
                final month = _monthForPage(i);
                setState(() {
                  _monthPageIndex = i;
                  _displayedMonth = DateTime(month.year, month.month);
                });
              },
              monthForPage: _monthForPage,
              onPrevMonth: () => _goToMonth(-1),
              onNextMonth: () => _goToMonth(1),
            ),
          ),
        ),
      ],
    );
  }
}

class OrgaMonthCalendar extends StatelessWidget {
  const OrgaMonthCalendar({
    super.key,
    required this.displayedMonth,
    required this.selected,
    required this.monthPageController,
    required this.onSelectDay,
    required this.onPageChanged,
    required this.monthForPage,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  final DateTime displayedMonth;
  final DateTime selected;
  final PageController monthPageController;
  final ValueChanged<DateTime> onSelectDay;
  final ValueChanged<int> onPageChanged;
  final DateTime Function(int) monthForPage;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  int _weekCountForMonth(DateTime month) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    final totalCells = firstWeekday + daysInMonth;
    return (totalCells / 7).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final active = CupertinoColors.activeBlue.resolveFrom(context);
    final label = CupertinoColors.label.resolveFrom(context);
    const double gridRowExtent = 35;
    final weekCount = _weekCountForMonth(displayedMonth);
    final gridHeight = weekCount * gridRowExtent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: onPrevMonth,
                child: Icon(CupertinoIcons.chevron_left, size: 20, color: active),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Text(
                    '${_monthNames[displayedMonth.month - 1]} ${displayedMonth.year}',
                    key: ValueKey('${displayedMonth.year}-${displayedMonth.month}'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.41,
                      color: label,
                    ),
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: onNextMonth,
                child: Icon(CupertinoIcons.chevron_right, size: 20, color: active),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: gridHeight,
            child: PageView.builder(
              controller: monthPageController,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                return _MonthGrid(
                  month: monthForPage(index),
                  selected: selected,
                  onSelectDay: onSelectDay,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.onSelectDay,
  });

  final DateTime month;
  final DateTime selected;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final y = month.year;
    final m = month.month;
    final daysInMonth = DateUtils.getDaysInMonth(y, m);
    final firstWeekday = DateTime(y, m, 1).weekday % 7;
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);

    final List<DateTime> cells = [];
    final prevMonthLastDay = DateTime(y, m, 0).day;
    for (int i = 0; i < firstWeekday; i++) {
      final day = prevMonthLastDay - firstWeekday + i + 1;
      cells.add(DateTime(y, m - 1, day));
    }
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(y, m, d));
    }
    while (cells.length % 7 != 0) {
      cells.add(DateTime(y, m + 1, cells.length - (firstWeekday + daysInMonth) + 1));
    }

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 35,
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
    final labelColor = CupertinoColors.label.resolveFrom(context);
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
              letterSpacing: -0.2,
              color: inMonth ? (isSelected ? active : labelColor) : tertiary,
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.today,
    required this.selected,
    required this.pageController,
    required this.weekDaysForPage,
    required this.onWeekPageChanged,
    required this.onDayTap,
  });

  final DateTime today;
  final DateTime selected;
  final PageController pageController;
  final List<DateTime> Function(int index) weekDaysForPage;
  final ValueChanged<int> onWeekPageChanged;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 35,
        child: PageView.builder(
          controller: pageController,
          onPageChanged: onWeekPageChanged,
          itemBuilder: (context, index) {
            final week = weekDaysForPage(index);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: week.map((date) {
                final isToday = date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;
                final isSelected = date.year == selected.year &&
                    date.month == selected.month &&
                    date.day == selected.day;
                return _WeekDayCell(
                  date: date,
                  isToday: isToday,
                  isSelected: isSelected,
                  onTap: () => onDayTap(date),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class _WeekDayCell extends StatelessWidget {
  const _WeekDayCell({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = CupertinoColors.activeBlue.resolveFrom(context);
    final labelColor = CupertinoColors.label.resolveFrom(context);
    final highlight = isToday || isSelected;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onTap,
      child: Container(
        width: 35,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF3C3C43).withOpacity(0.12),
            width: 1,
          ),
          color: isToday
              ? active.withOpacity(0.05)
              : CupertinoColors.systemBackground.resolveFrom(context),
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: highlight ? active : labelColor,
            ),
          ),
        ),
      ),
    );
  }
}