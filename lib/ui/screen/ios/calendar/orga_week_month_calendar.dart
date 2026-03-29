import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'calendar_date_utils.dart';
import 'orga_calendar_controller.dart';

class OrgaWeekMonthCalendar extends StatefulWidget {
  const OrgaWeekMonthCalendar({
    super.key,
    required this.selected,
    required this.onDateChanged,
    this.onDisplayedMonthChanged,
    this.monthViewNotifier,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<DateTime>? onDisplayedMonthChanged;
  final ValueNotifier<bool>? monthViewNotifier;

  @override
  State<OrgaWeekMonthCalendar> createState() => _OrgaWeekMonthCalendarState();
}

class _OrgaWeekMonthCalendarState extends State<OrgaWeekMonthCalendar> {
  static const Duration _kTransition = Duration(milliseconds: 400);

  late OrgaCalendarController _controller;
  VoidCallback? _externalViewListener;
  late DateTime _lastReportedMonth;
  late DateTime _lastReportedSelected;
  bool _didAlignWeekPage = false;

  @override
  void initState() {
    super.initState();
    _controller = OrgaCalendarController(
      initialSelected: widget.selected,
      initialMonthView: widget.monthViewNotifier?.value ?? false,
    )..addListener(_onControllerChanged);
    _lastReportedMonth = _controller.displayedMonth;
    _lastReportedSelected = _controller.selected;
    _attachExternalViewNotifier(widget.monthViewNotifier);
  }

  @override
  void didUpdateWidget(OrgaWeekMonthCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = OrgaCalendarDateUtils.dateOnly(widget.selected);
    if (next != _controller.selected) {
      _controller.setSelected(next);
      if (!_controller.monthView) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _controller.jumpToSelectedWeek(MaterialLocalizations.of(context));
        });
      }
    }

    if (oldWidget.monthViewNotifier != widget.monthViewNotifier) {
      if (_externalViewListener != null) {
        oldWidget.monthViewNotifier?.removeListener(_externalViewListener!);
      }
      _externalViewListener = null;
      _attachExternalViewNotifier(widget.monthViewNotifier);
    }
  }

  @override
  void dispose() {
    if (_externalViewListener != null) {
      widget.monthViewNotifier?.removeListener(_externalViewListener!);
    }
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (_controller.selected != _lastReportedSelected) {
      _lastReportedSelected = _controller.selected;
      widget.onDateChanged(_controller.selected);
    }
    if (_controller.displayedMonth != _lastReportedMonth) {
      _lastReportedMonth = _controller.displayedMonth;
      widget.onDisplayedMonthChanged?.call(_controller.displayedMonth);
    }
    if (mounted) setState(() {});
  }

  void _attachExternalViewNotifier(ValueNotifier<bool>? notifier) {
    if (notifier == null) return;
    _externalViewListener = () {
      final loc = MaterialLocalizations.of(context);
      _controller.setMonthView(notifier.value, loc: loc);
    };
    notifier.addListener(_externalViewListener!);
  }

  void _emit(DateTime d) {
    _controller.setSelected(d);
    widget.onDateChanged(_controller.selected);
  }

  @override
  Widget build(BuildContext context) {
    if (!_didAlignWeekPage) {
      _didAlignWeekPage = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _controller.jumpToSelectedWeek(MaterialLocalizations.of(context));
      });
    }

    final loc = MaterialLocalizations.of(context);
    final today = DateTime.now();
    const days = ["S", "M", "T", "W", "T", "F", "S"];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        ClipRect(
          child: AnimatedCrossFade(
            duration: _kTransition,
            reverseDuration: _kTransition,
            sizeCurve: Curves.easeInOutCubicEmphasized,
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeInCubic,
            alignment: Alignment.topCenter,
            crossFadeState: _controller.monthView
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: _WeekStrip(
              today: today,
              selected: _controller.selected,
              pageController: _controller.weekPageController,
              weekDaysForPage: (i) => _controller.weekDaysForPage(i, loc),
              onWeekPageChanged: (i) {
                final day = _controller.selectedForWeekPage(i, loc);
                if (day == _controller.selected) return;
                _emit(day);
              },
              onDayTap: _emit,
            ),
            secondChild: OrgaMonthCalendar(
              weekCount: _controller.weekCountForDisplayedMonth(),
              selected: _controller.selected,
              monthPageController: _controller.monthPageController,
              onSelectDay: (d) {
                _emit(d);
                _controller.syncToSelectedMonth(animate: true);
              },
              onPageChanged: _controller.onMonthPageChanged,
              monthForPage: _controller.monthForPage,
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
    required this.weekCount,
    required this.selected,
    required this.monthPageController,
    required this.onSelectDay,
    required this.onPageChanged,
    required this.monthForPage,
  });

  final int weekCount;
  final DateTime selected;
  final PageController monthPageController;
  final ValueChanged<DateTime> onSelectDay;
  final ValueChanged<int> onPageChanged;
  final DateTime Function(int) monthForPage;

  @override
  Widget build(BuildContext context) {
    const double gridRowExtent = 35;
    final gridHeight = weekCount * gridRowExtent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
