import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/tour_guide.dart';

class GuideTourCreateScreen extends StatefulWidget {
  final String guideId;
  final TourPackage? existingTour;
  const GuideTourCreateScreen({
    super.key,
    required this.guideId,
    this.existingTour,
  });

  @override
  State<GuideTourCreateScreen> createState() =>
      _GuideTourCreateScreenState();
}

class _GuideTourCreateScreenState extends State<GuideTourCreateScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _durationController = TextEditingController();
  final _groupController = TextEditingController();
  final _priceController = TextEditingController();
  final _meetingController = TextEditingController();
  final _itineraryController = TextEditingController();

  List<String> _languages = [];
  List<String> _inclusions = [];
  String _pricingModel = 'Per Person';
  String _cancellationPolicy = 'Flexible';
  bool _isSubmitting = false;

  static const List<String> _inclusionOptions = [
    'Transport',
    'Entry tickets',
    'Meals',
    'Snacks & water',
    'Photography',
    'Local guide fee',
    'Equipment rental',
    'Hotel pickup',
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.existingTour;
    if (t != null) {
      _titleController.text = t.title;
      _descController.text = t.description;
      _durationController.text = t.duration;
      _groupController.text = t.groupSize;
      _priceController.text = t.price;
      _meetingController.text = t.meetingPoint;
      _itineraryController.text = t.itinerary;
      _languages = List<String>.from(t.languages);
      _inclusions = List<String>.from(t.inclusions);
      _pricingModel = t.pricingModel;
      _cancellationPolicy = t.cancellationPolicy;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _durationController.dispose();
    _groupController.dispose();
    _priceController.dispose();
    _meetingController.dispose();
    _itineraryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      _snack('Please enter a tour title');
      return;
    }
    if (_descController.text.trim().isEmpty) {
      _snack('Please add a description');
      return;
    }
    if (_priceController.text.trim().isEmpty) {
      _snack('Please enter a price');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final payload = {
        'guideId': widget.guideId,
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'duration': _durationController.text.trim(),
        'groupSize': _groupController.text.trim(),
        'price': _priceController.text.trim(),
        'pricingModel': _pricingModel,
        'languages': _languages,
        'inclusions': _inclusions,
        'itinerary': _itineraryController.text.trim(),
        'meetingPoint': _meetingController.text.trim(),
        'cancellationPolicy': _cancellationPolicy,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (widget.existingTour != null) {
        await FirebaseFirestore.instance
            .collection('tour_packages')
            .doc(widget.existingTour!.docId)
            .update(payload);
      } else {
        await FirebaseFirestore.instance
            .collection('tour_packages')
            .add(payload);
      }
    } catch (e) {
      debugPrint('Tour submit error: $e');
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save tour: $e')),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(widget.existingTour != null
              ? 'Tour updated'
              : 'Tour published!')),
    );
    Navigator.pop(context, true);
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
    TextInputType keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
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
    final isEditing = widget.existingTour != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(isEditing ? 'Edit tour' : 'New tour',
            style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
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
                    _field(
                      controller: _titleController,
                      label: 'Tour title *',
                      hint: 'e.g. Sunrise trek to Triund',
                      icon: Icons.title_rounded,
                    ),
                    _field(
                      controller: _descController,
                      label: 'Short description *',
                      hint: 'What makes this tour special...',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            controller: _durationController,
                            label: 'Duration',
                            hint: 'e.g. 4 hours',
                            icon: Icons.timelapse_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            controller: _groupController,
                            label: 'Group size',
                            hint: 'e.g. 6',
                            icon: Icons.group_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const Text('Pricing model',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kGuidePricingModels.map((m) {
                        final sel = _pricingModel == m;
                        return GestureDetector(
                          onTap: () => setState(() => _pricingModel = m),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: sel
                                  ? const Color(0xFFFFF0F3)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: sel
                                    ? const Color(0xFFF3BDC3)
                                    : Colors.black12,
                                width: sel ? 2 : 1,
                              ),
                            ),
                            child: Text(m,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: sel
                                        ? FontWeight.bold
                                        : FontWeight.w500)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    _field(
                      controller: _priceController,
                      label: 'Price (₹) *',
                      hint: 'e.g. 1500',
                      icon: Icons.currency_rupee_rounded,
                      keyboardType: TextInputType.number,
                    ),

                    const Text('Languages offered',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kGuideLanguages.map((lang) {
                        final sel = _languages.contains(lang.label);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (sel) {
                                _languages.remove(lang.label);
                              } else {
                                _languages.add(lang.label);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: sel
                                  ? const Color(0xFFFFF0F3)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: sel
                                    ? const Color(0xFFF3BDC3)
                                    : Colors.black12,
                                width: sel ? 2 : 1,
                              ),
                            ),
                            child: Text(lang.label,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: sel
                                        ? FontWeight.bold
                                        : FontWeight.w500)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    const Text("What's included",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _inclusionOptions.map((inc) {
                        final sel = _inclusions.contains(inc);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (sel) {
                                _inclusions.remove(inc);
                              } else {
                                _inclusions.add(inc);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: sel
                                  ? const Color(0xFFFFF0F3)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: sel
                                    ? const Color(0xFFF3BDC3)
                                    : Colors.black12,
                                width: sel ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (sel) ...[
                                  const Icon(Icons.check_rounded,
                                      size: 16,
                                      color: Color(0xFFF3BDC3)),
                                  const SizedBox(width: 6),
                                ],
                                Text(inc,
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: sel
                                            ? FontWeight.bold
                                            : FontWeight.w500)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    _field(
                      controller: _meetingController,
                      label: 'Meeting point',
                      hint: 'e.g. McLeodganj main square',
                      icon: Icons.pin_drop_outlined,
                    ),
                    _field(
                      controller: _itineraryController,
                      label: 'Itinerary',
                      hint:
                          'Step-by-step plan (optional, but powerful)...',
                      icon: Icons.format_list_numbered_rounded,
                      maxLines: 4,
                    ),

                    const Text('Cancellation policy',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...kGuideCancellationPolicies.map((p) {
                      final sel = _cancellationPolicy == p;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _cancellationPolicy = p),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: sel
                                ? const Color(0xFFFFF0F3)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: sel
                                  ? const Color(0xFFF3BDC3)
                                  : Colors.black12,
                              width: sel ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(p,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ),
                              if (sel)
                                const Icon(Icons.check_circle,
                                    color: Color(0xFFF3BDC3), size: 20),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                isEditing
                                    ? 'Save changes'
                                    : 'Publish tour',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}