import 'package:flutter/material.dart';
import '../../models/vehicle_listing.dart';
import '../rentals/rental_vehicles.dart';
import 'vehicle_wizard_step6_screen.dart';
import 'wizard_helpers.dart';

class VehicleWizardStep5Screen extends StatefulWidget {
  final VehicleListingData data;
  const VehicleWizardStep5Screen({super.key, required this.data});

  @override
  State<VehicleWizardStep5Screen> createState() =>
      _VehicleWizardStep5ScreenState();
}

class _VehicleWizardStep5ScreenState extends State<VehicleWizardStep5Screen> {
  final _baseController = TextEditingController();
  final _minBillingController = TextEditingController();
  final _extraKmController = TextEditingController();
  final _extraHourController = TextEditingController();
  final _driverAllowanceController = TextEditingController();
  final _depositController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _baseController.text = widget.data.basePrice;
    _minBillingController.text = widget.data.minBilling;
    _extraKmController.text = widget.data.extraKmCharge;
    _extraHourController.text = widget.data.extraHourCharge;
    _driverAllowanceController.text = widget.data.driverAllowance;
    _depositController.text = widget.data.securityDeposit;
  }

  @override
  void dispose() {
    _baseController.dispose();
    _minBillingController.dispose();
    _extraKmController.dispose();
    _extraHourController.dispose();
    _driverAllowanceController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_baseController.text.trim().isEmpty) {
      _snack('Please enter a base price');
      return;
    }
    widget.data.basePrice = _baseController.text.trim();
    widget.data.minBilling = _minBillingController.text.trim();
    widget.data.extraKmCharge = _extraKmController.text.trim();
    widget.data.extraHourCharge = _extraHourController.text.trim();
    widget.data.driverAllowance = _driverAllowanceController.text.trim();
    widget.data.securityDeposit = _depositController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleWizardStep6Screen(data: widget.data),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.number,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38),
            prefixIcon: Icon(icon, color: const Color(0xFFF3BDC3)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFF3BDC3), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final needsDriver = widget.data.rentalMode == 'Chauffeur-driven' ||
        widget.data.rentalMode == 'Both';

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
                          child: Text('Pricing',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('You can change this any time',
                        style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 20),

                    const Text('Pricing model *',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kVehiclePricingModels.map((m) {
                        final sel = widget.data.pricingModel == m;
                        return GestureDetector(
                          onTap: () => setState(
                              () => widget.data.pricingModel = m),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: sel
                                  ? const Color(0xFFFFF0F3)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: sel
                                    ? const Color(0xFFF3BDC3)
                                    : Colors.black12,
                                width: sel ? 2 : 1,
                              ),
                            ),
                            child: Text(m,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: sel
                                        ? FontWeight.bold
                                        : FontWeight.w500)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    _field(
                      controller: _baseController,
                      label: 'Base price (₹) *',
                      hint: 'e.g. 2500',
                      icon: Icons.currency_rupee_rounded,
                    ),
                    _field(
                      controller: _minBillingController,
                      label: 'Minimum billing (optional)',
                      hint: 'e.g. 250 km/day',
                      icon: Icons.timer_outlined,
                      keyboardType: TextInputType.text,
                    ),
                    _field(
                      controller: _extraKmController,
                      label: 'Extra km charge (₹)',
                      hint: 'e.g. 15',
                      icon: Icons.add_road_rounded,
                    ),
                    _field(
                      controller: _extraHourController,
                      label: 'Extra hour charge (₹)',
                      hint: 'e.g. 200',
                      icon: Icons.hourglass_bottom_rounded,
                    ),
                    if (needsDriver)
                      _field(
                        controller: _driverAllowanceController,
                        label: 'Driver allowance (₹/day)',
                        hint: 'e.g. 300',
                        icon: Icons.support_agent,
                      ),
                    _field(
                      controller: _depositController,
                      label: 'Security deposit (₹)',
                      hint: 'e.g. 5000',
                      icon: Icons.shield_outlined,
                    ),

                    const SizedBox(height: 8),
                    const Text('Fuel policy',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kFuelPolicies.map((p) {
                        final sel = widget.data.fuelPolicy == p;
                        return GestureDetector(
                          onTap: () => setState(
                              () => widget.data.fuelPolicy = p),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: sel
                                  ? const Color(0xFFFFF0F3)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: sel
                                    ? const Color(0xFFF3BDC3)
                                    : Colors.black12,
                                width: sel ? 2 : 1,
                              ),
                            ),
                            child: Text(p,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: sel
                                        ? FontWeight.bold
                                        : FontWeight.w500)),
                          ),
                        );
                      }).toList(),
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