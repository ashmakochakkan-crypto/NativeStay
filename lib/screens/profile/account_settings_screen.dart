import 'package:flutter/material.dart';
import 'login_security_screen.dart';
import 'personal_info_screen.dart';

class AccountSettingsScreen extends StatelessWidget {
  final String currentLegalName;
  final String userEmail;
  final String userPhone;
  final Map<String, String> personalData;
  final Function(String) onNameUpdated;
  final Function(Map<String, String>) onPersonalDataUpdated;
  final Future<void> Function() onDeactivateAccount;

  const AccountSettingsScreen({
    super.key,
    required this.currentLegalName,
    required this.userEmail,
    required this.userPhone,
    required this.personalData,
    required this.onNameUpdated,
    required this.onPersonalDataUpdated,
    required this.onDeactivateAccount,
  });

  Widget _buildSettingTile(BuildContext context, IconData icon, String title,
      Widget destinationScreen) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black, size: 22),
      title: Text(title,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 16, color: Colors.black38),
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => destinationScreen));
      },
    );
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
            onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Account Settings',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 20),
              _buildSettingTile(
                context,
                Icons.person_outline,
                'Personal information',
                PersonalInfoScreen(
                  currentLegalName: currentLegalName,
                  userEmail: userEmail,
                  userPhone: userPhone,
                  personalData: personalData,
                  onNameUpdated: onNameUpdated,
                  onDataUpdated: onPersonalDataUpdated,
                ),
              ),
              _buildSettingTile(
                context,
                Icons.shield_outlined,
                'Login & security',
                LoginSecurityScreen(
                    userName: currentLegalName,
                    onDeactivate: onDeactivateAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}