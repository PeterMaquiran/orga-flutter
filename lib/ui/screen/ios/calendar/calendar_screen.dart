import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../shared/appbar.dart';
import '../../../shared/navigationBar.dart';
import 'orga_week_month_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selected = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);

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
                                    // Text(
                                    //   _selected == todayDay
                                    //       ? 'Today'
                                    //       : MaterialLocalizations.of(context).formatFullDate(_selected),
                                    //   style: TextStyle(
                                    //     fontSize: 15,
                                    //     color: Colors.black.withValues(alpha: 0.45),
                                    //   ),
                                    // ),
                                    const SizedBox(height: 20),
                                    Material(
                                      color: Colors.white,
                                      elevation: 0,
                                      shadowColor: Colors.black26,
                                      borderRadius: BorderRadius.circular(16),
                                      clipBehavior: Clip.antiAlias,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
                                        child: OrgaWeekMonthCalendar(
                                          selected: _selected,
                                          onDateChanged: (date) {
                                            setState(() {
                                              _selected = date;
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
