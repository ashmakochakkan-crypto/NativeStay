import 'package:flutter/material.dart';
import '../../models/vehicle_listing.dart';
import '../rentals/rental_vehicles.dart';
import 'vehicle_wizard_step5_screen.dart';
import 'wizard_helpers.dart';

class VehicleWizardStep4Screen extends StatefulWidget {
  final VehicleListingData data;
  const VehicleWizardStep4Screen({super.key, required this.data});

  @override
  State<VehicleWizardStep4Screen> createState() =>
      _VehicleWizardStep4ScreenState();
}

class _VehicleWizardStep4ScreenState extends State<VehicleWizardStep4Screen> {
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _deliveryFeeController = TextEditingController();

  final _driverNameController = TextEditingController();
  final _driverPhoneController = TextEditingController();
  final _driverExpController = TextEditingController();
  final _driverLangController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _stateController.text = widget.data.state;
    _cityController.text = widget.data.city;
    _areaController.text = widget.data.area;
    _deliveryFeeController.text = widget.data.deliveryFee;
    _driverNameController.text = widget.data.driverName;
    _driverPhoneController.text = widget.data.driverPhone;
    _driverExpController.text = widget.data.driverExperience;
    _driverLangController.text = widget.data.driverLanguages;
  }

  @override
  void dispose() {
    _stateController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _deliveryFeeController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _driverExpController.dispose();
    _driverLangController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_stateController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty) {
      _snack('Please fill in state and city');
      return;
    }

    final needsDriver = widget.data.rentalMode == 'Chauffeur-driven' ||
        widget.data.rentalMode == 'Both';

    if (needsDriver && _driverNameController.text.trim().isEmpty) {
      _snack('Please enter driver name (or switch to Self-drive)');
      return;
    }

    widget.data.state = _stateController.text.trim();
    widget.data.city = _cityController.text.trim();
    widget.data.area = _areaController.text.trim();
    widget.data.deliveryFee = _deliveryFeeController.text.trim();
    widget.data.driverName = _driverNameController.text.trim();
    widget.data.driverPhone = _driverPhoneController.text.trim();
    widget.data.driverExperience = _driverExpController.text.trim();
    widget.data.driverLanguages = _driverLangController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleWizardStep5Screen(data: widget.data),
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

  Widget _optionCard({
    required String label,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF0F3) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFF3BDC3) : Colors.black12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 26,
                color: isSelected
                    ? const Color(0xFFF3BDC3)
                    : Colors.black87),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: Color(0xFFF3BDC3), size: 22),
          ],
        ),
      ),
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
                        Icon(Icons.place_outlined,
                            color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Location & mode',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Where your vehicle is and how it can be rented',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 20),

                    _field(
                      controller: _stateController,
                      label: 'State *',
                      hint: 'e.g. Himachal Pradesh',
                      icon: Icons.map_outlined,
                    ),
                    _field(
                      controller: _cityController,
                      label: 'City *',
                      hint: 'e.g. Manali',
                      icon: Icons.location_city_rounded,
                    ),
                    _field(
                      controller: _areaController,
                      label: 'Area / Locality',
                      hint: 'e.g. Old Manali',
                      icon: Icons.place_outlined,
                    ),

                    const SizedBox(height: 8),
                    const Text('Rental mode *',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...kRentalModes.map((m) {
                      final isSelected = widget.data.rentalMode == m;
                      final subtitle = m == 'Self-drive'
                          ? 'Customer drives the vehicle'
                          : m == 'Chauffeur-driven'
                              ? 'Driver included'
                              : 'Offer both options';
                      final icon = m == 'Self-drive'
                          ? Icons.person_outline
                          : m == 'Chauffeur-driven'
                              ? Icons.support_agent
                              : Icons.swap_horiz_rounded;
                      return _optionCard(
                        label: m,
                        subtitle: subtitle,
                        icon: icon,
                        isSelected: isSelected,
                        onTap: () =>
                            setState(() => widget.data.rentalMode = m),
                      );
                    }),

                    const SizedBox(height: 12),
                    const Text('Delivery to customer?',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kYesNo.map((opt) {
                        final sel = widget.data.deliveryAvailable == opt;
                        return GestureDetector(
                          onTap: () => setState(
                              () => widget.data.deliveryAvailable = opt),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
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
                            child: Text(opt,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: sel
                                        ? FontWeight.bold
                                        : FontWeight.w500)),
                          ),
                        );
                      }).toList(),
                    ),
                    if (widget.data.deliveryAvailable == 'Yes') ...[
                      const SizedBox(height: 14),
                      _field(
                        controller: _deliveryFeeController,
                        label: 'Delivery fee (₹)',
                        hint: 'e.g. 300',
                        icon: Icons.currency_rupee_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ],

                    if (needsDriver) ...[
                      const SizedBox(height: 8),
                      const Divider(height: 1, color: Colors.black12),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Icon(Icons.support_agent,
                              color: Color(0xFFF3BDC3), size: 24),
                          SizedBox(width: 8),
                          Text('Driver details',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _field(
                        controller: _driverNameController,
                        label: 'Driver name *',
                        hint: 'e.g. Ravi Kumar',
                        icon: Icons.person_outline,
                      ),
                      _field(
                        controller: _driverPhoneController,
                        label: 'Driver phone',
                        hint: '10-digit number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      _field(
                        controller: _driverExpController,
                        label: 'Years of experience',
                        hint: 'e.g. 10',
                        icon: Icons.timelapse_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      _field(
                        controller: _driverLangController,
                        label: 'Languages spoken',
                        hint: 'e.g. Hindi, English',
                        icon: Icons.translate_rounded,
                      ),
                    ],
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