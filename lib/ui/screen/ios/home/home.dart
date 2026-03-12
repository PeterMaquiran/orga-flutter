import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../shared/appbar.dart';
import '../../../shared/navigationBar.dart';
import 'component/habit_list.dart';
import 'component/weekly_calendar.dart';

/// ---------------- HOME SCREEN ----------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  // We use a ValueNotifier to track the offset without calling setState
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // Update the notifier directly. This does NOT rebuild the whole widget.
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF), Color(0xFFDEE2E6)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ONLY this builder rebuilds when scrolling
              ValueListenableBuilder<double>(
                valueListenable: _scrollOffset,
                builder: (context, offset, child) {
                  final double headerHeight = (60.0 - offset).clamp(0.0, 60.0);
                  final double opacity = (1.0 - (offset / 60.0)).clamp(0.0, 1.0);

                  return Opacity(
                    opacity: opacity,
                    child: Container(
                      height: headerHeight,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerLeft,
                      // Child is the Text widget passed below to avoid re-creating it
                      child: headerHeight > 10 ? child : const SizedBox.shrink(),
                    ),
                  );
                },
                // Pass the static parts as a child to the builder for extra optimization
                child: appBar(),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: InfiniteWeeklyCalendar(),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20, top: 20, right: 16, left: 16),
                  physics: const BouncingScrollPhysics(),
                  controller: _scrollController,
                  itemCount: 30,
                  itemBuilder: (context, index) => HabitCard(index: index),
                ),
              ),
            ],
          ),
        ),
      ),
      extendBody: true, // Crucial: lets the list scroll behind the floating bar
      bottomNavigationBar: FloatingNavBar(),
    );
  }
}