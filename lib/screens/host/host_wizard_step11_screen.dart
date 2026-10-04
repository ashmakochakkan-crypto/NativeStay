import 'package:flutter/material.dart';
import '../../models/property_listing_data.dart';
import 'host_wizard_step12_screen.dart';
import 'wizard_helpers.dart';

class HostWizardStep11Screen extends StatefulWidget {
  final String userName;
  final PropertyListingData data;
  const HostWizardStep11Screen(
      {super.key, required this.userName, required this.data});

  @override
  State<HostWizardStep11Screen> createState() => _HostWizardStep11ScreenState();
}

class _HostWizardStep11ScreenState extends State<HostWizardStep11Screen> {
  final _hospitalController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _hospitalController.text = widget.data.nearestHospital;
    _instructionsController.text = widget.data.safetyInstructions;
  }

  @override
  void dispose() {
    _hospitalController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _handleNext() {
    widget.data.nearestHospital = _hospitalController.text.trim();
    widget.data.safetyInstructions = _instructionsController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HostWizardStep12Screen(userName: widget.userName, data: widget.data),
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
                        Icon(Icons.security_outlined,
                            color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Text('Safety',
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'What safety features does your place have?',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    _dropdown(
                      label: 'First-aid kit',
                      items: const ['Yes', 'No'],
                      value: widget.data.firstAid,
                      onChanged: (v) =>
                          setState(() => widget.data.firstAid = v),
                    ),
                    _dropdown(
                      label: 'Fire extinguisher',
                      items: const ['Yes', 'No'],
                      value: widget.data.fireExtinguisher,
                      onChanged: (v) =>
                          setState(() => widget.data.fireExtinguisher = v),
                    ),
                    _dropdown(
                      label: 'CCTV in common areas',
                      items: const ['Yes', 'No'],
                      value: widget.data.cctvCommon,
                      onChanged: (v) =>
                          setState(() => widget.data.cctvCommon = v),
                    ),

                    const Text('Nearest hospital / medical facility',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _hospitalController,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'e.g. City Hospital, 3 km',
                        hintStyle: const TextStyle(color: Colors.black38),
                        prefixIcon: const Icon(Icons.local_hospital_outlined,
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

                    const Text('Safety instructions for guests',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _instructionsController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Anything guests should know...',
                        hintStyle: const TextStyle(color: Colors.black38),
                        prefixIcon: const Icon(Icons.info_outline,
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