import 'package:flutter/material.dart';
import '../../models/tour_guide.dart';
import '../host/wizard_helpers.dart';
import 'guide_wizard_step5_screen.dart';

class GuideWizardStep4Screen extends StatefulWidget {
  final GuideProfileData data;
  const GuideWizardStep4Screen({super.key, required this.data});

  @override
  State<GuideWizardStep4Screen> createState() => _GuideWizardStep4ScreenState();
}

class _GuideWizardStep4ScreenState extends State<GuideWizardStep4Screen> {
  final _regionInputController = TextEditingController();
  final _licenseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _licenseController.text = widget.data.licenseNumber;
  }

  @override
  void dispose() {
    _regionInputController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  void _addRegion() {
    final r = _regionInputController.text.trim();
    if (r.isEmpty) return;
    if (widget.data.regionsCovered.contains(r)) {
      _regionInputController.clear();
      return;
    }
    setState(() {
      widget.data.regionsCovered.add(r);
      _regionInputController.clear();
    });
  }

  void _handleNext() {
    if (widget.data.regionsCovered.isEmpty) {
      _snack('Please add at least one region you guide in');
      return;
    }
    widget.data.licenseNumber = _licenseController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuideWizardStep5Screen(data: widget.data),
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
                        Icon(Icons.place_outlined,
                            color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Regions & certifications',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Where you guide, and what you are certified in',
                      style:
                          TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    const Text('Regions / cities you guide in *',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _regionInputController,
                            style: const TextStyle(fontSize: 15),
                            onSubmitted: (_) => _addRegion(),
                            decoration: InputDecoration(
                              hintText: 'e.g. Manali, Kerala, Goa',
                              hintStyle:
                                  const TextStyle(color: Colors.black38),
                              prefixIcon: const Icon(
                                  Icons.location_on_outlined,
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
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _addRegion,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3BDC3),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (widget.data.regionsCovered.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.data.regionsCovered.map((r) {
                          return Chip(
                            backgroundColor: const Color(0xFFFFF0F3),
                            label: Text(r,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600)),
                            deleteIconColor: Colors.black54,
                            onDeleted: () {
                              setState(
                                  () => widget.data.regionsCovered.remove(r));
                            },
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 28),

                    const Text('License / permit number (if any)',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _licenseController,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'e.g. MH-GUIDE-2018-3421',
                        hintStyle: const TextStyle(color: Colors.black38),
                        prefixIcon: const Icon(Icons.credit_card_rounded,
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
                    const SizedBox(height: 24),

                    Text(
                      'Certifications  (${widget.data.certifications.length} selected)',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kGuideCertifications.map((cert) {
                        final isSelected =
                            widget.data.certifications.contains(cert.label);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                widget.data.certifications
                                    .remove(cert.label);
                              } else {
                                widget.data.certifications.add(cert.label);
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  cert.icon,
                                  size: 18,
                                  color: isSelected
                                      ? const Color(0xFFF3BDC3)
                                      : Colors.black87,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  cert.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
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