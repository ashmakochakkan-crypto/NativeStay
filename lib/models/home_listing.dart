import 'package:cloud_firestore/cloud_firestore.dart';
import 'property_listing_data.dart';

class HomeListing {
  final String docId;
  final String userId;
  final String stayName;
  final String propertyType;
  final String stayType;
  final String city;
  final String state;
  final String area;
  final String fullAddress;
  final String pricePerNight;
  final String shortDescription;
  final List<String> photos;
  final List<String> amenities;
  final String hostName;
  final String hostBio;
  final String nearestAttraction;
  final DateTime? submittedAt;
  final String checkIn;
  final String checkOut;
  final String smoking;
  final String petsAllowed;
  final String parties;
  final String visitorsAllowed;
  final String childrenAllowed;
  final String quietHours;
  final String houseRulesOther;
  final String guests;
  final String bedrooms;
  final List<String> safetyFeatures;
  final List<AvailabilityPeriod> availabilityPeriods;
  final String cancellationPolicy;

  // Sharing & household
  final String liveWithHost;
  final String shareProperty;
  final String sharedAreas;
  final String haveRoommates;
  final String otherPeopleCount;
  final String familyCount;
  final String familyRelation;

  // Local experience
  final String culturalExperience;
  final String homeCookedFood;
  final String localGuide;
  final String activitiesOffered;
  final String expPrice;

  // Vehicle service
  final String vehicleAvailable;
  final String vehicleType;
  final String driverOption;
  final String vehiclePrice;

  // Booking details
  final String minStay;
  final String maxStay;
  final String availableDates;
  final String instantBooking;
  final String advanceDeposit;

  // Availability help
  final String availabilityHours;
  final String localInfoHelp;

  // Guest privacy
  final String privateAreas;

  // Safety extras
  final String smokeDetector;
  final String emergencyExit;
  final String doorLock;
  final String nearestHospital;
  final String safetyInstructions;

  const HomeListing({
    required this.docId,
    required this.userId,
    required this.stayName,
    required this.propertyType,
    required this.stayType,
    required this.city,
    required this.state,
    required this.area,
    required this.fullAddress,
    required this.pricePerNight,
    required this.shortDescription,
    required this.photos,
    required this.amenities,
    required this.hostName,
    required this.hostBio,
    required this.nearestAttraction,
    required this.submittedAt,
    required this.checkIn,
    required this.checkOut,
    required this.smoking,
    required this.petsAllowed,
    required this.parties,
    required this.visitorsAllowed,
    required this.childrenAllowed,
    required this.quietHours,
    required this.houseRulesOther,
    required this.guests,
    required this.bedrooms,
    required this.safetyFeatures,
    required this.availabilityPeriods,
    required this.cancellationPolicy,
    required this.liveWithHost,
    required this.shareProperty,
    required this.sharedAreas,
    required this.haveRoommates,
    required this.otherPeopleCount,
    required this.familyCount,
    required this.familyRelation,
    required this.culturalExperience,
    required this.homeCookedFood,
    required this.localGuide,
    required this.activitiesOffered,
    required this.expPrice,
    required this.vehicleAvailable,
    required this.vehicleType,
    required this.driverOption,
    required this.vehiclePrice,
    required this.minStay,
    required this.maxStay,
    required this.availableDates,
    required this.instantBooking,
    required this.advanceDeposit,
    required this.availabilityHours,
    required this.localInfoHelp,
    required this.smokeDetector,
    required this.emergencyExit,
    required this.doorLock,
    required this.nearestHospital,
    required this.safetyInstructions,
    required this.privateAreas,
  });

  String get coverPhoto => photos.isNotEmpty ? photos.first : '';

  String get locationLabel {
    final parts = [city, state].where((e) => e.trim().isNotEmpty).toList();
    return parts.isEmpty ? 'India' : parts.join(', ');
  }

  String get priceLabel {
    if (pricePerNight.trim().isEmpty) return '₹—';
    return '₹$pricePerNight';
  }

  String get hostInitial {
    final n = hostName.trim();
    return n.isEmpty ? 'H' : n[0].toUpperCase();
  }

