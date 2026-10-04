import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  final Function(String?, String?, String?)? onLoginSuccess;

  const SignUpScreen({super.key, this.onLoginSuccess});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreedToTerms = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);
  bool _isValidPhone(String phone) => RegExp(r'^[0-9]{10}$').hasMatch(phone);

  String _sanitizePhoneNumber(String rawPhone) {
    String cleaned = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.startsWith('91') && cleaned.length > 10) {
      cleaned = cleaned.substring(cleaned.length - 10);
    }
    return cleaned;
  }

  Future<void> _handleCreateAccount() async {
    final fname = _firstNameController.text.trim();
    final lname = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final pass = _passwordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (fname.isEmpty ||
        lname.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        pass.isEmpty ||
        confirmPass.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all required fields.');
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }

    final cleanPhone = _sanitizePhoneNumber(phone);
    if (!_isValidPhone(cleanPhone)) {
      setState(
          () => _errorMessage = 'Please enter a valid 10-digit phone number.');
      return;
    }

    if (pass.length < 6) {
      setState(() => _errorMessage =
          'Password must be at least 6 characters or digits.');
      return;
    }

    if (pass != confirmPass) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    if (!_agreedToTerms) {
      setState(
          () => _errorMessage = 'Please agree to Terms and Conditions.');
      return;
    }

    final fullName = '$fname $lname'.trim();

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      await credential.user?.updateDisplayName(fullName);

      if (credential.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set({
          'uid': credential.user!.uid,
          'firstName': fname,
          'lastName': lname,
          'email': email,
          'phone': cleanPhone,
          'interests': [],
          'about': '',
          'born': '',
          'destination': '',
          'work': '',
          'pets': '',
          'skill': '',
          'funFact': '',
          'song': '',
          'languages': '',
          'love': '',
          'live': '',
        }, SetOptions(merge: true));
      }

      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!(fullName, email, cleanPhone);
      }

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'email-already-in-use':
            _errorMessage =
                'An account already exists with this email address.';
            break;
          case 'invalid-email':
            _errorMessage = 'The email address provided is invalid.';
            break;
          case 'weak-password':
            _errorMessage =
                'The password is too weak. Please use a stronger password.';
            break;
          case 'operation-not-allowed':
            _errorMessage =
                'Email/Password sign-in is not enabled in Firebase Console.';
            break;
          default:
            _errorMessage = (e.message != null && e.message!.isNotEmpty)
                ? e.message!
                : 'Registration failed (${e.code}). Please try again.';
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.person_add_alt_1_rounded,
                  color: Color(0xFFF3BDC3), size: 36),
              const SizedBox(height: 12),
              const Text('Create Account',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 6),
              const Text('Join us and start your journey today',
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 24),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF3BDC3))),
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
                  child: const Text('Firstname',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54))),
              const SizedBox(height: 6),
              TextField(
                controller: _firstNameController,
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
                ),
              ),
              const SizedBox(height: 14),

              Align(
                  alignment: Alignment.centerLeft,
                  child: const Text('Lastname',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54))),
              const SizedBox(height: 6),
              TextField(
                controller: _lastNameController,
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
                ),
              ),
              const SizedBox(height: 14),

              Align(
                  alignment: Alignment.centerLeft,
                  child: const Text('Email Address',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54))),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
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
                ),
              ),
              const SizedBox(height: 14),

              Align(
                  alignment: Alignment.centerLeft,
                  child: const Text('Phone Number',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54))),
              const SizedBox(height: 6),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Text('+91 ',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black))),
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
              const SizedBox(height: 14),

              Align(
                  alignment: Alignment.centerLeft,
                  child: const Text('Password',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54))),
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
              const SizedBox(height: 14),

              Align(
                  alignment: Alignment.centerLeft,
                  child: const Text('Confirm Password',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54))),
              const SizedBox(height: 6),
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
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
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFFF3BDC3)),
                    onPressed: () => setState(() =>
                        _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    activeColor: const Color(0xFFF3BDC3),
                    onChanged: (val) =>
                        setState(() => _agreedToTerms = val ?? false),
                  ),
                  Expanded(
                    child: Wrap(
                      children: const [
                        Text('I agree to the ',
                            style: TextStyle(
                                fontSize: 13, color: Colors.black54)),
                        Text('Terms and Conditions',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        Text(' and ',
                            style: TextStyle(
                                fontSize: 13, color: Colors.black54)),
                        Text('Privacy Policy',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

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
                  onPressed: _handleCreateAccount,
                  child: const Text('Create Account',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ',
                      style: TextStyle(fontSize: 14, color: Colors.black54)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Sign in instead',
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