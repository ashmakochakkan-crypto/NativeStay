import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String docId;
  final String listingId;
  final String listingType;
  final String bookingId;
  final String reviewerId;
  final String reviewerName;
  final String hostId;
  final int rating; // 1–5
  final String text;
  final DateTime? createdAt;

  const Review({
    required this.docId,
    required this.listingId,
    required this.listingType,
    required this.bookingId,
    required this.reviewerId,
    required this.reviewerName,
    required this.hostId,
    required this.rating,
    required this.text,
    required this.createdAt,
  });

  String get initial {
    final n = reviewerName.trim();
    return n.isEmpty ? 'U' : n[0].toUpperCase();
  }

  String get relativeDate {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inDays < 1) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 30) return '${diff.inDays} days ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} mo ago';
    return '${(diff.inDays / 365).floor()} yr ago';
  }

  factory Review.fromDoc(String id, Map<String, dynamic> m) {
    DateTime? ts;
    final raw = m['createdAt'];
    if (raw is Timestamp) ts = raw.toDate();
    return Review(
      docId: id,
      listingId: (m['listingId'] ?? '').toString(),
      listingType: (m['listingType'] ?? 'homestay').toString(),
      bookingId: (m['bookingId'] ?? '').toString(),
      reviewerId: (m['reviewerId'] ?? '').toString(),
      reviewerName: (m['reviewerName'] ?? 'Guest').toString(),
      hostId: (m['hostId'] ?? '').toString(),
      rating: (m['rating'] is int)
          ? m['rating']
          : int.tryParse((m['rating'] ?? '0').toString()) ?? 0,
      text: (m['text'] ?? '').toString(),
      createdAt: ts,
    );
  }
}