import 'package:flutter/material.dart';
import '../../models/property_listing_data.dart';
import 'host_wizard_step14_screen.dart';
import 'wizard_helpers.dart';

class HostWizardStep13Screen extends StatefulWidget {
  final String userName;
  final PropertyListingData data;
  const HostWizardStep13Screen(
      {super.key, required this.userName, required this.data});

  @override
  State<HostWizardStep13Screen> createState() => _HostWizardStep13ScreenState();
}

class _HostWizardStep13ScreenState extends State<HostWizardStep13Screen> {
  final _activitiesController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _activitiesController.text = widget.data.activitiesOffered;
    _priceController.text = widget.data.expPrice;
  }

  @override
  void dispose() {
    _activitiesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _handleNext() {
    widget.data.activitiesOffered = _activitiesController.text.trim();
    widget.data.expPrice = _priceController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HostWizardStep14Screen(userName: widget.userName, data: widget.data),
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
                        Icon(Icons.local_activity_outlined,
                            color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Local Experience',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Offer something unique guests will remember',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    _dropdown(
                      label: 'Local/cultural experience offered?',
                      items: const ['Yes', 'No'],
                      value: widget.data.culturalExperience,
                      onChanged: (v) =>
                          setState(() => widget.data.culturalExperience = v),
                    ),
                    _dropdown(
                      label: 'Traditional/home-cooked food available?',
                      items: const ['Yes', 'No'],
                      value: widget.data.homeCookedFood,
                      onChanged: (v) =>
                          setState(() => widget.data.homeCookedFood = v),
                    ),
                    _dropdown(
                      label: 'Local guide available?',
                      items: const ['Yes', 'No'],
                      value: widget.data.localGuide,
                      onChanged: (v) =>
                          setState(() => widget.data.localGuide = v),
                    ),

                    const Text('Activities offered',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _activitiesController,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'e.g. Cooking class, Farm tour',
                        hintStyle: const TextStyle(color: Colors.black38),
                        prefixIcon: const Icon(Icons.hiking_rounded,
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

                    const Text('Experience price (₹)',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'e.g. 1000',
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