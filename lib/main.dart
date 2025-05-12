import 'onboarding_screen.dart';

import 'package:UEEats/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:UEEats/AdminHome.dart';
import 'package:UEEats/UserHome.dart';
import 'package:UEEats/login_screen.dart';
import 'package:UEEats/signup_screen.dart';
import 'package:UEEats/splash_screen.dart';

import 'login_screen.dart';

void main() {
  runApp(const UniEats());
}

class UniEats extends StatelessWidget {
  const UniEats({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/admin_home': (context) => const AdminHome(),
        '/user_home': (context) => const UserHome(),
      },
    );
  }
}
