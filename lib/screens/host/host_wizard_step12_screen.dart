import 'package:flutter/material.dart';
import '../../models/property_listing_data.dart';
import 'host_wizard_step13_screen.dart';
import 'wizard_helpers.dart';

class RuleOption {
  final String label;
  final IconData icon;
  final List<String> choices;
  const RuleOption(this.label, this.icon, this.choices);
}

const List<RuleOption> kHouseRuleOptions = [
  RuleOption('Check-in time', Icons.login_rounded,
      ['12:00 PM', '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM']),
  RuleOption('Check-out time', Icons.logout_rounded,
      ['9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM']),
  RuleOption('Smoking', Icons.smoking_rooms_rounded, ['Allowed', 'Not Allowed']),
  RuleOption('Pets', Icons.pets_rounded, ['Allowed', 'Not Allowed']),
  RuleOption('Parties', Icons.celebration_rounded, ['Allowed', 'Not Allowed']),
  RuleOption('Visitors', Icons.group_add_rounded, ['Yes', 'No']),
  RuleOption('Children', Icons.child_care_rounded, ['Allowed', 'Not Allowed']),
  RuleOption('Quiet Hours', Icons.volume_off_rounded,
      ['10 PM - 7 AM', '11 PM - 6 AM', 'No Quiet Hours']),
  RuleOption('Commercial Photography', Icons.camera_alt_rounded,
      ['Allowed', 'Not Allowed']),
  RuleOption('Events', Icons.event_rounded, ['Allowed', 'Not Allowed']),
];

class HostWizardStep12Screen extends StatefulWidget {
  final String userName;
  final PropertyListingData data;
  const HostWizardStep12Screen(
      {super.key, required this.userName, required this.data});

  @override
  State<HostWizardStep12Screen> createState() => _HostWizardStep12ScreenState();
}

class _HostWizardStep12ScreenState extends State<HostWizardStep12Screen> {
  final _rulesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _rulesController.text = widget.data.houseRulesOther;
  }

  @override
  void dispose() {
    _rulesController.dispose();
    super.dispose();
  }

  void _handleNext() {
    widget.data.houseRulesOther = _rulesController.text.trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HostWizardStep13Screen(userName: widget.userName, data: widget.data),
      ),
    );
  }

  String _getValue(String label) {
    switch (label) {
      case 'Check-in time': return widget.data.checkIn;
      case 'Check-out time': return widget.data.checkOut;
      case 'Smoking': return widget.data.smoking;
      case 'Pets': return widget.data.petsAllowed;
      case 'Parties': return widget.data.parties;
      case 'Visitors': return widget.data.visitorsAllowed;
      case 'Children': return widget.data.childrenAllowed;
      case 'Quiet Hours': return widget.data.quietHours;
      case 'Commercial Photography': return widget.data.commercialPhotography;
      case 'Events': return widget.data.events;
      default: return '';
    }
  }

  void _setValue(String label, String value) {
    setState(() {
      switch (label) {
        case 'Check-in time': widget.data.checkIn = value; break;
        case 'Check-out time': widget.data.checkOut = value; break;
        case 'Smoking': widget.data.smoking = value; break;
        case 'Pets': widget.data.petsAllowed = value; break;
        case 'Parties': widget.data.parties = value; break;
        case 'Visitors': widget.data.visitorsAllowed = value; break;
        case 'Children': widget.data.childrenAllowed = value; break;
        case 'Quiet Hours': widget.data.quietHours = value; break;
        case 'Commercial Photography': widget.data.commercialPhotography = value; break;
        case 'Events': widget.data.events = value; break;
        default: break;
      }
    });
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
                        Text('House Rules',
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Set expectations for your guests',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    ...kHouseRuleOptions.map((rule) {
                      final currentValue = _getValue(rule.label);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(rule.icon,
                                    size: 22, color: const Color(0xFFF3BDC3)),
                                const SizedBox(width: 10),
                                Text(
                                  rule.label,
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: rule.choices.map((choice) {
                                final isSelected = currentValue == choice;
                                return GestureDetector(
                                  onTap: () => _setValue(rule.label, choice),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFF3BDC3)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFFF3BDC3)
                                            : Colors.black12,
                                      ),
                                    ),
                                    child: Text(
                                      choice,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.black54,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 8),
                    const Text('Other house rules',
                        style:
                            TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _rulesController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Anything else guests should know...',
                        hintStyle: const TextStyle(color: Colors.black38),
                        prefixIcon: const Icon(Icons.edit_note_rounded,
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