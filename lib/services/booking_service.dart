import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import 'notification_service.dart';

class BookingService {
  static CollectionReference<Map<String, dynamic>> get _ref =>
      FirebaseFirestore.instance.collection('bookings');

  static bool _rangesOverlap(
    DateTime s1, DateTime e1,
    DateTime s2, DateTime e2,
  ) {
    final a1 = DateTime(s1.year, s1.month, s1.day);
    final b1 = DateTime(e1.year, e1.month, e1.day);
    final a2 = DateTime(s2.year, s2.month, s2.day);
    final b2 = DateTime(e2.year, e2.month, e2.day);
    return b1.isAfter(a2) && a1.isBefore(b2);
  }

  static Future<String> create({
    required String listingId,
    required String listingType,
    required String listingName,
    required String listingPhoto,
    required String hostId,
    required String hostName,
    required DateTime checkIn,
    required DateTime checkOut,
    required int adults,
    required int children,
    required int rooms,
    required String totalPrice,
    required String paymentMethod,
    required String notes,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('You must be logged in');

    String travelerName = user.displayName ?? 'Guest';
    String travelerEmail = user.email ?? '';
    String travelerPhone = '';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users').doc(user.uid).get();
      final data = doc.data() ?? {};
      final fn = (data['firstName'] ?? '').toString().trim();
      final ln = (data['lastName'] ?? '').toString().trim();
      final full = '$fn $ln'.trim();
      if (full.isNotEmpty) travelerName = full;
      travelerPhone = (data['phone'] ?? '').toString();
    } catch (_) {}

    final db = FirebaseFirestore.instance;

    // Fast-fail check. Authoritative check happens in updateStatus().
    final blocksSnap = await db
        .collection('listing_blocks')
        .doc(listingId)
        .get();
    final rawBlocks = (blocksSnap.data()?['blocks'] as List?) ?? [];
    for (final b in rawBlocks) {
      final m = Map<String, dynamic>.from(b as Map);
      final s = (m['checkIn'] as Timestamp?)?.toDate();
      final e = (m['checkOut'] as Timestamp?)?.toDate();
      if (s == null || e == null) continue;
      if (_rangesOverlap(s, e, checkIn, checkOut)) {
        throw Exception('These dates are already booked.');
      }
    }

    final bookingRef = await db.collection('bookings').add({
      'listingId': listingId,
      'listingType': listingType,
      'listingName': listingName,
      'listingPhoto': listingPhoto,
      'travelerId': user.uid,
      'travelerName': travelerName,
      'travelerEmail': travelerEmail,
      'travelerPhone': travelerPhone,
      'hostId': hostId,
      'hostName': hostName,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': Timestamp.fromDate(checkOut),
      'adults': adults,
      'children': children,
      'rooms': rooms,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
      'status': 'requested',
      'notes': notes,
      'hostMessage': '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await NotificationService.create(
      userId: hostId,
      type: 'booking_requested',
      title: 'New booking request',
      body: '$travelerName wants to book "$listingName"',
      bookingId: bookingRef.id,
    );

    return bookingRef.id;
  }

  static Stream<List<Booking>> streamBookingsForTraveler(String uid) {
    return _ref.where('travelerId', isEqualTo: uid).snapshots().map((snap) {
      final list =
          snap.docs.map((d) => Booking.fromDoc(d.id, d.data())).toList();
      list.sort((a, b) {
        final ad = a.createdAt ?? DateTime(1970);
        final bd = b.createdAt ?? DateTime(1970);
        return bd.compareTo(ad);
      });
      return list;
    });
  }

  static Stream<List<Booking>> streamBookingsForHost(String uid,
      {String? listingType}) {
    return _ref.where('hostId', isEqualTo: uid).snapshots().map((snap) {
      var list =
          snap.docs.map((d) => Booking.fromDoc(d.id, d.data())).toList();
      if (listingType != null) {
        list = list.where((b) => b.listingType == listingType).toList();
      }
      list.sort((a, b) {
        final ad = a.createdAt ?? DateTime(1970);
        final bd = b.createdAt ?? DateTime(1970);
        return bd.compareTo(ad);
      });
      return list;
    });
  }

  static Stream<List<Booking>> streamConfirmedForListing(String listingId) {
    return _ref
        .where('listingId', isEqualTo: listingId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Booking.fromDoc(d.id, d.data()))
            .where((b) => b.status == 'confirmed')
            .toList());
  }

