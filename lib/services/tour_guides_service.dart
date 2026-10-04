import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/tour_guide.dart';
import '../helpers/text_utils.dart';

class TourGuidesService {
  /// Fetch all published guide profiles.
  static Future<List<TourGuide>> fetchPublished() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('tour_guides')
          .orderBy('submittedAt', descending: true)
          .get();

      final List<TourGuide> result = [];
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['isPublished'] == true) {
          result.add(TourGuide.fromDoc(doc.id, data));
        }
      }
      return result;
    } catch (e) {
      debugPrint('TourGuidesService.fetchPublished error: $e');
      // Fallback without orderBy
      try {
        final snap = await FirebaseFirestore.instance
            .collection('tour_guides')
            .get();
        final List<TourGuide> result = [];
        for (final doc in snap.docs) {
          final data = doc.data();
          if (data['isPublished'] == true) {
            result.add(TourGuide.fromDoc(doc.id, data));
          }
        }
        result.sort((a, b) {
          final ad = a.submittedAt ?? DateTime(1970);
          final bd = b.submittedAt ?? DateTime(1970);
          return bd.compareTo(ad);
        });
        return result;
      } catch (e2) {
        debugPrint('TourGuidesService fallback error: $e2');
        return [];
      }
    }
  }

  /// Check if the given user has a guide profile.
  static Future<bool> userHasGuideProfile(String userId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('tour_guides')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (e) {
      debugPrint('userHasGuideProfile error: $e');
      return false;
    }
  }

  /// Fetch a guide's own profile doc (may be draft or published).
  static Future<TourGuide?> fetchUserGuideProfile(String userId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('tour_guides')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return TourGuide.fromDoc(snap.docs.first.id, snap.docs.first.data());
    } catch (e) {
      debugPrint('fetchUserGuideProfile error: $e');
      return null;
    }
  }

  /// Fetch tour packages offered by a guide.
  static Future<List<TourPackage>> fetchToursForGuide(String guideId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('tour_packages')
          .where('guideId', isEqualTo: guideId)
          .get();
      final list = snap.docs
          .map((d) => TourPackage.fromDoc(d.id, d.data()))
          .toList();
      list.sort((a, b) {
        final ad = a.createdAt ?? DateTime(1970);
        final bd = b.createdAt ?? DateTime(1970);
        return bd.compareTo(ad);
      });
      return list;
    } catch (e) {
      debugPrint('fetchToursForGuide error: $e');
      return [];
    }
  }

  /// Search + filter guides.
  static List<TourGuide> applyFilters({
    required List<TourGuide> source,
    required String query,
    required String specialty,
  }) {
    final q = query.trim().toLowerCase();
    final words = q
        .split(RegExp(r'[\s,]+'))
        .where((w) => w.isNotEmpty)
        .toList();

    return source.where((g) {
      // Specialty filter
      if (specialty != 'All' && !g.specialties.contains(specialty)) {
        return false;
      }

      // Text search
      if (words.isEmpty) return true;

      // Match if ANY of the search words match
      return words.any((w) =>
          g.displayName.toLowerCase().contains(w) ||
          g.fullName.toLowerCase().contains(w) ||
          g.tagline.toLowerCase().contains(w) ||
          g.bio.toLowerCase().contains(w) ||
          g.regionsCovered.any((r) => r.toLowerCase().contains(w)) ||
          g.specialties.any((s) => s.toLowerCase().contains(w)));
    }).toList();
  }

  /// Group guides by their primary city.
  static Map<String, List<TourGuide>> groupByRegion(List<TourGuide> all) {
    final Map<String, String> displayNames = {};
    final Map<String, List<TourGuide>> grouped = {};

    for (final guide in all) {
      final rawCity =
          guide.regionsCovered.isNotEmpty ? guide.regionsCovered.first : '';
      final normalizedKey = normalizeText(rawCity)
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '');

      if (normalizedKey.isEmpty) {
        const otherKey = 'other';
        displayNames.putIfAbsent(otherKey, () => 'Other Places');
        grouped.putIfAbsent(otherKey, () => []).add(guide);
        continue;
      }

      displayNames.putIfAbsent(normalizedKey, () => normalizeState(rawCity));
      grouped.putIfAbsent(normalizedKey, () => []).add(guide);
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
}