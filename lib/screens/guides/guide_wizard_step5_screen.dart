import 'package:flutter/material.dart';
import '../../models/tour_guide.dart';
import '../host/wizard_helpers.dart';
import 'guide_wizard_step6_screen.dart';

class GuideWizardStep5Screen extends StatefulWidget {
  final GuideProfileData data;
  const GuideWizardStep5Screen({super.key, required this.data});

  @override
  State<GuideWizardStep5Screen> createState() => _GuideWizardStep5ScreenState();
}

class _GuideWizardStep5ScreenState extends State<GuideWizardStep5Screen> {
  final _priceController = TextEditingController();
  final _maxGroupController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _priceController.text = widget.data.basePrice;
    _maxGroupController.text = widget.data.maxGroupSize;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _maxGroupController.dispose();
    super.dispose();
  }

  void _handleNext() {
    final price = _priceController.text.trim();
    if (price.isEmpty) {
      _snack('Please enter your base price');
      return;
    }
    widget.data.basePrice = price;
    widget.data.maxGroupSize = _maxGroupController.text.trim().isEmpty
        ? '10'
        : _maxGroupController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuideWizardStep6Screen(data: widget.data),
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
                        Icon(Icons.currency_rupee_rounded,
                            color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Your pricing',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'You can update this any time',
                      style:
                          TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    const Text('Pricing model *',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...kGuidePricingModels.map((model) {
                      final isSelected = widget.data.pricingModel == model;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => widget.data.pricingModel = model),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
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
                          child: Row(
                            children: [
                              Icon(
                                Icons.currency_rupee_rounded,
                                size: 22,
                                color: isSelected
                                    ? const Color(0xFFF3BDC3)
                                    : Colors.black87,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  model,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
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
                    const SizedBox(height: 20),

                    const Text('Base price (₹) *',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'e.g. 2500',
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
                    const SizedBox(height: 20),

                    const Text('Maximum group size',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _maxGroupController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'e.g. 10',
                        hintStyle: const TextStyle(color: Colors.black38),
                        prefixIcon: const Icon(Icons.group_outlined,
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