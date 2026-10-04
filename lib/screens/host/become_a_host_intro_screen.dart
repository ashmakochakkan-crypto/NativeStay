import 'package:flutter/material.dart';
import '../home/address_search_sheet.dart';
import 'confirm_address_screen.dart';
import 'other_hosting_options_screen.dart';

class BecomeAHostIntroScreen extends StatelessWidget {
  final String userName;
  const BecomeAHostIntroScreen({super.key, required this.userName});

  void _openAddressSearch(BuildContext context) async {
    final IndianPlace? selectedPlace = await showModalBottomSheet<IndianPlace>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddressSearchSheet(),
    );

    if (selectedPlace != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmAddressScreen(
            userName: userName,
            selectedPlace: selectedPlace,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade100,
            child: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 250,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F3),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.home_work_rounded,
                          size: 72,
                          color: Color(0xFFF3BDC3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Entire home',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Set up your address & details',
                      style: TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              const Text(
                'Set up your listing',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'It\'s easy to create a great listing—\nlet\'s start with your address.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              GestureDetector(
                onTap: () => _openAddressSearch(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(color: Colors.black26),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.search, color: Colors.black87),
                      SizedBox(width: 12),
                      Text(
                        'Enter your address',
                        style: TextStyle(color: Colors.black45, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Want to offer something else? Host a ',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const OtherHostingOptionsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'vehicle rental or tour guide experience.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}