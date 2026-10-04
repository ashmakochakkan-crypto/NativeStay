import 'package:flutter/material.dart';

class AccountSettingsScreen extends StatefulWidget {
  final String? currentLegalName;
  final String? userEmail;
  final String? userPhone;
  final Map<String, String> personalData;
  final Function(String) onNameUpdated;
  final Function(Map<String, String>) onPersonalDataUpdated;
  final Future<void> Function() onDeactivateAccount;

  const AccountSettingsScreen({
    super.key,
    this.currentLegalName,
    this.userEmail,
    this.userPhone,
    required this.personalData,
    required this.onNameUpdated,
    required this.onPersonalDataUpdated,
    required this.onDeactivateAccount,
  });

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentLegalName ?? '');
    _emailController = TextEditingController(text: widget.userEmail ?? '');
    _phoneController = TextEditingController(text: widget.userPhone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Legal Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => widget.onNameUpdated(val),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Danger Zone',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 8),
            const Text(
              'Once you deactivate your account, there is no going back. Please be certain.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await widget.onDeactivateAccount();
                },
                child: const Text('Deactivate Account', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}