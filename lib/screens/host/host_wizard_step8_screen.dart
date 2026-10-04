import 'package:flutter/material.dart';
import '../../models/property_listing_data.dart';
import 'host_wizard_step9_screen.dart';
import 'wizard_helpers.dart';

class HostWizardStep8Screen extends StatefulWidget {
  final String userName;
  final PropertyListingData data;
  const HostWizardStep8Screen(
      {super.key, required this.userName, required this.data});

  @override
  State<HostWizardStep8Screen> createState() => _HostWizardStep8ScreenState();
}

class _HostWizardStep8ScreenState extends State<HostWizardStep8Screen> {
  final _priceController = TextEditingController();
  final _extraController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _priceController.text = widget.data.pricePerNight;
    _extraController.text = widget.data.extraCharges;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _extraController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter price per night')),
      );
      return;
    }
    widget.data.pricePerNight = _priceController.text.trim();
    widget.data.extraCharges = _extraController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HostWizardStep9Screen(userName: widget.userName, data: widget.data),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.currency_rupee_rounded,
                            color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Set your price',
                              style: TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'You can change this anytime',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    const Text('Price per night (₹) *',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'e.g. 2500',
                        hintStyle: const TextStyle(color: Colors.black38),
                        prefixIcon: const Icon(Icons.currency_rupee_rounded,
                            color: Color(0xFFF3BDC3)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFFF3BDC3), width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text('Extra charges (if any)',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _extraController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'e.g. 500 cleaning fee',
                        hintStyle: const TextStyle(color: Colors.black38),
                        prefixIcon: const Icon(Icons.add_card_rounded,
                            color: Color(0xFFF3BDC3)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFFF3BDC3), width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text('Cancellation policy *',
                        style:
                            TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...const ['Flexible', 'Moderate', 'Strict'].map((p) {
                      final sel = widget.data.cancellationPolicy == p;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => widget.data.cancellationPolicy = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: sel
                                ? const Color(0xFFFFF0F3)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: sel
                                  ? const Color(0xFFF3BDC3)
                                  : Colors.black12,
                              width: sel ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text(
                                      p == 'Flexible'
                                          ? 'Full refund up to 24 hours before'
                                          : p == 'Moderate'
                                              ? 'Full refund up to 5 days before'
                                              : 'No refunds after booking',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              if (sel)
                                const Icon(Icons.check_circle,
                                    color: Color(0xFFF3BDC3), size: 22),
                            ],
                          ),
                        ),
                      );
                    }),
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
