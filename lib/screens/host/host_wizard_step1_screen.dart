import 'package:flutter/material.dart';
import '../../models/property_listing_data.dart';
import 'host_wizard_step2_screen.dart';
import 'wizard_helpers.dart';

class HostWizardStep1Screen extends StatefulWidget {
  final String userName;
  final PropertyListingData? existingData;
  const HostWizardStep1Screen(
      {super.key, required this.userName, this.existingData});

  @override
  State<HostWizardStep1Screen> createState() => _HostWizardStep1ScreenState();
}

class _HostWizardStep1ScreenState extends State<HostWizardStep1Screen> {
  late PropertyListingData _data;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _data = widget.existingData ?? PropertyListingData();
    _nameController.text = _data.stayName;
  }

  void _handleNext() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please give your property a name')),
      );
      return;
    }
    _data.stayName = name;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HostWizardStep2Screen(userName: widget.userName, data: _data),
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
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 140,
                      height: 140,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF0F3),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.cottage_rounded,
                          size: 80,
                          color: Color(0xFFF3BDC3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "What's your place called?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Give it a fun, memorable name that guests will love. You can always change it later.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          height: 1.4),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 60,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'e.g. Riverside Cottage',
                        hintStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Colors.black26,
                        ),
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: Color(0xFFF3BDC3), width: 2),
                        ),
                      ),
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