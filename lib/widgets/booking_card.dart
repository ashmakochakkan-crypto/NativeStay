import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../screens/booking/booking_detail_screen.dart';

class BookingCard extends StatefulWidget {
  final Booking booking;
  final bool isHostView;
  const BookingCard({super.key, required this.booking, required this.isHostView});

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  final _hostMsgCtrl = TextEditingController();
  bool _busy = false;
  Map<String, dynamic>? _travelerProfile;

  @override
  void initState() {
    super.initState();
    if (widget.isHostView) _loadTravelerProfile();
  }

  Future<void> _loadTravelerProfile() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.booking.travelerId)
          .get();
      if (mounted) setState(() => _travelerProfile = doc.data());
    } catch (_) {}
  }

  @override
  void dispose() {
    _hostMsgCtrl.dispose();
    super.dispose();
  }

  Future<void> _update(String status) async {
    setState(() => _busy = true);
    try {
      await BookingService.updateStatus(
        widget.booking.docId,
        status,
        hostMessage: _hostMsgCtrl.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update booking: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmComplete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Expanded(child: Text('Mark as completed?')),
          ],
        ),
        content: const Text(
          'Has the traveller completed the stay and payment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF3BDC3),
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('OK',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _update('completed');
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete this booking?'),
        content: const Text(
          'Warning: This booking will be permanently deleted. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await BookingService.deleteBooking(widget.booking.docId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BookingDetailScreen(booking: b)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 64,
                    height: 64,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                          widget.isHostView
                              ? 'From ${b.travelerName}'
                              : 'Hosted by ${b.hostName}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: b.statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          b.status == 'confirmed' ? 'Booked' : b.statusLabel,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: b.statusColor),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                  onPressed: _busy ? null : _confirmDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 10),
            _row(Icons.calendar_today_rounded, b.dateRangeLabel),
            const SizedBox(height: 6),
            _row(Icons.group_outlined, b.guestsLabel),
            const SizedBox(height: 6),
            _row(Icons.currency_rupee_rounded,
                '₹${b.totalPrice} · Pay on stay'),

            if (b.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10)),
                child: Text('"${b.notes}"',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontStyle: FontStyle.italic)),
              ),
            ],

            if (widget.isHostView) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Colors.black12),
              const SizedBox(height: 10),
              const Text('Traveler profile',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _travelerProfileRow(),
              const SizedBox(height: 12),
              if (b.status == 'requested') ...[
                const Text('Message before confirming (optional)',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54)),
                const SizedBox(height: 6),
                TextField(
                  controller: _hostMsgCtrl,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'e.g. "See you on the 3rd!"',
                    hintStyle: const TextStyle(
                        color: Colors.black38, fontSize: 13),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFFF3BDC3), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _busy
                            ? null
                            : () => _update('cancelled'),
                        child: const Text('Decline',
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3BDC3),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _busy
                            ? null
                            : () => _update('confirmed'),
                        child: _busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.black, strokeWidth: 2))
                            : const Text('Confirm booking',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ] else if (b.status == 'confirmed')
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _busy ? null : _confirmComplete,
                    child: const Text('Mark as completed',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
            ] else ...[
              if (b.hostMessage.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7FA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFCE4EC)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Host message',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54)),
                      const SizedBox(height: 4),
                      Text(b.hostMessage,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black87)),
                    ],
                  ),
                ),
              ],
              if (b.status == 'requested') ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () =>
                      BookingService.cancelByTraveler(b.docId),
                  child: const Text('Cancel request',
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _travelerProfileRow() {
    final p = _travelerProfile ?? {};
    final bio = (p['about'] ?? '').toString();
    final interests = List<String>.from(p['interests'] ?? []);
    final phone = (p['phone'] ?? '').toString();
    final work = (p['work'] ?? '').toString();
    final live = (p['live'] ?? '').toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  color: Color(0xFFFFF0F3), shape: BoxShape.circle),
              child: Center(
                child: Text(
                  widget.booking.travelerName.isNotEmpty
                      ? widget.booking.travelerName[0].toUpperCase()
                      : 'G',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE91E63)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.booking.travelerName,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  if (widget.booking.travelerPhone.isNotEmpty ||
                      phone.isNotEmpty)
                    Text(
                        '+91 ${widget.booking.travelerPhone.isNotEmpty ? widget.booking.travelerPhone : phone}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
        if (work.isNotEmpty) ...[
          const SizedBox(height: 6),
          _miniRow(Icons.work_outline, 'Works as $work'),
        ],
        if (live.isNotEmpty) ...[
          const SizedBox(height: 4),
          _miniRow(Icons.location_on_outlined, 'Lives in $live'),
        ],
        if (bio.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(bio,
              style: const TextStyle(
                  fontSize: 12, color: Colors.black87, height: 1.4)),
        ],
        if (interests.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: interests
                .take(6)
                .map((t) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(t,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w500)),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _miniRow(IconData i, String t) => Row(
        children: [
          Icon(i, size: 14, color: Colors.black54),
          const SizedBox(width: 6),
          Expanded(
              child: Text(t,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black87))),
        ],
      );

  Widget _row(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 15, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black87))),
        ],
      );

  Widget _ph() => Container(
        color: const Color(0xFFFFF0F3),
        child: const Icon(Icons.home_work_rounded,
            color: Color(0xFFF3BDC3)),
      );
}