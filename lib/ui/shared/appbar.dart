import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class appBar extends StatelessWidget {
  const appBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Home",
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
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.grey[300], // Soft gray background
              shape: BoxShape.circle,
              // If you have a profile image, use DecorationImage here
            ),
            child: const Icon(
              Icons.person,
              size: 22,
              color: Colors.white, // White icon on gray looks very iOS
            ),
          ),
        ),
      ],
    );
  }
}
