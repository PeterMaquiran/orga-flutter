import 'package:flutter/material.dart';

import '../../../shared/navigationBar.dart';

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
          Positioned.fill(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, safeTop + 16, 20, 120),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Calendar',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selected == todayDay
                              ? 'Today'
                              : MaterialLocalizations.of(context).formatFullDate(_selected),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black.withValues(alpha: 0.45),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Material(
                          color: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.black26,
                          borderRadius: BorderRadius.circular(16),
                          child: CalendarDatePicker(
                            initialDate: _selected,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035, 12, 31),
                            onDateChanged: (date) {
                              setState(() {
                                _selected = DateTime(date.year, date.month, date.day);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const FloatingNavBar(),
    );
  }
}
