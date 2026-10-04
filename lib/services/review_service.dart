import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/review.dart';

class ReviewService {
  static CollectionReference<Map<String, dynamic>> get _ref =>
      FirebaseFirestore.instance.collection('reviews');

  /// Stream all reviews for a listing, newest first.
  static Stream<List<Review>> streamForListing(String listingId) {
    return _ref
        .where('listingId', isEqualTo: listingId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => Review.fromDoc(d.id, d.data()))
          .toList();
      list.sort((a, b) {
        final ad = a.createdAt ?? DateTime(1970);
        final bd = b.createdAt ?? DateTime(1970);
        return bd.compareTo(ad);
      });
      return list;
    });
  }

  static Stream<List<Review>> streamForHost(String hostId) {
    return _ref.where('hostId', isEqualTo: hostId).snapshots().map((snap) {
      final list =
          snap.docs.map((d) => Review.fromDoc(d.id, d.data())).toList();
      list.sort((a, b) {
        final ad = a.createdAt ?? DateTime(1970);
        final bd = b.createdAt ?? DateTime(1970);
        return bd.compareTo(ad);
      });
      return list;
    });
  }

  static Future<bool> hasReviewed(String bookingId) async {
    try {
      final snap = await _ref
          .where('bookingId', isEqualTo: bookingId)
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (e) {
      debugPrint('hasReviewed error: $e');
      return false;
    }
  }

  static Future<void> create({
    required String listingId,
    required String listingType,
    required String bookingId,
    required String hostId,
    required int rating,
    required String text,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Must be logged in');

    String reviewerName = user.displayName ?? 'Guest';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final d = doc.data() ?? {};
      final full =
          '${(d['firstName'] ?? '').toString().trim()} ${(d['lastName'] ?? '').toString().trim()}'
              .trim();
      if (full.isNotEmpty) reviewerName = full;
    } catch (_) {}

    await _ref.add({
      'listingId': listingId,
      'listingType': listingType,
      'bookingId': bookingId,
      'reviewerId': user.uid,
      'reviewerName': reviewerName,
      'hostId': hostId,
      'rating': rating,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Average + count + distribution (5/4/3/2/1).
  static Map<String, dynamic> stats(List<Review> reviews) {
    if (reviews.isEmpty) {
      return {
        'average': 0.0,
        'count': 0,
        'distribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      };
    }
    int sum = 0;
    final dist = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final r in reviews) {
      sum += r.rating;
      if (r.rating >= 1 && r.rating <= 5) {
        dist[r.rating] = (dist[r.rating] ?? 0) + 1;
      }
    }
    return {
      'average': sum / reviews.length,
      'count': reviews.length,
      'distribution': dist,
    };
  }
}