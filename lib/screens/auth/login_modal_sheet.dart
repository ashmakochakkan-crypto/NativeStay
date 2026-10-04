import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class LoginModalSheet extends StatelessWidget {
  final Function(String?, String?, String?) onAuthSuccess;
  const LoginModalSheet({super.key, required this.onAuthSuccess});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 50),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.black),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: Color(0xFFF3BDC3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.card_travel_rounded,
                size: 40, color: Colors.black),
          ),
          const SizedBox(height: 18),
          const Text('Welcome',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 8),
          const Text(
            'Sign in to save trips, manage bookings, and access your profile.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3BDC3),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginScreen(onLoginSuccess: onAuthSuccess)),
                );
              },
              child: const Text('Login',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SignUpScreen(onLoginSuccess: onAuthSuccess)),
                );
              },
              child: const Text('Create account',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}