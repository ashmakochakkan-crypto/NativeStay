import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/home_listing.dart';
import '../models/vehicle_listing.dart';
import '../models/tour_guide.dart';

// ==========================================
// HOMESTAY WISHLIST
// ==========================================
class WishlistService {
  static CollectionReference<Map<String, dynamic>> _ref(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('wishlist');

  static Future<void> add(String uid, HomeListing listing) async {
    await _ref(uid).doc(listing.docId).set({
      'listingId': listing.docId,
      'stayName': listing.stayName,
      'city': listing.city,
      'state': listing.state,
      'pricePerNight': listing.pricePerNight,
      'coverPhoto': listing.coverPhoto,
      'propertyType': listing.propertyType,
      'stayType': listing.stayType,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> remove(String uid, String listingId) async {
    await _ref(uid).doc(listingId).delete();
  }

  static Future<bool> isSaved(String uid, String listingId) async {
    final doc = await _ref(uid).doc(listingId).get();
    return doc.exists;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> stream(String uid) {
    return _ref(uid).orderBy('addedAt', descending: true).snapshots();
  }
}

// ==========================================
// VEHICLE WISHLIST
// ==========================================
class VehicleWishlistService {
  static CollectionReference<Map<String, dynamic>> _ref(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('vehicle_wishlist');

  static Future<void> add(String uid, VehicleListing v) async {
    await _ref(uid).doc(v.docId).set({
      'vehicleId': v.docId,
      'nickname': v.nickname,
      'displayTitle': v.displayTitle,
      'city': v.city,
      'state': v.state,
      'pricePerDay': v.basePrice,
      'pricingModel': v.pricingModel,
      'photo': v.photos.isNotEmpty ? v.photos.first : '',
      'vehicleType': v.vehicleType,
      'rentalMode': v.rentalMode,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> remove(String uid, String vehicleId) async {
    await _ref(uid).doc(vehicleId).delete();
  }

  static Future<bool> isSaved(String uid, String vehicleId) async {
    final doc = await _ref(uid).doc(vehicleId).get();
    return doc.exists;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> stream(String uid) {
    return _ref(uid).orderBy('addedAt', descending: true).snapshots();
  }
}

// ==========================================
// GUIDE WISHLIST
// ==========================================
class GuideWishlistService {
  static CollectionReference<Map<String, dynamic>> _ref(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('guide_wishlist');

  static Future<void> add(String uid, TourGuide g) async {
    await _ref(uid).doc(g.docId).set({
      'guideId': g.docId,
      'displayName': g.displayName,
      'tagline': g.tagline,
      'region': g.primaryRegion,
      'pricePerDay': g.basePrice,
      'priceSuffix': g.priceSuffix,
      'photo': g.photos.isNotEmpty ? g.photos.first : '',
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> remove(String uid, String guideId) async {
    await _ref(uid).doc(guideId).delete();
  }

  static Future<bool> isSaved(String uid, String guideId) async {
    final doc = await _ref(uid).doc(guideId).get();
    return doc.exists;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> stream(String uid) {
    return _ref(uid).orderBy('addedAt', descending: true).snapshots();
  }
}