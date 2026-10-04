import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Booking {
  final String docId;
  final String listingId;
  final String listingType; // 'homestay' | 'guide' | 'vehicle'
  final String listingName;
  final String listingPhoto;
  final String travelerId;
  final String travelerName;
  final String travelerEmail;
  final String travelerPhone;
  final String hostId;
  final String hostName;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int adults;
  final int children;
  final int rooms;
  final String totalPrice;
  final String paymentMethod; // 'Pay on arrival' | 'Pay online'
  final String status; // 'requested' | 'confirmed' | 'completed' | 'cancelled'
  final String notes;
  final String hostMessage;
  final DateTime? createdAt;

  const Booking({
    required this.docId,
    required this.listingId,
    required this.listingType,
    required this.listingName,
    required this.listingPhoto,
    required this.travelerId,
    required this.travelerName,
    required this.travelerEmail,
    required this.travelerPhone,
    required this.hostId,
    required this.hostName,
    required this.checkIn,
    required this.checkOut,
    required this.adults,
    required this.children,
    required this.rooms,
    required this.totalPrice,
    required this.paymentMethod,
    required this.status,
    required this.notes,
    required this.hostMessage,
    required this.createdAt,
  });

  String get dateRangeLabel {
    if (checkIn == null || checkOut == null) return 'Dates not set';
    final m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
               'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${m[checkIn!.month - 1]} ${checkIn!.day} – ${m[checkOut!.month - 1]} ${checkOut!.day}';
  }

  String get guestsLabel {
    final parts = <String>[];
    if (adults > 0) parts.add('$adults adult${adults > 1 ? 's' : ''}');
    if (children > 0) parts.add('$children child${children > 1 ? 'ren' : ''}');
    if (rooms > 0) parts.add('$rooms room${rooms > 1 ? 's' : ''}');
    return parts.isEmpty ? 'No guests set' : parts.join(' · ');
  }

  int get nights {
    if (checkIn == null || checkOut == null) return 0;
    return checkOut!.difference(checkIn!).inDays.clamp(0, 365);
  }

  String get statusLabel {
    switch (status) {
      case 'requested': return 'Requested';
      case 'confirmed': return 'Confirmed';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'requested': return Colors.orange;
      case 'confirmed': return Colors.green;
      case 'completed': return Colors.blueGrey;
      case 'cancelled': return Colors.redAccent;
      default: return Colors.black54;
    }
  }

  factory Booking.fromDoc(String id, Map<String, dynamic> m) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    return Booking(
      docId: id,
      listingId: (m['listingId'] ?? '').toString(),
      listingType: (m['listingType'] ?? 'homestay').toString(),
      listingName: (m['listingName'] ?? 'Listing').toString(),
      listingPhoto: (m['listingPhoto'] ?? '').toString(),
      travelerId: (m['travelerId'] ?? '').toString(),
      travelerName: (m['travelerName'] ?? 'Guest').toString(),
      travelerEmail: (m['travelerEmail'] ?? '').toString(),
      travelerPhone: (m['travelerPhone'] ?? '').toString(),
      hostId: (m['hostId'] ?? '').toString(),
      hostName: (m['hostName'] ?? 'Host').toString(),
      checkIn: parseDate(m['checkIn']),
      checkOut: parseDate(m['checkOut']),
      adults: (m['adults'] ?? 0) is int
          ? m['adults'] ?? 0
          : int.tryParse((m['adults'] ?? '0').toString()) ?? 0,
      children: (m['children'] ?? 0) is int
          ? m['children'] ?? 0
          : int.tryParse((m['children'] ?? '0').toString()) ?? 0,
      rooms: (m['rooms'] ?? 0) is int
          ? m['rooms'] ?? 0
          : int.tryParse((m['rooms'] ?? '0').toString()) ?? 0,
      totalPrice: (m['totalPrice'] ?? '').toString(),
      paymentMethod: (m['paymentMethod'] ?? 'Pay on arrival').toString(),
      status: (m['status'] ?? 'requested').toString(),
      notes: (m['notes'] ?? '').toString(),
      hostMessage: (m['hostMessage'] ?? '').toString(),
      createdAt: parseDate(m['createdAt']),
    );
  }
}