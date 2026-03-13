import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../shared/appbar.dart';
import '../../../shared/navigationBar.dart';
import 'component/habit_list.dart';
import 'component/weekly_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffset = ValueNotifier(0);

  // Configuration Constants
  final double _appBarHeight = 50.0;
  final double _calendarHeight = 150.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      _scrollOffset.value = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      // CRITICAL: extendBody allows the list to scroll behind the floating nav bar
      extendBody: true,

      // We keep the Stack approach to handle the background and sticky header
      body: Stack(
        children: [
          /// 1. THE FIXED GRADIENT BACKGROUND
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

          /// 3. THE DYNAMIC HEADER
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
                      color: Colors.white.withOpacity(0.7),
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
                                  child: const Center(child: appBar()),
                                ),
                              )),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16),
                              child: SizedBox(
                                height: _calendarHeight,
                                child: const InfiniteWeeklyCalendar(),
                              )),

                          const Divider(height: 1, color: Colors.black12),
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

      /// 4. THE FLOATING NAVIGATION BAR
      bottomNavigationBar: const FloatingNavBar(),
    );
  }
}