  factory HomeListing.fromDoc(String id, Map<String, dynamic> map) {
    DateTime? submitted;
    final raw = map['submittedAt'];
    if (raw is Timestamp) {
      submitted = raw.toDate();
    } else if (raw is DateTime) {
      submitted = raw;
    }

    final List<String> safety = [];
    if (map['firstAid'] == 'Yes') safety.add('First-aid kit');
    if (map['fireExtinguisher'] == 'Yes') safety.add('Fire extinguisher');
    if (map['cctvCommon'] == 'Yes') safety.add('CCTV in common areas');

    return HomeListing(
      docId: id,
      userId: (map['userId'] ?? '').toString(),
      stayName: (map['stayName'] ?? 'Untitled Stay').toString(),
      propertyType: (map['propertyType'] ?? 'Homestay').toString(),
      stayType: (map['stayType'] ?? 'Entire Property').toString(),
      city: (map['city'] ?? '').toString(),
      state: (map['state'] ?? '').toString(),
      area: (map['area'] ?? '').toString(),
      fullAddress: (map['fullAddress'] ?? '').toString(),
      pricePerNight: (map['pricePerNight'] ?? '').toString(),
      shortDescription: (map['shortDescription'] ?? '').toString(),
      photos: List<String>.from(map['photos'] ?? []),
      amenities: List<String>.from(map['amenities'] ?? []),
      hostName: (map['hostName'] ?? 'Host').toString(),
      hostBio: (map['hostBio'] ?? '').toString(),
      nearestAttraction: (map['nearbyAttractions'] ?? '').toString(),
      submittedAt: submitted,
      checkIn: (map['checkIn'] ?? '12:00 PM').toString(),
      checkOut: (map['checkOut'] ?? '11:00 AM').toString(),
      smoking: (map['smoking'] ?? 'Not Allowed').toString(),
      petsAllowed: (map['petsAllowed'] ?? 'Not Allowed').toString(),
      parties: (map['parties'] ?? 'Not Allowed').toString(),
      visitorsAllowed: (map['visitorsAllowed'] ?? 'Yes').toString(),
      childrenAllowed: (map['childrenAllowed'] ?? 'Yes').toString(),
      quietHours: (map['quietHours'] ?? '10 PM - 7 AM').toString(),
      houseRulesOther: (map['houseRulesOther'] ?? '').toString(),
      guests: (map['guests'] ?? '0').toString(),
      bedrooms: (map['bedrooms'] ?? '0').toString(),
      safetyFeatures: safety,
      availabilityPeriods: (map['availabilityPeriods'] as List? ?? [])
          .map((e) => AvailabilityPeriod.fromMap(
              Map<String, dynamic>.from(e as Map)))
          .whereType<AvailabilityPeriod>()
          .toList(),
      cancellationPolicy:
          (map['cancellationPolicy'] ?? 'Flexible').toString(),
      liveWithHost: (map['liveWithHost'] ?? 'No').toString(),
      shareProperty: (map['shareProperty'] ?? 'No').toString(),
      sharedAreas: (map['sharedAreas'] ?? 'None').toString(),
      haveRoommates: (map['haveRoommates'] ?? 'No').toString(),
      otherPeopleCount: (map['otherPeopleCount'] ?? '0').toString(),
      familyCount: (map['familyCount'] ?? '0').toString(),
      familyRelation: (map['familyRelation'] ?? 'None').toString(),
      culturalExperience: (map['culturalExperience'] ?? 'No').toString(),
      homeCookedFood: (map['homeCookedFood'] ?? 'No').toString(),
      localGuide: (map['localGuide'] ?? 'No').toString(),
      activitiesOffered: (map['activitiesOffered'] ?? '').toString(),
      expPrice: (map['expPrice'] ?? '').toString(),
      vehicleAvailable: (map['vehicleAvailable'] ?? 'No').toString(),
      vehicleType: (map['vehicleType'] ?? '').toString(),
      driverOption: (map['driverOption'] ?? '').toString(),
      vehiclePrice: (map['vehiclePrice'] ?? '').toString(),
      minStay: (map['minStay'] ?? '1').toString(),
      maxStay: (map['maxStay'] ?? '30').toString(),
      availableDates: (map['availableDates'] ?? 'All Year').toString(),
      instantBooking: (map['instantBooking'] ?? 'Yes').toString(),
      advanceDeposit: (map['advanceDeposit'] ?? 'None').toString(),
      availabilityHours: (map['availabilityHours'] ?? '24/7').toString(),
      localInfoHelp: (map['localInfoHelp'] ?? 'Yes').toString(),
      smokeDetector: (map['smokeDetector'] ?? 'Yes').toString(),
      emergencyExit: (map['emergencyExit'] ?? 'Yes').toString(),
      doorLock: (map['doorLock'] ?? 'Yes').toString(),
      nearestHospital: (map['nearestHospital'] ?? '').toString(),
      safetyInstructions: (map['safetyInstructions'] ?? '').toString(),
      privateAreas: (map['privateAreas'] ?? '').toString(),
    );
  }
}