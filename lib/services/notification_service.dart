import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/notification.dart';

class NotificationService {
  static CollectionReference<Map<String, dynamic>> _ref(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications');

  static Future<void> create({
    required String userId,
    required String type,
    required String title,
    required String body,
    required String bookingId,
  }) async {
    try {
      await _ref(userId).add({
        'type': type,
        'title': title,
        'body': body,
        'bookingId': bookingId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Notification create error: $e');
    }
  }

  static Stream<List<AppNotification>> stream(String uid) {
    return _ref(uid).snapshots().map((snap) {
      final list = snap.docs
          .map((d) => AppNotification.fromDoc(d.id, d.data()))
          .toList();
      list.sort((a, b) {
        final ad = a.createdAt ?? DateTime(1970);
        final bd = b.createdAt ?? DateTime(1970);
        return bd.compareTo(ad);
      });
      return list;
    });
  }

  static Future<void> markAllRead(String uid) async {
    final snap = await _ref(uid).where('read', isEqualTo: false).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final d in snap.docs) {
      batch.update(d.reference, {'read': true});
    }
    await batch.commit();
  }
}