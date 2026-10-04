import 'package:flutter/material.dart';
import '../../models/vehicle_listing.dart';
import 'vehicle_wizard_step4_screen.dart';
import 'wizard_helpers.dart';

class VehicleWizardStep3Screen extends StatefulWidget {
  final VehicleListingData data;
  const VehicleWizardStep3Screen({super.key, required this.data});

  @override
  State<VehicleWizardStep3Screen> createState() => _VehicleWizardStep3ScreenState();
}

class _VehicleWizardStep3ScreenState extends State<VehicleWizardStep3Screen> {
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.directions_car_rounded, color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Step 3: Pricing & Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'This is a placeholder for Step 3.\n\nIf you lost your original code, you can rebuild it here. Otherwise, paste your original code over this.',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            WizardBottomBar(
              onPrevious: () => Navigator.pop(context),
              onNext: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VehicleWizardStep4Screen(data: widget.data),
                  ),
                );
              },
              nextLabel: 'Next: Location & Mode',
            ),
          ],
        ),
      ),
    );
  }
}