import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../shared/appbar.dart';
import '../../../shared/navigationBar.dart';
import '../home/component/habit_list.dart';
import 'orga_week_month_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selected;
  late DateTime _displayedMonth;
  late ValueNotifier<bool> _monthViewNotifier;


  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selected = DateTime(now.year, now.month, now.day);
    _displayedMonth = DateTime(_selected.year, _selected.month);

    // Initialize the monthViewNotifier based on your default calendarView
    _monthViewNotifier = ValueNotifier(calendarView.value == CalendarView.month);

    // Listen to external calendarView changes
    calendarView.addListener(() {
      _monthViewNotifier.value = calendarView.value == CalendarView.month;
    });
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    // Configuration Constants (large title needs a bit more vertical room)
    final double _appBarHeight = 64.0;
    final double _calendarHeight = 150.0;
    final ScrollController _scrollController = ScrollController();
    final ValueNotifier<double> _scrollOffset = ValueNotifier(0);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF8F9FA),
                    Color(0xFFE9ECEF),
                    Color(0xFFDEE2E6),
                  ],
                ),
              ),
            ),
          ),


          /// 2. THE SCROLLABLE CONTENT
          Positioned.fill(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(
                    top: safeTop + _appBarHeight + _calendarHeight + 10,
                    bottom: 120, // Extra bottom padding so items aren't hidden by NavBar
                    left: 16,
                    right: 16,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => HabitCard(index: index,),
                      childCount: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          ValueListenableBuilder<double>(
            valueListenable: _scrollOffset,
            builder: (context, offset, child) {
              double shrinkProgress = (offset / _appBarHeight).clamp(0.0, 1.0);
              double currentAppBarHeight = _appBarHeight * (1 - shrinkProgress);
              double opacity = (1 - shrinkProgress).clamp(0.0, 1.0);

              return Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.72),
                      padding: EdgeInsets.only(top: safeTop),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16),
                              child:
                              Opacity(
                                opacity: opacity,
                                child: SizedBox(
                                  height: currentAppBarHeight,
                                  child: Padding(padding: EdgeInsets.only(bottom: 14),
                                    child: const Center(child: appBar(title: "Calendar",))
                                    ,),
                                ),
                              )),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16),
                              child: SizedBox(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
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
                                              color: CupertinoColors.secondaryLabel.resolveFrom(context),
                                            ),
                                          ),
                                        ),
                                        ValueListenableBuilder<bool>(
                                          valueListenable: _monthViewNotifier,
                                          builder: (context, isMonthView, _) {
                                            final String title = isMonthView
                                                ? '${monthNames[_displayedMonth.month - 1]} ${_displayedMonth.year}'
                                                : (_selected == todayDay
                                                ? 'Today'
                                                : (() {
                                              final String yearStr =
                                              _selected.year != today.year ? ', ${_selected.year}' : '';
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
                                              ][_selected.month - 1];
                                              return '$month ${_selected.day}$yearStr';
                                            })());
                                            return Text(
                                              title,
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
                                                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              SizedBox(
                                                width: 44,
                                                height: 44,
                                                child: CupertinoButton(
                                                  padding: EdgeInsets.zero,
                                                  onPressed: () {
                                                    showCalendarViewSelector(context);
                                                  },
                                                  child: Icon(
                                                    CupertinoIcons.slider_horizontal_3,
                                                    size: 22,
                                                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      elevation: 0,
                                      shadowColor: Colors.black26,
                                      borderRadius: BorderRadius.circular(16),
                                      clipBehavior: Clip.antiAlias,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 19),
                                        child: OrgaWeekMonthCalendar(
                                          monthViewNotifier: _monthViewNotifier,
                                          selected: _selected,
                                          onDisplayedMonthChanged: (month) {
                                            setState(() {
                                              _displayedMonth = DateTime(month.year, month.month);
                                            });
                                          },
                                          onDateChanged: (date) {
                                            setState(() {
                                              _selected = date;
                                              _displayedMonth = DateTime(date.year, date.month);
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),

                          Divider(
                            height: 1,
                            thickness: 0.5,
                            color: const Color(0xFF3C3C43).withValues(alpha: 0.29),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const FloatingNavBar(),
    );
  }
}



enum CalendarView {
  week,
  month,
}

final ValueNotifier<CalendarView> calendarView =
ValueNotifier(CalendarView.week);

void showCalendarViewSelector(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (context) => CupertinoActionSheet(
      title: const Text("Calendar View"),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            calendarView.value = CalendarView.week;
            Navigator.pop(context);
          },
          child: const Text("Week View"),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            calendarView.value = CalendarView.month;
            Navigator.pop(context);
          },
          child: const Text("Month View"),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: true,
        onPressed: () => Navigator.pop(context),
        child: const Text("Cancel"),
      ),
    ),
  );
}