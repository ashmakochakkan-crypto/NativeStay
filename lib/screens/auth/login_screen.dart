import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final Function(String?, String?, String?)? onLoginSuccess;

  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);

  Future<void> _handleSignIn() async {
    setState(() => _errorMessage = null);
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address.');
      return;
    }

    if (pass.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password.');
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }
    final loginEmail = email;

    try {
      final credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: loginEmail,
        password: pass,
      );

      if (credential.user != null) {
        if (widget.onLoginSuccess != null) {
          widget.onLoginSuccess!(
            credential.user!.displayName,
            credential.user!.email,
            '',
          );
        }

        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          _errorMessage =
              'Account not found or invalid credentials. Please check your details.';
        } else if (e.code == 'wrong-password') {
          _errorMessage = 'Incorrect password. Please try again.';
        } else {
          _errorMessage = (e.message != null && e.message!.isNotEmpty)
              ? e.message!
              : 'Unable to log in (${e.code}). Please try again.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text('Login',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 8),
              const Text('Enter your credentials to access your account',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF3BDC3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.redAccent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(_errorMessage ?? '',
                              style: const TextStyle(
                                  color: Colors.redAccent, fontSize: 13))),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: const [
                    Icon(Icons.person_outline,
                        size: 16, color: Color(0xFFF3BDC3)),
                    SizedBox(width: 6),
                    Text('Email Address',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Enter Email',
                  hintStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.black38),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black12)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFF3BDC3))),
                ),
              ),

              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: const [
                    Icon(Icons.lock_outline,
                        size: 16, color: Color(0xFFF3BDC3)),
                    SizedBox(width: 6),
                    Text('Password',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black12)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFF3BDC3))),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFFF3BDC3)),
                    onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
              ),

              const SizedBox(height: 24),

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
                  onPressed: _handleSignIn,
                  child: const Text('Sign In',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ",
                      style: TextStyle(fontSize: 14, color: Colors.black54)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignUpScreen(
                                onLoginSuccess: widget.onLoginSuccess)),
                      );
                    },
                    child: const Text('Sign up',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}