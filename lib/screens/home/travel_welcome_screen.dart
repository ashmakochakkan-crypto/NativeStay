import 'package:flutter/material.dart';

class TravelWelcomeScreen extends StatelessWidget {
  const TravelWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Center(
              child: Image.asset(
                'assets/Logo.jpg',
                width: 350,
                height: 350,
                fit: BoxFit.contain,
              ),
            ),
            const Spacer(),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFFF3BDC3),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}