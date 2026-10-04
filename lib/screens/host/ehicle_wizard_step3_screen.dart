import 'package:flutter/material.dart';
import '../../models/vehicle_listing.dart';
import '../rentals/rental_vehicles.dart';
import 'vehicle_wizard_step4_screen.dart';
import 'wizard_helpers.dart';

class VehicleWizardStep3Screen extends StatefulWidget {
  final VehicleListingData data;
  const VehicleWizardStep3Screen({super.key, required this.data});

  @override
  State<VehicleWizardStep3Screen> createState() =>
      _VehicleWizardStep3ScreenState();
}

class _VehicleWizardStep3ScreenState extends State<VehicleWizardStep3Screen> {
  void _handleNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleWizardStep4Screen(data: widget.data),
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
                        Icon(Icons.star_outline_rounded,
                            color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Vehicle features',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tap everything your vehicle offers',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.data.features.length} selected',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF3BDC3)),
                    ),
                    const SizedBox(height: 20),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: kVehicleFeatures.length,
                      itemBuilder: (context, index) {
                        final f = kVehicleFeatures[index];
                        final isSelected =
                            widget.data.features.contains(f.label);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                widget.data.features.remove(f.label);
                              } else {
                                widget.data.features.add(f.label);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFFF0F3)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFF3BDC3)
                                    : Colors.black12,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  f.icon,
                                  size: 30,
                                  color: isSelected
                                      ? const Color(0xFFF3BDC3)
                                      : Colors.black87,
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: Text(
                                    f.label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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