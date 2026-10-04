import 'package:flutter/material.dart';
import '../../models/tour_guide.dart';
import '../host/wizard_helpers.dart';
import 'guide_wizard_step3_screen.dart';

class GuideWizardStep2Screen extends StatefulWidget {
  final GuideProfileData data;
  const GuideWizardStep2Screen({super.key, required this.data});

  @override
  State<GuideWizardStep2Screen> createState() => _GuideWizardStep2ScreenState();
}

class _GuideWizardStep2ScreenState extends State<GuideWizardStep2Screen> {
  final _taglineController = TextEditingController();
  final _bioController = TextEditingController();
  final _yearsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _taglineController.text = widget.data.tagline;
    _bioController.text = widget.data.bio;
    _yearsController.text = widget.data.yearsExperience;
  }

  @override
  void dispose() {
    _taglineController.dispose();
    _bioController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  void _handleNext() {
    final tagline = _taglineController.text.trim();
    final bio = _bioController.text.trim();
    final years = _yearsController.text.trim();

    if (tagline.isEmpty) {
      _snack('Please add a short tagline');
      return;
    }
    if (bio.isEmpty) {
      _snack('Please add a bio');
      return;
    }
    if (years.isEmpty) {
      _snack('Please enter your years of experience');
      return;
    }

    widget.data.tagline = tagline;
    widget.data.bio = bio;
    widget.data.yearsExperience = years;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuideWizardStep3Screen(data: widget.data),
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
                        Icon(Icons.description_outlined,
                            color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('About you',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Help travelers get to know you',
                      style:
                          TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    const Text('Tagline *',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _taglineController,
                      maxLength: 80,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText:
                            'e.g. Certified Himalayan trekking guide since 2012',
                        hintStyle: const TextStyle(color: Colors.black38),
                        counterText: '',
                        prefixIcon: const Icon(Icons.short_text_rounded,
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
                    const SizedBox(height: 20),

                    const Text('Bio *',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bioController,
                      maxLines: 5,
                      maxLength: 500,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText:
                            'Tell travelers about your background, what drives you, and why you love guiding...',
                        hintStyle: const TextStyle(color: Colors.black38),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFFF3BDC3), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text('Years of experience *',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _yearsController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'e.g. 8',
                        hintStyle: const TextStyle(color: Colors.black38),
                        prefixIcon: const Icon(Icons.timelapse_rounded,
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