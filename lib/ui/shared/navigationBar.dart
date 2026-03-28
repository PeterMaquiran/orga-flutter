import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({super.key});

  int _currentIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path == '/calendar') return 1;
    if (path == '/boards') return 2;
    if (path == '/home') return 0;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        return;
      case 1:
        context.go('/calendar');
        return;
      case 2:
        context.go('/boards');
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
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
                _navItem(context, currentIndex, Icons.home_rounded, 0),
                _navItem(context, currentIndex, Icons.calendar_today_rounded, 1),
                //_navItem(Icons.leaderboard_rounded, 1),
                _navItem(context, currentIndex, Icons.view_kanban_rounded, 2),
                //_navItem(Icons.insights_rounded, 3),        // Analytics/Stats
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    int currentIndex,
    IconData icon,
    int index,
  ) {
    final bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => _onTap(context, index),
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