import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class appBar extends StatelessWidget {
  const appBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Habit",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5, // iOS titles are slightly tighter
          ),
        ),
        GestureDetector(
          onTap: () {
            // Profile action
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey[300], // Soft gray background
              shape: BoxShape.circle,
              // If you have a profile image, use DecorationImage here
            ),
            child: const Icon(
              Icons.person,
              size: 30,
              color: Colors.white, // White icon on gray looks very iOS
            ),
          ),
        ),
      ],
    );
  }
}




class OrgaAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AppBar(
          backgroundColor: Colors.white.withOpacity(0.7),
          elevation: 0,
          title: const Text(
            'Orga',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
          actions: [
            // Plus Button
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.add, color: Colors.black87),
              onPressed: () => _handleAddTask(context),
            ),

            // More Options (Popup Menu)
            PopupMenuButton<String>(
              icon: const Icon(CupertinoIcons.ellipsis, color: Colors.black87),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              offset: const Offset(0, 50),
              onSelected: (value) => _handleMenuSelection(value),
              itemBuilder: (context) => [
                _buildMenuItem('Edit Layout', CupertinoIcons.pencil),
                _buildMenuItem('Settings', CupertinoIcons.settings),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String title, IconData icon) {
    return PopupMenuItem(
      value: title,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  void _handleAddTask(BuildContext context) {
    // Logic for adding a new task or habit
  }

  void _handleMenuSelection(String value) {
    // Logic for menu options
  }
}