import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 200),
            SizedBox(height: 20),
            // Text(
            //   'UEEats',
            //   style: TextStyle(
            //     fontSize: 32,
            //     fontWeight: FontWeight.w900,
            //     color: Colors.white,
            //     letterSpacing: 4,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
