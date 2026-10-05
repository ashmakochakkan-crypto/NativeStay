import 'package:flutter/material.dart';
import '../../models/home_listing.dart';

class CancellationPolicyScreen extends StatelessWidget {
  final HomeListing listing;
  const CancellationPolicyScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final policy = listing.cancellationPolicy;
    final (title, steps) = switch (policy) {
      'Strict' => (
          'Strict',
          const [
            ('Before check-in',
                'Cancel up to 7 days before check-in for a 50% refund.'),
            ('Within 7 days of check-in', 'Cancellations are non-refundable.'),
            ('After check-in', 'No refund.'),
          ]
        ),
      'Moderate' => (
          'Moderate',
          const [
            ('Before check-in',
                'Cancel up to 5 days before check-in for a full refund.'),
            ('Within 5 days of check-in',
                'Cancel before check-in for a 50% refund.'),
            ('After check-in', 'No refund.'),
          ]
        ),
      _ => (
          'Flexible',
          const [
            ('Before check-in',
                'Cancel up to 24 hours before check-in for a full refund.'),
            ('Within 24 hours of check-in',
                'Cancel before check-in for a 50% refund.'),
            ('After check-in', 'No refund.'),
          ]
        ),
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Cancellation policy',
            style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 6),
            Text('Host selected: $policy policy.',
                style: const TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 20),
            for (int i = 0; i < steps.length; i++)
              _TimelineStep(
                title: steps[i].$1,
                subtitle: steps[i].$2,
                isLast: i == steps.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isLast;
  const _TimelineStep({
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3BDC3),
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: Colors.black12),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          height: 1.45)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}