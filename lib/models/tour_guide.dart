import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ==========================================
// TOUR GUIDE MODEL
// ==========================================
class TourGuide {
  final String docId;
  final String userId;
  final String fullName;
  final String displayName;
  final String phone;
  final String email;
  final String photoUrl;
  final List<String> photos;
  final String tagline;
  final String bio;
  final String yearsExperience;
  final List<String> languages;
  final List<String> specialties;
  final List<String> regionsCovered;
  final String licenseNumber;
  final List<String> certifications;
  final String pricingModel;
  final String basePrice;
  final String meetingPoint;
  final String inclusions;
  final String exclusions;
  final String houseRules;
  final String maxGroupSize;
  final String cancellationPolicy;
  final bool isPublished;
  final DateTime? submittedAt;
  final double rating;
  final int reviewCount;

  const TourGuide({
    required this.docId,
    required this.userId,
    required this.fullName,
    required this.displayName,
    required this.phone,
    required this.email,
    required this.photoUrl,
    required this.photos,
    required this.tagline,
    required this.bio,
    required this.yearsExperience,
    required this.languages,
    required this.specialties,
    required this.regionsCovered,
    required this.licenseNumber,
    required this.certifications,
    required this.pricingModel,
    required this.basePrice,
    required this.meetingPoint,
    required this.inclusions,
    required this.exclusions,
    required this.houseRules,
    required this.maxGroupSize,
    required this.cancellationPolicy,
    required this.isPublished,
    required this.submittedAt,
    required this.rating,
    required this.reviewCount,
  });

  String get coverPhoto => photoUrl;

  String get initial {
    final n = (displayName.trim().isNotEmpty ? displayName : fullName).trim();
    return n.isEmpty ? 'G' : n[0].toUpperCase();
  }

  String get primaryRegion {
    if (regionsCovered.isEmpty) return 'India';
    return regionsCovered.first;
  }

  String get priceLabel {
    if (basePrice.trim().isEmpty) return '₹—';
    return '₹$basePrice';
  }

  String get priceSuffix {
    switch (pricingModel) {
      case 'Per Hour':
        return ' / hour';
      case 'Per Day':
        return ' / day';
      case 'Per Person':
        return ' / person';
      case 'Per Group':
        return ' / group';
      default:
        return '';
    }
  }

  String get ratingLabel {
    if (reviewCount == 0) return 'New';
    return rating.toStringAsFixed(1);
  }

