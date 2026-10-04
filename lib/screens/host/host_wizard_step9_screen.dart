import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/property_listing_data.dart';
import 'host_wizard_step10_screen.dart';
import 'wizard_helpers.dart';

class HostWizardStep9Screen extends StatefulWidget {
  final String userName;
  final PropertyListingData data;
  const HostWizardStep9Screen(
      {super.key, required this.userName, required this.data});

  @override
  State<HostWizardStep9Screen> createState() => _HostWizardStep9ScreenState();
}

class _HostWizardStep9ScreenState extends State<HostWizardStep9Screen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _langController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _langController.dispose();
    super.dispose();
  }

  Future<void> _prefill() async {
    _nameController.text = widget.data.hostName.isNotEmpty
        ? widget.data.hostName
        : widget.userName;
    _phoneController.text = widget.data.phone;
    _emailController.text = widget.data.email;
    _bioController.text = widget.data.hostBio;
    _langController.text = widget.data.languagesSpoken;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final data = doc.data() ?? {};

        final firstName = (data['firstName'] ?? '').toString().trim();
        final lastName = (data['lastName'] ?? '').toString().trim();
        final fullName = '$firstName $lastName'.trim();

        if (mounted) {
          setState(() {
            if (_nameController.text.trim().isEmpty && fullName.isNotEmpty) {
              _nameController.text = fullName;
            }
            if (_phoneController.text.trim().isEmpty) {
              _phoneController.text = (data['phone'] ?? '').toString();
            }
            if (_emailController.text.trim().isEmpty) {
              _emailController.text =
                  (data['email'] ?? user.email ?? '').toString();
            }
            if (_bioController.text.trim().isEmpty) {
              _bioController.text = (data['about'] ?? '').toString();
            }
            if (_langController.text.trim().isEmpty) {
              _langController.text = (data['languages'] ?? '').toString();
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Prefill error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleNext() {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please provide host name and phone number')),
      );
      return;
    }
    widget.data.hostName = _nameController.text.trim();
    widget.data.phone = _phoneController.text.trim();
    widget.data.email = _emailController.text.trim();
    widget.data.hostBio = _bioController.text.trim();
    widget.data.languagesSpoken = _langController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HostWizardStep10Screen(userName: widget.userName, data: widget.data),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38),
            prefixIcon: Icon(icon, color: const Color(0xFFF3BDC3)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFF3BDC3), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFFF3BDC3)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.person_outline,
                                  color: Color(0xFFF3BDC3), size: 28),
                              SizedBox(width: 10),
                              Text('About you',
                                  style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Prefilled from your profile. Edit if needed.',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(height: 24),

                          _field(
                            controller: _nameController,
                            label: 'Host Name *',
                            hint: 'Your full name',
                            icon: Icons.person_outline,
                          ),
                          _field(
                            controller: _phoneController,
                            label: 'Phone Number *',
                            hint: '10-digit number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          _field(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'your@email.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          _field(
                            controller: _bioController,
                            label: 'Short bio',
                            hint: 'Tell guests a bit about yourself...',
                            icon: Icons.edit_note_rounded,
                            maxLines: 3,
                          ),
                          _field(
                            controller: _langController,
                            label: 'Languages spoken',
                            hint: 'e.g. English, Hindi',
                            icon: Icons.translate_rounded,
                          ),
                        ],
                      ),
                    ),
            ),
            WizardBottomBar(
              onPrevious: () => Navigator.pop(context),
              onNext: _handleNext,
            ),
          ],
        ),
      ),
    );
  }
}