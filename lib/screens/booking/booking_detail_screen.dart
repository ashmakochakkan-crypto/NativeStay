import 'package:flutter/material.dart';
import '../../models/booking.dart';

class BookingDetailScreen extends StatelessWidget {
  final Booking booking;
  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final b = booking;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Booking details',
            style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: b.status == 'confirmed'
                    ? Colors.green.withValues(alpha: 0.10)
                    : b.statusColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: b.statusColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(
                    b.status == 'confirmed'
                        ? Icons.check_circle
                        : Icons.receipt_long,
                    color: b.statusColor,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.status == 'confirmed' ? 'Booked' : b.statusLabel,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: b.statusColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          b.status == 'confirmed'
                              ? 'Your stay is confirmed'
                              : b.status == 'requested'
                                  ? 'Waiting for host to confirm'
                                  : b.status == 'completed'
                                      ? 'Trip finished'
                                      : 'Cancelled',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: b.listingPhoto.isNotEmpty
                          ? Image.network(b.listingPhoto,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _ph())
                          : _ph(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.listingName,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Hosted by ${b.hostName}',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black54)),
                        const SizedBox(height: 6),
                        Text(
                            'Booking ID: ${b.docId.substring(0, 8).toUpperCase()}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black38)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Dates',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  _kv(
                      'Check-in',
                      b.checkIn == null
                          ? '—'
                          : '${b.checkIn!.day}/${b.checkIn!.month}/${b.checkIn!.year}'),
                  const Divider(height: 20),
                  _kv(
                      'Check-out',
                      b.checkOut == null
                          ? '—'
                          : '${b.checkOut!.day}/${b.checkOut!.month}/${b.checkOut!.year}'),
                  const Divider(height: 20),
                  _kv('Nights', '${b.nights}'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Guests',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  _kv('Adults', '${b.adults}'),
                  const Divider(height: 20),
                  _kv('Children', '${b.children}'),
                  const Divider(height: 20),
                  _kv('Rooms', '${b.rooms}'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Payment',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  _kv('Total', '₹${b.totalPrice}'),
                  const Divider(height: 20),
                  _kv('Method', 'Cash on stay'),
                ],
              ),
            ),

            if (b.notes.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Your message to host',
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('"${b.notes}"',
                    style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontStyle: FontStyle.italic)),
              ),
            ],

            if (b.hostMessage.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Message from host',
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFCE4EC)),
                ),
                child: Text(b.hostMessage,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black87)),
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) => Row(
        children: [
          Text(k,
              style:
                  const TextStyle(fontSize: 13, color: Colors.black54)),
          const Spacer(),
          Text(v,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
        ],
      );

  Widget _ph() => Container(
        color: const Color(0xFFFFF0F3),
        child: const Icon(Icons.home_work_rounded,
            color: Color(0xFFF3BDC3)),
      );
}