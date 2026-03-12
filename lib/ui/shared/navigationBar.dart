import 'dart:ui';
import 'package:flutter/material.dart';

class FloatingNavBar extends StatelessWidget {

  const FloatingNavBar({
    super.key,
  });
  final int currentIndex = 1;


  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding pushes the bar away from the edges to make it "float"
      padding: const EdgeInsets.fromLTRB(50, 0, 50, 30),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          // This creates the iOS frosted glass effect
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem(Icons.home_rounded, 0),
                _navItem(Icons.calendar_today_rounded, 1),
                //_navItem(Icons.leaderboard_rounded, 1),
                _navItem(Icons.checklist_rounded, 2),       // Task Management
                _navItem(Icons.insights_rounded, 3),        // Analytics/Stats
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => {},
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.black : Colors.black38,
            size: 28,
          ),
          // Small animated dot indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(top: 4),
            height: 4,
            width: isSelected ? 4 : 0,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}