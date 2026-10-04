import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../models/notification.dart';
import '../../services/notification_service.dart';
import '../../services/review_service.dart';
import '../booking/booking_detail_screen.dart';
import '../booking/host_bookings_screen.dart';
import '../trips/rate_review_sheet.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (user != null)
            TextButton(
              onPressed: () => NotificationService.markAllRead(user.uid),
              child: const Text('Mark all read',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: user == null
          ? const Center(
              child: Text('Log in to see notifications',
                  style: TextStyle(color: Colors.black54)))
          : StreamBuilder<List<AppNotification>>(
              stream: NotificationService.stream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFF3BDC3)));
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined,
                            size: 64, color: Colors.black38),
                        SizedBox(height: 16),
                        Text('No notifications yet',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final n = items[i];
                    return GestureDetector(
                      onTap: () async {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('notifications')
                            .doc(n.id)
                            .update({'read': true});

                        if (!context.mounted) return;
                        if (n.bookingId.isEmpty) return;

                        final doc = await FirebaseFirestore.instance
                            .collection('bookings')
                            .doc(n.bookingId)
                            .get();
                        if (!doc.exists || !context.mounted) return;
                        final booking =
                            Booking.fromDoc(doc.id, doc.data()!);

                        if (n.type == 'booking_completed' &&
                            booking.travelerId == user.uid) {
                          final alreadyReviewed =
                              await ReviewService.hasReviewed(booking.docId);
                          if (!context.mounted) return;
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => RateReviewSheet(
                              booking: booking,
                              alreadyReviewed: alreadyReviewed,
                            ),
                          );
                          return;
                        }

                        if (booking.hostId == user.uid) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HostBookingsScreen()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    BookingDetailScreen(booking: booking)),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              n.read ? Colors.white : const Color(0xFFFFF7FA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: n.read
                                  ? Colors.black12
                                  : const Color(0xFFF3BDC3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF0F3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(_iconFor(n.type),
                                  size: 20, color: const Color(0xFFE91E63)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(n.title,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(n.body,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                          height: 1.4)),
                                  if (!n.read) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      n.type == 'booking_completed'
                                          ? 'Tap to rate & review ⭐'
                                          : 'Tap to open',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFFE91E63),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  IconData _iconFor(String type) {
    if (type.contains('confirmed')) return Icons.check_circle_outline;
    if (type.contains('cancelled')) return Icons.cancel_outlined;
    if (type.contains('requested')) return Icons.receipt_long_outlined;
    if (type.contains('completed')) return Icons.flag_outlined;
    return Icons.notifications_none;
  }
}