import 'package:flutter/material.dart';
import '../../models/home_listing.dart';

class SafetyDetailScreen extends StatelessWidget {
  final HomeListing listing;
  const SafetyDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final l = listing;

    final rows = <Map<String, dynamic>>[];

    // From safetyFeatures (built from firstAid, fireExtinguisher, cctvCommon)
    for (final f in l.safetyFeatures) {
      rows.add({'label': f, 'value': 'Yes', 'icon': Icons.check_circle_outline});
    }
    if (l.smokeDetector == 'Yes') {
      rows.add({
        'label': 'Smoke detector',
        'value': 'Yes',
        'icon': Icons.doorbell_rounded
      });
    }
    if (l.emergencyExit == 'Yes') {
      rows.add({
        'label': 'Emergency exit',
        'value': 'Available',
        'icon': Icons.exit_to_app_rounded
      });
    }
    if (l.doorLock == 'Yes') {
      rows.add({
        'label': 'Door lock on private space',
        'value': 'Yes',
        'icon': Icons.lock_outline_rounded
      });
    }
    if (l.nearestHospital.isNotEmpty) {
      rows.add({
        'label': 'Nearest hospital',
        'value': l.nearestHospital,
        'icon': Icons.local_hospital_outlined
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Safety & property',
            style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text('Safety features',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 6),
            const Text("What's available at this property.",
                style: TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 24),

            if (rows.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No safety features were listed by the host.',
                    style: TextStyle(fontSize: 13, color: Colors.black45)),
              )
            else
              ...rows.map((r) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Icon(r['icon'] as IconData,
                            size: 22, color: const Color(0xFFF3BDC3)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(r['label'] as String,
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.black)),
                        ),
                        Text(r['value'] as String,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87)),
                      ],
                    ),
                  )),

            if (l.safetyInstructions.isNotEmpty) ...[
              const SizedBox(height: 30),
              const Text('Safety instructions',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFCE4EC)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFFE91E63)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(l.safetyInstructions,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.5)),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}