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

/// Dummy month calendar for demonstration
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
    final daysInMonth = DateUtils.getDaysInMonth(displayedMonth.year, displayedMonth.month);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(onPressed: onPrevMonth, icon: const Icon(Icons.arrow_back)),
            Text("${displayedMonth.month}/${displayedMonth.year}"),
            IconButton(onPressed: onNextMonth, icon: const Icon(Icons.arrow_forward)),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(daysInMonth, (i) {
            final day = i + 1;
            final date = DateTime(displayedMonth.year, displayedMonth.month, day);
            final isSelected = date.year == selected.year &&
                date.month == selected.month &&
                date.day == selected.day;
            return GestureDetector(
              onTap: () => onSelectDay(date),
              child: Container(
                width: 35,
                height: 35,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemBackground,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF3C3C43).withOpacity(0.12),
                  ),
                ),
                child: Text(
                  "$day",
                  style: TextStyle(
                    color: isSelected ? Colors.white : CupertinoColors.label.resolveFrom(context),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

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
  late DateTime _selected;
  late DateTime _displayedMonth;
  late bool _monthView;
  bool _didAlignWeekPage = false;

  @override
  void initState() {
    super.initState();
    _selected = OrgaCalendarDateUtils.dateOnly(widget.selected);
    _displayedMonth = DateTime(_selected.year, _selected.month);
    _monthView = widget.monthViewNotifier?.value ?? false;

    // Listen for external monthView changes
    widget.monthViewNotifier?.addListener(() {
      if (!mounted) return;
      setState(() => _monthView = widget.monthViewNotifier!.value);
      if (!_monthView) _jumpToSelectedWeek();
    });

    _pageController = PageController(initialPage: _virtualCenter);
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
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  void _setMonthView(bool month) {
    if (_monthView == month) return;
    setState(() => _monthView = month);
    widget.monthViewNotifier?.value = month;
    if (!month) _jumpToSelectedWeek();
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
              onSelectDay: _emit,
              onPrevMonth: () {
                setState(() {
                  _displayedMonth = DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month - 1,
                  );
                });
              },
              onNextMonth: () {
                setState(() {
                  _displayedMonth = DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month + 1,
                  );
                });
              },
            ),
          ),
        ),
      ],
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