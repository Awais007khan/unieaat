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
      Navigator.pushReplacementNamed(context, '/login');
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
            Text(
              'UEEats',  // Text matching your logo
              style: TextStyle(
                fontSize: 32,               // Bigger size for logo feel
                fontWeight: FontWeight.w900, // Boldest weight
                color: Colors.white,         // White like your logo text
                letterSpacing: 4,            // Space between letters
                fontFamily: 'Sans',          // You can use a custom font here for exact match
              ),
            ),
          ],
        ),
      ),
    );
  }


}