  factory TourGuide.fromDoc(String id, Map<String, dynamic> map) {
    DateTime? submitted;
    final raw = map['submittedAt'];
    if (raw is Timestamp) {
      submitted = raw.toDate();
    } else if (raw is DateTime) {
      submitted = raw;
    }

    return TourGuide(
      docId: id,
      userId: (map['userId'] ?? '').toString(),
      fullName: (map['fullName'] ?? '').toString(),
      displayName: (map['displayName'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      photoUrl: (map['photoUrl'] ?? '').toString(),
      photos: List<String>.from(map['photos'] ?? []),
      tagline: (map['tagline'] ?? '').toString(),
      bio: (map['bio'] ?? '').toString(),
      yearsExperience: (map['yearsExperience'] ?? '').toString(),
      languages: List<String>.from(map['languages'] ?? []),
      specialties: List<String>.from(map['specialties'] ?? []),
      regionsCovered: List<String>.from(map['regionsCovered'] ?? []),
      licenseNumber: (map['licenseNumber'] ?? '').toString(),
      certifications: List<String>.from(map['certifications'] ?? []),
      pricingModel: (map['pricingModel'] ?? 'Per Day').toString(),
      basePrice: (map['basePrice'] ?? '').toString(),
      meetingPoint: (map['meetingPoint'] ?? '').toString(),
      inclusions: (map['inclusions'] ?? '').toString(),
      exclusions: (map['exclusions'] ?? '').toString(),
      houseRules: (map['houseRules'] ?? '').toString(),
      maxGroupSize: (map['maxGroupSize'] ?? '10').toString(),
      cancellationPolicy:
          (map['cancellationPolicy'] ?? 'Flexible').toString(),
      isPublished: map['isPublished'] == true,
      submittedAt: submitted,
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: (map['reviewCount'] ?? 0).toInt(),
    );
  }
}

// ==========================================
// TOUR PACKAGE MODEL
// ==========================================
class TourPackage {
  final String docId;
  final String guideId;
  final String title;
  final String description;
  final String duration;
  final String groupSize;
  final String price;
  final String pricingModel;
  final List<String> languages;
  final List<String> inclusions;
  final String itinerary;
  final String meetingPoint;
  final String cancellationPolicy;
  final DateTime? createdAt;

  const TourPackage({
    required this.docId,
    required this.guideId,
    required this.title,
    required this.description,
    required this.duration,
    required this.groupSize,
    required this.price,
    required this.pricingModel,
    required this.languages,
    required this.inclusions,
    required this.itinerary,
    required this.meetingPoint,
    required this.cancellationPolicy,
    required this.createdAt,
  });

  String get priceLabel {
    if (price.trim().isEmpty) return '₹—';
    return '₹$price';
  }

  factory TourPackage.fromDoc(String id, Map<String, dynamic> map) {
    DateTime? created;
    final raw = map['createdAt'];
    if (raw is Timestamp) {
      created = raw.toDate();
    } else if (raw is DateTime) {
      created = raw;
    }
    return TourPackage(
      docId: id,
      guideId: (map['guideId'] ?? '').toString(),
      title: (map['title'] ?? 'Untitled Tour').toString(),
      description: (map['description'] ?? '').toString(),
      duration: (map['duration'] ?? '').toString(),
      groupSize: (map['groupSize'] ?? '').toString(),
      price: (map['price'] ?? '').toString(),
      pricingModel: (map['pricingModel'] ?? 'Per Person').toString(),
      languages: List<String>.from(map['languages'] ?? []),
      inclusions: List<String>.from(map['inclusions'] ?? []),
      itinerary: (map['itinerary'] ?? '').toString(),
      meetingPoint: (map['meetingPoint'] ?? '').toString(),
      cancellationPolicy:
          (map['cancellationPolicy'] ?? 'Flexible').toString(),
      createdAt: created,
    );
  }
}

// ==========================================
// GUIDE CONSTANTS
// ==========================================
class GuideSpecialty {
  final String label;
  final IconData icon;
  const GuideSpecialty(this.label, this.icon);
}

const List<GuideSpecialty> kGuideSpecialties = [
  GuideSpecialty('City Tours', Icons.location_city_rounded),
  GuideSpecialty('Cultural', Icons.temple_hindu_rounded),
  GuideSpecialty('Food Walks', Icons.restaurant_rounded),
  GuideSpecialty('Trekking', Icons.hiking_rounded),
  GuideSpecialty('Adventure', Icons.paragliding_rounded),
  GuideSpecialty('Wildlife', Icons.pets_rounded),
  GuideSpecialty('Photography', Icons.camera_alt_rounded),
  GuideSpecialty('Religious', Icons.church_rounded),
  GuideSpecialty('Historical', Icons.museum_rounded),
  GuideSpecialty('Shopping', Icons.shopping_bag_rounded),
  GuideSpecialty('Nightlife', Icons.nightlife_rounded),
  GuideSpecialty('Family-Friendly', Icons.family_restroom_rounded),
  GuideSpecialty('Nature', Icons.forest_rounded),
  GuideSpecialty('Beach', Icons.beach_access_rounded),
  GuideSpecialty('Cycling', Icons.pedal_bike_rounded),
  GuideSpecialty('Yoga & Wellness', Icons.self_improvement_rounded),
];

class GuideLanguage {
  final String label;
  final IconData icon;
  const GuideLanguage(this.label, this.icon);
}

const List<GuideLanguage> kGuideLanguages = [
  GuideLanguage('English', Icons.language_rounded),
  GuideLanguage('Hindi', Icons.language_rounded),
  GuideLanguage('Tamil', Icons.language_rounded),
  GuideLanguage('Telugu', Icons.language_rounded),
  GuideLanguage('Malayalam', Icons.language_rounded),
  GuideLanguage('Kannada', Icons.language_rounded),
  GuideLanguage('Marathi', Icons.language_rounded),
  GuideLanguage('Bengali', Icons.language_rounded),
  GuideLanguage('Gujarati', Icons.language_rounded),
  GuideLanguage('Punjabi', Icons.language_rounded),
  GuideLanguage('Urdu', Icons.language_rounded),
  GuideLanguage('French', Icons.language_rounded),
  GuideLanguage('German', Icons.language_rounded),
  GuideLanguage('Spanish', Icons.language_rounded),
  GuideLanguage('Japanese', Icons.language_rounded),
  GuideLanguage('Mandarin', Icons.language_rounded),
];

class GuideCertification {
  final String label;
  final IconData icon;
  const GuideCertification(this.label, this.icon);
}

const List<GuideCertification> kGuideCertifications = [
  GuideCertification('Government Guide License', Icons.verified_user_rounded),
  GuideCertification('First Aid Certified', Icons.medical_services_rounded),
  GuideCertification('CPR Certified', Icons.favorite_rounded),
  GuideCertification('Trekking Certified', Icons.hiking_rounded),
  GuideCertification('Wildlife Certified', Icons.pets_rounded),
  GuideCertification('Photography Certified', Icons.camera_alt_rounded),
  GuideCertification('Yoga Instructor', Icons.self_improvement_rounded),
  GuideCertification('Lifeguard', Icons.pool_rounded),
  GuideCertification('Mountain Rescue', Icons.terrain_rounded),
];

const List<String> kGuidePricingModels = [
  'Per Hour',
  'Per Day',
  'Per Person',
  'Per Group',
];

const List<String> kGuideCancellationPolicies = [
  'Flexible',
  'Moderate',
  'Strict',
];

// ==========================================
// GUIDE PROFILE DATA CARRIER (wizard)
// ==========================================
class GuideProfileData {
  String? docId;
  String fullName = '';
  String displayName = '';
  String phone = '';
  String email = '';
  String photoUrl = '';
  List<String> photos = [];
  List<XFile> localPhotos = [];
  String tagline = '';
  String bio = '';
  String yearsExperience = '';
  List<String> languages = [];
  List<String> specialties = [];
  List<String> regionsCovered = [];
  String licenseNumber = '';
  List<String> certifications = [];
  String pricingModel = 'Per Day';
  String basePrice = '';
  String maxGroupSize = '10';
  String meetingPoint = '';
  String inclusions = '';
  String exclusions = '';
  String houseRules = '';
  String cancellationPolicy = 'Flexible';
  bool isPublished = false;

  GuideProfileData();

  factory GuideProfileData.fromGuide(TourGuide g) {
    return GuideProfileData()
      ..docId = g.docId
      ..fullName = g.fullName
      ..displayName = g.displayName
      ..phone = g.phone
      ..email = g.email
      ..photoUrl = g.photoUrl
      ..photos = List<String>.from(g.photos)
      ..tagline = g.tagline
      ..bio = g.bio
      ..yearsExperience = g.yearsExperience
      ..languages = List<String>.from(g.languages)
      ..specialties = List<String>.from(g.specialties)
      ..regionsCovered = List<String>.from(g.regionsCovered)
      ..licenseNumber = g.licenseNumber
      ..certifications = List<String>.from(g.certifications)
      ..pricingModel = g.pricingModel
      ..basePrice = g.basePrice
      ..maxGroupSize = g.maxGroupSize
      ..meetingPoint = g.meetingPoint
      ..inclusions = g.inclusions
      ..exclusions = g.exclusions
      ..houseRules = g.houseRules
      ..cancellationPolicy = g.cancellationPolicy
      ..isPublished = g.isPublished;
  }
}