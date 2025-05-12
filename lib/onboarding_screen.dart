import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> pages = [
    {
      'type': 'image',
      'asset': 'assets/ob1.png',
      'title': 'Order Your Food Now',
      'description': 'Browse your favorites and order in just a few taps.',
    },
    {
      'type': 'lottie',
      'asset': 'assets/ob2.json',
      'title': 'Carefully Prepared',
      'description': 'Fresh ingredients, cooked with love and precision.',
    },
    {
      'type': 'lottie',
      'asset': 'assets/ob3.json',
      'title': 'Fast Delivery',
      'description': 'Your food arrives hot and on time, every time.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return buildPage(pages[index]);
                },
              ),
            ),
            const SizedBox(height: 20),
            buildIndicator(),
            const SizedBox(height: 30),
            if (_currentPage == pages.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 30,
                    ),
                  ),
                  child: Text(
                    'Get Started',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget buildPage(Map<String, dynamic> page) {
    Widget visual;
    if (page['type'] == 'image') {
      visual = Image.asset(page['asset'], height: 250);
    } else {
      visual = Lottie.asset(page['asset'], height: 250);
    }

    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          visual,
          const SizedBox(height: 40),
          Text(
            page['title'],
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page['description'],
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          height: 10,
          width: _currentPage == index ? 24 : 10,
          decoration: BoxDecoration(
            color:
                _currentPage == index ? Colors.orange : Colors.orange.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}
