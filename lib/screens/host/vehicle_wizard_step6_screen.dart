import 'package:flutter/material.dart';
import '../../models/vehicle_listing.dart';
import '../rentals/rental_vehicles.dart';
import 'vehicle_wizard_step7_screen.dart';
import 'wizard_helpers.dart';

class VehicleWizardStep6Screen extends StatefulWidget {
  final VehicleListingData data;
  const VehicleWizardStep6Screen({super.key, required this.data});

  @override
  State<VehicleWizardStep6Screen> createState() =>
      _VehicleWizardStep6ScreenState();
}

class _VehicleWizardStep6ScreenState extends State<VehicleWizardStep6Screen> {
  final _lateFeeController = TextEditingController();
  final _cleaningFeeController = TextEditingController();
  final _mileageLimitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _lateFeeController.text = widget.data.lateReturnFee;
    _cleaningFeeController.text = widget.data.cleaningFee;
    _mileageLimitController.text = widget.data.mileageLimit;
  }

  @override
  void dispose() {
    _lateFeeController.dispose();
    _cleaningFeeController.dispose();
    _mileageLimitController.dispose();
    super.dispose();
  }

  void _handleNext() {
    widget.data.lateReturnFee = _lateFeeController.text.trim();
    widget.data.cleaningFee = _cleaningFeeController.text.trim();
    widget.data.mileageLimit = _mileageLimitController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleWizardStep7Screen(data: widget.data),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
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

  Widget _dropdownRow({
    required String label,
    required List<String> items,
    required String value,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFFF3BDC3)),
              items:
                  items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => onChanged(v!),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
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
                        Icon(Icons.rule_outlined,
                            color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Policies',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('Set expectations for renters',
                        style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 20),

                    const Text('Cancellation policy *',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...kVehicleCancellationPolicies.map((p) {
                      final sel = widget.data.cancellationPolicy == p;
                      return GestureDetector(
                        onTap: () => setState(
                            () => widget.data.cancellationPolicy = p),
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
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
                                          fontSize: 12,
                                          color: Colors.black54),
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

                    const SizedBox(height: 8),
                    _field(
                      controller: _lateFeeController,
                      label: 'Late return fee (₹)',
                      hint: 'e.g. 500 per hour',
                      icon: Icons.schedule_rounded,
                    ),
                    _field(
                      controller: _cleaningFeeController,
                      label: 'Cleaning fee (₹)',
                      hint: 'e.g. 300',
                      icon: Icons.cleaning_services_rounded,
                    ),
                    _field(
                      controller: _mileageLimitController,
                      label: 'Mileage limit',
                      hint: 'e.g. 300 km/day',
                      icon: Icons.speed_rounded,
                    ),

                    _dropdownRow(
                      label: 'Smoking',
                      items: kAllowedNotAllowed,
                      value: widget.data.smokingPolicy,
                      onChanged: (v) =>
                          setState(() => widget.data.smokingPolicy = v),
                    ),
                    _dropdownRow(
                      label: 'Pets',
                      items: kAllowedNotAllowed,
                      value: widget.data.petPolicy,
                      onChanged: (v) =>
                          setState(() => widget.data.petPolicy = v),
                    ),
                    _dropdownRow(
                      label: 'Interstate travel allowed?',
                      items: kYesNo,
                      value: widget.data.interstateAllowed,
                      onChanged: (v) =>
                          setState(() => widget.data.interstateAllowed = v),
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