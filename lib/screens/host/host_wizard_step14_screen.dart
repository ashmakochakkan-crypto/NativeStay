import 'package:flutter/material.dart';
import '../../models/property_listing_data.dart';
import 'host_wizard_step15_screen.dart';
import 'wizard_helpers.dart';

class HostWizardStep14Screen extends StatefulWidget {
  final String userName;
  final PropertyListingData data;
  const HostWizardStep14Screen(
      {super.key, required this.userName, required this.data});

  @override
  State<HostWizardStep14Screen> createState() => _HostWizardStep14ScreenState();
}

class _HostWizardStep14ScreenState extends State<HostWizardStep14Screen> {
  final _vehicleTypeController = TextEditingController();
  final _vehiclePriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vehicleTypeController.text =
        widget.data.vehicleType == 'None' ? '' : widget.data.vehicleType;
    _vehiclePriceController.text = widget.data.vehiclePrice;
  }

  @override
  void dispose() {
    _vehicleTypeController.dispose();
    _vehiclePriceController.dispose();
    super.dispose();
  }

  void _handleNext() {
    widget.data.vehicleType = _vehicleTypeController.text.trim();
    widget.data.vehiclePrice = _vehiclePriceController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HostWizardStep15Screen(userName: widget.userName, data: widget.data),
      ),
    );
  }

  Widget _dropdown({
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
        const SizedBox(height: 16),
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
                        Icon(Icons.directions_car_outlined,
                            color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Text('Vehicle Service',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Offer a ride to your guests',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    _dropdown(
                      label: 'Vehicle available?',
                      items: const ['Yes', 'No'],
                      value: widget.data.vehicleAvailable,
                      onChanged: (v) =>
                          setState(() => widget.data.vehicleAvailable = v),
                    ),

                    const Text('Vehicle type',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _vehicleTypeController,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'e.g. Sedan, SUV, Scooter',
                        hintStyle: const TextStyle(color: Colors.black38),
                        prefixIcon: const Icon(Icons.directions_car_rounded,
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
                    const SizedBox(height: 16),

                    _dropdown(
                      label: 'Driver option',
                      items: const ['With Driver', 'Without Driver'],
                      value: widget.data.driverOption,
                      onChanged: (v) =>
                          setState(() => widget.data.driverOption = v),
                    ),

                    const Text('Vehicle rental price (₹)',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _vehiclePriceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'e.g. 1500 / day',
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