import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/vehicle_listing.dart';
import '../helpers/text_utils.dart';

class VehicleListingsService {
  static Future<List<VehicleListing>> fetchPublished() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('vehicle_listings')
          .orderBy('submittedAt', descending: true)
          .get();

      final List<VehicleListing> result = [];
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['isPublished'] == true) {
          result.add(VehicleListing.fromDoc(doc.id, data));
        }
      }
      return result;
    } catch (e) {
      debugPrint('VehicleListingsService.fetchPublished error: $e');
      try {
        final snap = await FirebaseFirestore.instance
            .collection('vehicle_listings')
            .get();
        final List<VehicleListing> result = [];
        for (final doc in snap.docs) {
          final data = doc.data();
          if (data['isPublished'] == true) {
            result.add(VehicleListing.fromDoc(doc.id, data));
          }
        }
        result.sort((a, b) {
          final ad = a.submittedAt ?? DateTime(1970);
          final bd = b.submittedAt ?? DateTime(1970);
          return bd.compareTo(ad);
        });
        return result;
      } catch (e2) {
        debugPrint('VehicleListingsService fallback error: $e2');
        return [];
      }
    }
  }

  static Future<bool> userHasVehicles(String userId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('vehicle_listings')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (e) {
      debugPrint('userHasVehicles error: $e');
      return false;
    }
  }

  /// Fetch all vehicles of a user.
  static Future<List<VehicleListing>> fetchAllForUser(String userId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('vehicle_listings')
          .where('userId', isEqualTo: userId)
          .get();
      return snap.docs
          .map((d) => VehicleListing.fromDoc(d.id, d.data()))
          .toList();
    } catch (e) {
      debugPrint('fetchAllForUser error: $e');
      return [];
    }
  }

  /// Search + filter.
  static List<VehicleListing> applyFilters({
    required List<VehicleListing> source,
    required String query,
    required String vehicleType,
  }) {
    final q = normalizeText(query).toLowerCase();
    final words = q
        .split(RegExp(r'[\s,]+'))
        .where((w) => w.isNotEmpty)
        .toList();

    return source.where((v) {
      if (vehicleType != 'All' && v.vehicleType != vehicleType) {
        return false;
      }

      if (words.isEmpty) return true;

      return words.any((w) =>
          v.nickname.toLowerCase().contains(w) ||
          v.make.toLowerCase().contains(w) ||
          v.model.toLowerCase().contains(w) ||
          v.vehicleType.toLowerCase().contains(w) ||
          v.city.toLowerCase().contains(w) ||
          v.state.toLowerCase().contains(w) ||
          v.area.toLowerCase().contains(w) ||
          v.fuelType.toLowerCase().contains(w) ||
          v.transmission.toLowerCase().contains(w));
    }).toList();
  }

  static Map<String, List<VehicleListing>> groupByState(
      List<VehicleListing> all) {
    final Map<String, List<VehicleListing>> grouped = {};
    for (final v in all) {
      final key = canonicalStateKey(v.state);
      grouped.putIfAbsent(key, () => []).add(v);
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) {
        final c = b.value.length.compareTo(a.value.length);
        if (c != 0) return c;
        return a.key.compareTo(b.key);
      });
    return {for (final e in entries) e.key: e.value};
  }
}