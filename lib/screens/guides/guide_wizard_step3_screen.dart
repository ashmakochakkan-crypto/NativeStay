import 'package:flutter/material.dart';
import '../../models/tour_guide.dart';
import '../host/wizard_helpers.dart';
import 'guide_wizard_step4_screen.dart';

class GuideWizardStep3Screen extends StatefulWidget {
  final GuideProfileData data;
  const GuideWizardStep3Screen({super.key, required this.data});

  @override
  State<GuideWizardStep3Screen> createState() => _GuideWizardStep3ScreenState();
}

class _GuideWizardStep3ScreenState extends State<GuideWizardStep3Screen> {
  void _handleNext() {
    if (widget.data.languages.isEmpty) {
      _snack('Please select at least one language');
      return;
    }
    if (widget.data.specialties.isEmpty) {
      _snack('Please select at least one specialty');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuideWizardStep4Screen(data: widget.data),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
                        Icon(Icons.translate_rounded,
                            color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Languages & specialties',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'What you speak and what you do best',
                      style:
                          TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Languages you speak *  (${widget.data.languages.length} selected)',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kGuideLanguages.map((lang) {
                        final isSelected =
                            widget.data.languages.contains(lang.label);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                widget.data.languages.remove(lang.label);
                              } else {
                                widget.data.languages.add(lang.label);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFFF0F3)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFF3BDC3)
                                    : Colors.black12,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              lang.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    Text(
                      'Specialties *  (${widget.data.specialties.length} selected)',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
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
                      itemCount: kGuideSpecialties.length,
                      itemBuilder: (context, index) {
                        final s = kGuideSpecialties[index];
                        final isSelected =
                            widget.data.specialties.contains(s.label);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                widget.data.specialties.remove(s.label);
                              } else {
                                widget.data.specialties.add(s.label);
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
                                  s.icon,
                                  size: 28,
                                  color: isSelected
                                      ? const Color(0xFFF3BDC3)
                                      : Colors.black87,
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: Text(
                                    s.label,
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