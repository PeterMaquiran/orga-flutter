import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'calendar_date_utils.dart';
import 'custom_calendar.dart';

/// Custom calendar with **Week** (paged strip) and **Month** (grid) modes and a smooth transition.
class OrgaWeekMonthCalendar extends StatefulWidget {
  const OrgaWeekMonthCalendar({
    super.key,
    required this.selected,
    required this.onDateChanged,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onDateChanged;

  @override
  State<OrgaWeekMonthCalendar> createState() => _OrgaWeekMonthCalendarState();
}

class _OrgaWeekMonthCalendarState extends State<OrgaWeekMonthCalendar> {
  static const int _virtualCenter = 10000;
  /// Cross-fade + shared size animation (replaces separate Size + Switcher for smoother motion).
  static const Duration _kTransition = Duration(milliseconds: 400);

  late PageController _pageController;
  late DateTime _selected;
  late DateTime _displayedMonth;
  bool _monthView = false;
  bool _didAlignWeekPage = false;

  @override
  void initState() {
    super.initState();
    _selected = OrgaCalendarDateUtils.dateOnly(widget.selected);
    _displayedMonth = DateTime(_selected.year, _selected.month);
    _pageController = PageController(initialPage: _virtualCenter);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didAlignWeekPage) return;
    _didAlignWeekPage = true;
    final loc = MaterialLocalizations.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _pageController.jumpToPage(_pageForSelected(loc));
    });
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
      if (!_monthView) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _pageController.jumpToPage(
            _pageForSelected(MaterialLocalizations.of(context)),
          );
        });
      }
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
    if (!month) {
      final loc = MaterialLocalizations.of(context);
      _pageController.jumpToPage(_pageForSelected(loc));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final today = DateTime.now();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
          child: CupertinoSlidingSegmentedControl<bool>(
            groupValue: _monthView,
            children: const {
              false: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('Week'),
              ),
              true: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('Month'),
              ),
            },
            onValueChanged: (v) {
              if (v != null) _setMonthView(v);
            },
          ),
        ),
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
                  match = week.firstWhere(
                    (d) => d.weekday == _selected.weekday,
                  );
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
        height: 76,
        child: PageView.builder(
          controller: pageController,
          onPageChanged: onWeekPageChanged,
          itemBuilder: (context, index) {
            final week = weekDaysForPage(index);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final label = labels[date.weekday % 7];
    final active = CupertinoColors.activeBlue.resolveFrom(context);
    final labelColor = CupertinoColors.label.resolveFrom(context);
    final tertiary = CupertinoColors.tertiaryLabel.resolveFrom(context);
    final highlight = isToday || isSelected;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onTap,
      child: Container(
        width: 44,
        decoration: BoxDecoration(
          color: highlight
              ? active.withValues(alpha: 0.08)
              : CupertinoColors.systemGrey6.resolveFrom(context),
          borderRadius: BorderRadius.circular(10),
          border: isSelected && !isToday
              ? Border.all(color: active.withValues(alpha: 0.4))
              : null,
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
              '${date.day}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: highlight ? active : labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