  static Future<void> updateStatus(
    String docId,
    String status, {
    String hostMessage = '',
  }) async {
    final db = FirebaseFirestore.instance;
    final bookingRef = db.collection('bookings').doc(docId);

    Map<String, dynamic>? data;

    await db.runTransaction((tx) async {
      final snap = await tx.get(bookingRef);
      if (!snap.exists) return;
      final d = snap.data() ?? {};
      data = d;

      final listingId = (d['listingId'] ?? '').toString();

      if (listingId.isNotEmpty) {
        final blocksRef = db.collection('listing_blocks').doc(listingId);
        final blocksSnap = await tx.get(blocksRef);
        final rawBlocks = (blocksSnap.data()?['blocks'] as List?) ?? [];

        final cleaned = <Map<String, dynamic>>[];
        for (final b in rawBlocks) {
          final m = Map<String, dynamic>.from(b as Map);
          if ((m['bookingId'] ?? '').toString() != docId) cleaned.add(m);
        }

        if (status == 'confirmed') {
          final ci = d['checkIn'] as Timestamp?;
          final co = d['checkOut'] as Timestamp?;

          if (ci != null && co != null) {
            for (final b in cleaned) {
              final s = (b['checkIn'] as Timestamp?)?.toDate();
              final e = (b['checkOut'] as Timestamp?)?.toDate();
              if (s == null || e == null) continue;
              if (_rangesOverlap(s, e, ci.toDate(), co.toDate())) {
                throw Exception(
                    'Another confirmed booking already covers these dates.');
              }
            }
            cleaned.add({
              'bookingId': docId,
              'checkIn': ci,
              'checkOut': co,
            });
          }
        }

        tx.set(blocksRef, {
          'listingId': listingId,
          'listingType': (d['listingType'] ?? '').toString(),
          'blocks': cleaned,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      tx.update(bookingRef, {
        'status': status,
        if (hostMessage.isNotEmpty) 'hostMessage': hostMessage,
      });
    });

    if (data == null) return;

    final travelerId = (data!['travelerId'] ?? '').toString();
    final listingName = (data!['listingName'] ?? 'listing').toString();
    if (travelerId.isEmpty) return;

    String title;
    String body;
    switch (status) {
      case 'confirmed':
        title = 'Booking confirmed 🎉';
        body = '"$listingName" is booked for you!'
            '${hostMessage.isNotEmpty ? '\n\nHost says: $hostMessage' : ''}';
        break;
      case 'cancelled':
        title = 'Booking declined';
        body = 'Your request for "$listingName" was declined.'
            '${hostMessage.isNotEmpty ? '\n\nHost says: $hostMessage' : ''}';
        break;
      case 'completed':
        title = 'Trip completed';
        body = 'Hope you enjoyed "$listingName"!';
        break;
      default:
        return;
    }

    await NotificationService.create(
      userId: travelerId,
      type: 'booking_$status',
      title: title,
      body: body,
      bookingId: docId,
    );
  }

  static Future<void> cancelByTraveler(String docId) async {
    final db = FirebaseFirestore.instance;
    final ref = db.collection('bookings').doc(docId);
    final d = (await ref.get()).data();
    if (d == null) return;
    await ref.update({'status': 'cancelled'});

    try {
      final listingId = (d['listingId'] ?? '').toString();
      if (listingId.isNotEmpty) {
        final blocksRef = db.collection('listing_blocks').doc(listingId);
        await db.runTransaction((tx) async {
          final bs = await tx.get(blocksRef);
          if (!bs.exists) return;
          final raw = (bs.data()?['blocks'] as List?) ?? [];
          final cleaned = raw
              .map((b) => Map<String, dynamic>.from(b as Map))
              .where((b) => (b['bookingId'] ?? '').toString() != docId)
              .toList();
          tx.update(blocksRef, {
            'blocks': cleaned,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        });
      }
    } catch (e) {
      debugPrint('cancelByTraveler: block cleanup failed: $e');
    }

    final hostId = (d['hostId'] ?? '').toString();
    if (hostId.isEmpty) return;
    await NotificationService.create(
      userId: hostId,
      type: 'booking_cancelled_by_traveler',
      title: 'Booking cancelled',
      body:
          '${d['travelerName'] ?? 'A traveler'} cancelled their request for "${d['listingName'] ?? 'your listing'}"',
      bookingId: docId,
    );
  }

  static Future<void> deleteBooking(String docId) async {
    try {
      final ref = _ref.doc(docId);
      final snap = await ref.get();
      final d = snap.data();

      if (d != null) {
        final listingId = (d['listingId'] ?? '').toString();
        if (listingId.isNotEmpty) {
          final blocksRef = FirebaseFirestore.instance
              .collection('listing_blocks')
              .doc(listingId);
          await FirebaseFirestore.instance.runTransaction((tx) async {
            final bs = await tx.get(blocksRef);
            if (!bs.exists) return;
            final raw = (bs.data()?['blocks'] as List?) ?? [];
            final cleaned = raw
                .map((b) => Map<String, dynamic>.from(b as Map))
                .where((b) => (b['bookingId'] ?? '').toString() != docId)
                .toList();
            tx.update(blocksRef, {
              'blocks': cleaned,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          });
        }
      }

      await ref.delete();
    } catch (e) {
      debugPrint('deleteBooking error: $e');
    }
  }
}