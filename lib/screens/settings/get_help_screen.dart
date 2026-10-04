import 'package:flutter/material.dart';
import 'help_center_screen.dart';
import 'safety_issue_screen.dart';
import 'share_feedback_screen.dart';

class GetHelpScreen extends StatelessWidget {
  const GetHelpScreen({super.key});

  Widget _buildHelpTile(BuildContext context, IconData icon, String title,
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
              const Text('Get help',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 20),
              _buildHelpTile(context, Icons.help_outline_rounded,
                  'Visit the Help Center', const HelpCenterScreen()),
              const Divider(height: 1, color: Colors.black12),
              _buildHelpTile(context, Icons.shield_outlined,
                  'Get help with a safety issue', const SafetyIssueScreen()),
              const Divider(height: 1, color: Colors.black12),
              _buildHelpTile(context, Icons.campaign_outlined,
                  'Give us feedback', const ShareFeedbackScreen()),
            ],
          ),
        ),
      ),
    );
  }
}