import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/tour_guide.dart';
import '../host/wizard_helpers.dart';
import 'guide_dashboard_screen.dart';

class GuideWizardStep7Screen extends StatefulWidget {
  final GuideProfileData data;
  const GuideWizardStep7Screen({super.key, required this.data});

  @override
  State<GuideWizardStep7Screen> createState() => _GuideWizardStep7ScreenState();
}

class _GuideWizardStep7ScreenState extends State<GuideWizardStep7Screen> {
  bool _isSubmitting = false;

  Future<void> _publish() async {
    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) setState(() => _isSubmitting = false);
      return;
    }

    try {
      final payload = {
        'userId': user.uid,
        'fullName': widget.data.fullName,
        'displayName': widget.data.displayName,
        'phone': widget.data.phone,
        'email': widget.data.email,
        'photoUrl': widget.data.photoUrl,
        'photos': widget.data.photos,
        'tagline': widget.data.tagline,
        'bio': widget.data.bio,
        'yearsExperience': widget.data.yearsExperience,
        'languages': widget.data.languages,
        'specialties': widget.data.specialties,
        'regionsCovered': widget.data.regionsCovered,
        'licenseNumber': widget.data.licenseNumber,
        'certifications': widget.data.certifications,
        'pricingModel': widget.data.pricingModel,
        'basePrice': widget.data.basePrice,
        'maxGroupSize': widget.data.maxGroupSize,
        'meetingPoint': widget.data.meetingPoint,
        'inclusions': widget.data.inclusions,
        'exclusions': widget.data.exclusions,
        'houseRules': widget.data.houseRules,
        'cancellationPolicy': widget.data.cancellationPolicy,
        'isPublished': true,
      };

      if (widget.data.docId != null && widget.data.docId!.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('tour_guides')
            .doc(widget.data.docId)
            .update(payload);
      } else {
        await FirebaseFirestore.instance.collection('tour_guides').add({
          ...payload,
          'submittedAt': FieldValue.serverTimestamp(),
          'rating': 0,
          'reviewCount': 0,
        });
      }
    } catch (e) {
      debugPrint('Publish guide error: $e');
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not publish guide profile: $e')),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const GuideDashboardScreen()),
      (route) => route.isFirst,
    );
  }

  Widget _summaryRow(IconData icon, String label, String val) {
    if (val.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFF3BDC3)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: Colors.black54, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              val,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;

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
                        Icon(Icons.check_circle_outline,
                            color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Almost there!',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Review your guide profile before publishing',
                      style:
                          TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.displayName,
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(d.tagline,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54)),
                          const Divider(height: 24),
                          _summaryRow(Icons.person_outline, 'Full name',
                              d.fullName),
                          _summaryRow(Icons.phone_outlined, 'Phone',
                              d.phone),
                          _summaryRow(Icons.timelapse_rounded, 'Experience',
                              '${d.yearsExperience} years'),
                          _summaryRow(Icons.translate_rounded, 'Languages',
                              d.languages.join(', ')),
                          _summaryRow(Icons.star_outline_rounded,
                              'Specialties', d.specialties.join(', ')),
                          _summaryRow(Icons.place_outlined, 'Regions',
                              d.regionsCovered.join(', ')),
                          _summaryRow(Icons.credit_card_rounded, 'License',
                              d.licenseNumber),
                          _summaryRow(Icons.currency_rupee_rounded, 'Price',
                              '₹${d.basePrice} ${d.pricingModel}'),
                          _summaryRow(Icons.group_outlined, 'Max group',
                              d.maxGroupSize),
                          _summaryRow(Icons.pin_drop_outlined, 'Meeting at',
                              d.meetingPoint),
                          _summaryRow(Icons.event_busy_rounded,
                              'Cancellation', d.cancellationPolicy),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            WizardBottomBar(
              onPrevious: () => Navigator.pop(context),
              onNext: _publish,
              nextLabel: 'Publish guide profile',
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}