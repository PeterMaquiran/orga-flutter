import 'package:flutter/material.dart';

import 'component/habit_list.dart';
import 'component/weekly_calendar.dart';

// --- MAIN HOME SCREEN ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF), Color(0xFFDEE2E6)],
          ),
        ),
        child: const SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Home", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 10),
              // The extracted Calendar component
              InfiniteWeeklyCalendar(),
              SizedBox(height: 9,),
              // Add your HabitHub or Orga tasks list here
              Expanded(
                child: HabitList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}