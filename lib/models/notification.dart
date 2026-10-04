import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final String bookingId;
  final bool read;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.bookingId,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromDoc(String id, Map<String, dynamic> m) {
    DateTime? ts;
    final raw = m['createdAt'];
    if (raw is Timestamp) ts = raw.toDate();
    return AppNotification(
      id: id,
      type: (m['type'] ?? '').toString(),
      title: (m['title'] ?? '').toString(),
      body: (m['body'] ?? '').toString(),
      bookingId: (m['bookingId'] ?? '').toString(),
      read: m['read'] == true,
      createdAt: ts,
    );
  }
}