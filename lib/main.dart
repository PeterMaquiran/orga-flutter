import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orga/ui/screen/ios/auth/email_confirmation.dart';
import 'package:orga/ui/screen/ios/auth/login.dart';
import 'package:orga/ui/screen/ios/home/home.dart';
import 'package:orga/ui/shared/theme/appColors.dart';

// 1. Define your Route "Map" (The Central Command)
final GoRouter _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const OrgaLoginScreen(),
    ),
    GoRoute(
      path: '/confirm-email',
      builder: (context, state) => const EmailConfirmationScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);

void main() {
  runApp(const OrgaApp());
}

class OrgaApp extends StatelessWidget {
  const OrgaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Use .router constructor to connect your Map to the App
    return MaterialApp.router(
      theme: appTheme,
      routerConfig: _router,
      title: 'Orga',
      debugShowCheckedModeBanner: false,
    );
  }
}
