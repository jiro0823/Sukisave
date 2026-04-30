import 'package:flutter/material.dart';

import 'features/auth/login_page.dart';
import 'features/auth/signup_users.dart';
import 'features/home/pages/Onbording_page.dart';
import 'features/home/pages/landing_page.dart';
import 'features/home/pages/map_location.dart';
import 'features/home/pages/message_page.dart';
import 'features/home/pages/profile_page.dart';
import 'features/home/pages/activities.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SukiSave',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'Geist',
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupUsersPage(),
        '/landing': (context) => const LandingPage(),
        '/map': (context) => const MapLocationPage(),
        '/messages': (context) => const MessagePage(),
        '/receipts': (context) => const ReceiptPage(),
        '/profile': (context) => const ProfilePage(),
      },
      home: const OnboardingPage(),
    );
  }
}
