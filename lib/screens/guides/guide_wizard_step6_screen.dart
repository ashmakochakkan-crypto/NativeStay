import 'package:flutter/material.dart';
import '../../models/tour_guide.dart';
import '../host/wizard_helpers.dart';
import 'guide_wizard_step7_screen.dart';

class GuideWizardStep6Screen extends StatefulWidget {
  final GuideProfileData data;
  const GuideWizardStep6Screen({super.key, required this.data});

  @override
  State<GuideWizardStep6Screen> createState() => _GuideWizardStep6ScreenState();
}

class _GuideWizardStep6ScreenState extends State<GuideWizardStep6Screen> {
  final _meetingController = TextEditingController();
  final _inclusionsController = TextEditingController();
  final _exclusionsController = TextEditingController();
  final _rulesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _meetingController.text = widget.data.meetingPoint;
    _inclusionsController.text = widget.data.inclusions;
    _exclusionsController.text = widget.data.exclusions;
    _rulesController.text = widget.data.houseRules;
  }

  @override
  void dispose() {
    _meetingController.dispose();
    _inclusionsController.dispose();
    _exclusionsController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_meetingController.text.trim().isEmpty) {
      _snack('Please enter a meeting point');
      return;
    }
    widget.data.meetingPoint = _meetingController.text.trim();
    widget.data.inclusions = _inclusionsController.text.trim();
    widget.data.exclusions = _exclusionsController.text.trim();
    widget.data.houseRules = _rulesController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuideWizardStep7Screen(data: widget.data),
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
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38),
            prefixIcon: Icon(icon, color: const Color(0xFFF3BDC3)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFFF3BDC3), width: 2),
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
                        Icon(Icons.info_outline,
                            color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Meeting & rules',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Set expectations for your tours',
                      style:
                          TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    _field(
                      controller: _meetingController,
                      label: 'Default meeting point *',
                      hint: 'e.g. Hotel pickup, City center',
                      icon: Icons.pin_drop_outlined,
                    ),
                    _field(
                      controller: _inclusionsController,
                      label: 'What\'s included',
                      hint: 'e.g. Transportation, tickets, snacks',
                      icon: Icons.check_circle_outline_rounded,
                      maxLines: 2,
                    ),
                    _field(
                      controller: _exclusionsController,
                      label: 'Not included',
                      hint: 'e.g. Meals, personal expenses',
                      icon: Icons.cancel_outlined,
                      maxLines: 2,
                    ),
                    _field(
                      controller: _rulesController,
                      label: 'House rules / what to bring',
                      hint:
                          'e.g. Wear comfortable shoes, bring water, no smoking',
                      icon: Icons.rule_outlined,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 8),
                    const Text('Cancellation policy *',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...kGuideCancellationPolicies.map((policy) {
                      final isSelected =
                          widget.data.cancellationPolicy == policy;
                      return GestureDetector(
                        onTap: () => setState(
                            () => widget.data.cancellationPolicy = policy),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFFF0F3)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFF3BDC3)
                                  : Colors.black12,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      policy,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      policy == 'Flexible'
                                          ? 'Full refund up to 24 hours before'
                                          : policy == 'Moderate'
                                              ? 'Full refund up to 5 days before'
                                              : 'No refunds after booking',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54),
                                    ),
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
                    }),
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