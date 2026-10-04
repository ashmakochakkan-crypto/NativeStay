import 'package:flutter/material.dart';
import '../../models/property_listing_data.dart';
import 'host_wizard_step11_screen.dart';
import 'wizard_helpers.dart';

class HostWizardStep10Screen extends StatefulWidget {
  final String userName;
  final PropertyListingData data;
  const HostWizardStep10Screen(
      {super.key, required this.userName, required this.data});

  @override
  State<HostWizardStep10Screen> createState() => _HostWizardStep10ScreenState();
}

class _HostWizardStep10ScreenState extends State<HostWizardStep10Screen> {
  final _contactPersonController = TextEditingController();
  final _emergencyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _contactPersonController.text = widget.data.contactPerson;
    _emergencyController.text = widget.data.emergencyNum;
  }

  @override
  void dispose() {
    _contactPersonController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_emergencyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter an emergency contact number')),
      );
      return;
    }
    widget.data.contactPerson = _contactPersonController.text.trim();
    widget.data.emergencyNum = _emergencyController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HostWizardStep11Screen(userName: widget.userName, data: widget.data),
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
                        Icon(Icons.access_time_rounded,
                            color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Your availability',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Let guests know how to reach you',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    _dropdown(
                      label: 'Is the host available during the stay?',
                      items: const ['Always', 'Sometimes', 'No'],
                      value: widget.data.hostAvailable,
                      onChanged: (v) =>
                          setState(() => widget.data.hostAvailable = v),
                    ),
                    _dropdown(
                      label: 'Is a family member available for assistance?',
                      items: const ['Yes', 'No'],
                      value: widget.data.familyAssistance,
                      onChanged: (v) =>
                          setState(() => widget.data.familyAssistance = v),
                    ),

                    const Text('Who can guests contact for help?',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _contactPersonController,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'e.g. Host, Caretaker',
                        hintStyle: const TextStyle(color: Colors.black38),
                        prefixIcon: const Icon(Icons.support_agent_outlined,
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

                    const Text('Emergency contact number *',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emergencyController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: '10-digit number',
                        hintStyle: const TextStyle(color: Colors.black38),
                        prefixIcon: const Icon(Icons.emergency_outlined,
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