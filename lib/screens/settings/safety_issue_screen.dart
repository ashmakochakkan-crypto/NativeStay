import 'package:flutter/material.dart';

class SafetyIssueScreen extends StatelessWidget {
  const SafetyIssueScreen({super.key});

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFFF3BDC3)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
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
              const Text('Safety & Emergency',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 20),

              _buildSectionCard(
                title: 'Emergency Numbers',
                children: [
                  _buildDetailRow(Icons.local_police_outlined,
                      'National Emergency', '112 (Police, Fire, Ambulance)'),
                  const Divider(height: 1, color: Colors.black12),
                  _buildDetailRow(Icons.woman_outlined,
                      'Women\'s Safety Helpline', '1091'),
                  const Divider(height: 1, color: Colors.black12),
                  _buildDetailRow(Icons.support_agent_outlined,
                      'Tourist Helpline', '1363'),
                ],
              ),

              _buildSectionCard(
                title: 'App Support Desk',
                children: [
                  _buildDetailRow(Icons.phone_in_talk_outlined,
                      '24/7 Safety Desk', '+91 8097003176'),
                  const Divider(height: 1, color: Colors.black12),
                  _buildDetailRow(Icons.email_outlined, 'Support Email',
                      'NativeStays@gmail.com'),
                  const Divider(height: 1, color: Colors.black12),
                  _buildDetailRow(Icons.access_time_rounded, 'Response Time',
                      'Available 24/7 for travelers, hosts, and guides'),
                ],
              ),

              _buildSectionCard(
                title: 'Quick Safety Guidelines',
                children: [
                  _buildDetailRow(Icons.home_outlined, 'Homestays',
                      'Verify the host\'s profile details and property address before checking in.'),
                  const Divider(height: 1, color: Colors.black12),
                  _buildDetailRow(Icons.directions_car_outlined,
                      'Vehicle Rentals',
                      'Inspect vehicle condition and confirm document availability before driving.'),
                  const Divider(height: 1, color: Colors.black12),
                  _buildDetailRow(Icons.person_search_outlined, 'Tour Guides',
                      'Ensure your guide matches the verified ID shown in the app.'),
                  const Divider(height: 1, color: Colors.black12),
                  _buildDetailRow(Icons.report_problem_outlined, 'Reporting',
                      'In case of misconduct or fraudulent listings, contact the support desk immediately.'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}