import 'package:flutter/material.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  Widget _buildLegalTile(BuildContext context, String title,
      Widget destinationScreen) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading:
          const Icon(Icons.menu_book_outlined, color: Colors.black, size: 22),
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
              const Text('Legal',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 20),
              _buildLegalTile(context, 'Terms of Service',
                  const TermsOfServiceScreen()),
              const Divider(height: 1, color: Colors.black12),
              _buildLegalTile(
                  context, 'Privacy Policy', const PrivacyPolicyScreen()),
              const Divider(height: 1, color: Colors.black12),
            ],
          ),
        ),
      ),
    );
  }
}

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 6),
          Text(body,
              style: const TextStyle(
                  fontSize: 14, color: Colors.black87, height: 1.45)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Terms of Service',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                'Our Platform',
                'This app is a unified marketplace connecting travelers with independent homestay hosts, managing agents (handling multiple properties), vehicle rental providers, and local tour guides. We facilitate connections and do not own or manage the properties, vehicles, or tours directly.',
              ),
              _buildSection(
                'User Accounts & Roles',
                '• Travelers: Agree to provide accurate information and respect the rules of booked homestays, vehicles, and guided tours.\n\n• Hosts & Agents: Agree to provide accurate listing details, pricing, and availability, and maintain authorized management of all represented properties.\n\n• Tour Guides & Vehicle Providers: Agree to deliver listed services safely, maintain valid licenses/credentials, and uphold agreed schedules.',
              ),
              _buildSection(
                'Bookings & Payments',
                'All reservations for stays, vehicles, and guides are subject to provider confirmation, availability, and the specific cancellation terms agreed upon during booking.',
              ),
              _buildSection(
                'Code of Conduct',
                'Users must not post fraudulent listings, misuse vehicles, damage homestay properties, or violate local laws. Accounts violating these standards may be suspended.',
              ),
              _buildSection(
                'Limitation of Liability',
                'The platform connects users with independent service providers and is not directly liable for off-platform disputes, property damage, accidents, or service cancellations.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 6),
          Text(body,
              style: const TextStyle(
                  fontSize: 14, color: Colors.black87, height: 1.45)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            const Text('Privacy Policy', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                'Information We Collect',
                '• Account Info: Name, email, phone number, and selected role (Traveler, Host, Agent, or Guide).\n\n• Listing Details: Property images, vehicle details, tour credentials, pricing, and host/agent business details.\n\n• Location Data: GPS location to show nearby homestays, rental pickups, and tour guides on the map.',
              ),
              _buildSection(
                'How We Use Information',
                '• To process search queries and link travelers with nearby hosts, agents, vehicles, and guides.\n\n• To display accurate map pins and booking routes.\n\n• To verify providers and maintain platform security.',
              ),
              _buildSection(
                'Data Sharing',
                'We only share necessary contact and booking details between travelers and their corresponding host, agent, or guide to fulfill confirmed reservations. We do not sell your personal data.',
              ),
              _buildSection(
                'Data Security & Your Rights',
                'All account data is securely stored. You can edit your profile, manage listings, or delete your account at any time through the Profile settings.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}