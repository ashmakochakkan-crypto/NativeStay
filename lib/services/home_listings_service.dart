import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/home_listing.dart';
import '../helpers/text_utils.dart';

class HomeListingsService {
  /// Returns every published listing.
  static Future<List<HomeListing>> fetchPublished() async {
    final snap = await FirebaseFirestore.instance
        .collection('property_listings')
        .orderBy('submittedAt', descending: true)
        .get();
    final result = <HomeListing>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      if (data['isPublished'] == true) {
        result.add(HomeListing.fromDoc(doc.id, data));
      }
    }
    return result;
  }

  /// True if the given user has at least 1 PUBLISHED listing.
  static Future<bool> userHasListings(String userId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('property_listings')
          .where('userId', isEqualTo: userId)
          .where('isPublished', isEqualTo: true)
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (e) {
      debugPrint('userHasListings error: $e');
      return false;
    }
  }

  static String _stateKey(String raw) {
    final n = normalizeState(raw);
    if (n.isEmpty) return 'other';
    return n.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  static Map<String, List<HomeListing>> groupByState(List<HomeListing> all) {
    final Map<String, String> displayNames = {};
    final Map<String, List<HomeListing>> grouped = {};
    for (final l in all) {
      final key = _stateKey(l.state);
      final display = normalizeState(l.state);
      displayNames.putIfAbsent(key, () => display.isEmpty ? 'Other' : display);
      grouped.putIfAbsent(key, () => []).add(l);
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) {
        final c = b.value.length.compareTo(a.value.length);
        if (c != 0) return c;
        return a.key.compareTo(b.key);
      });
    return {
      for (final e in entries) (displayNames[e.key] ?? e.key): e.value,
    };
  }

  static List<HomeListing> applyFilters({
    required List<HomeListing> source,
    required String query,
    required String filter,
    DateTime? checkIn,
    DateTime? checkOut,
    int totalGuests = 0,
    int roomsNeeded = 0,
  }) {
    final q = normalizeText(query).toLowerCase();
    final words = q
        .split(RegExp(r'[\s,]+'))
        .where((w) => w.isNotEmpty)
        .toList();

    return source.where((l) {
      if (filter != 'All') {
        final filterState = normalizeState(filter).toLowerCase();
        final listingState = normalizeState(l.state).toLowerCase();
        if (listingState != filterState) return false;
      }

      if (words.isNotEmpty) {
        final matchesSearch = words.any((w) =>
            l.stayName.toLowerCase().contains(w) ||
            l.city.toLowerCase().contains(w) ||
            l.state.toLowerCase().contains(w) ||
            l.area.toLowerCase().contains(w) ||
            l.fullAddress.toLowerCase().contains(w));
        if (!matchesSearch) return false;
      }

      if (totalGuests > 0) {
        final maxGuests = int.tryParse(l.guests.trim()) ?? 0;
        if (maxGuests > 0 && maxGuests < totalGuests) return false;
      }

      if (roomsNeeded > 0) {
        final maxRooms = int.tryParse(l.bedrooms.trim()) ?? 0;
        if (maxRooms > 0 && maxRooms < roomsNeeded) return false;
      }

      if (checkIn != null && checkOut != null) {
        if (l.availabilityPeriods.isNotEmpty) {
          final fits = l.availabilityPeriods.any(
            (p) => p.containsRange(checkIn, checkOut),
          );
          if (!fits) return false;
        }
      }

      return true;
    }).toList();
  }
}