import 'package:image_picker/image_picker.dart';

class AvailabilityPeriod {
  final DateTime start;
  final DateTime end;
  const AvailabilityPeriod({required this.start, required this.end});

  bool containsRange(DateTime otherStart, DateTime otherEnd) {
    return !otherStart.isBefore(start) && !otherEnd.isAfter(end);
  }

  String get label {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[start.month - 1]} ${start.day} – ${months[end.month - 1]} ${end.day}, ${end.year}';
  }

  Map<String, String> toMap() => {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      };

  static AvailabilityPeriod? fromMap(Map<String, dynamic> m) {
    try {
      final s = DateTime.tryParse((m['start'] ?? '').toString());
      final e = DateTime.tryParse((m['end'] ?? '').toString());
      if (s == null || e == null) return null;
      return AvailabilityPeriod(start: s, end: e);
    } catch (_) {
      return null;
    }
  }
}

class PropertyListingData {
  String? docId;
  String stayName = '';
  String propertyType = 'House';
  String stayType = 'Entire Property';
  String shortDescription = '';
  String guests = '2';
  String bedrooms = '1';
  String beds = '1';
  String bathrooms = '1';
  String propertySize = '';
  List<Map<String, String>> availabilityPeriods = [];
  String suitableFor = 'Families';

  String state = '';
  String city = '';
  String area = '';
  String fullAddress = '';
  String nearbyAttractions = '';
  String transportDistance = '';

  List<XFile> localPhotos = [];
  List<String> photos = [];

  String liveWithHost = 'No';
  String shareProperty = 'No';
  String sharedAreas = 'None';
  String haveRoommates = 'No';
  String otherPeopleCount = '0';
  String familyCount = '0';
  String familyRelation = 'None';
  String privateAreas = '';

  List<String> amenities = [];

  String pricePerNight = '';
  String extraCharges = '';
  String minStay = '1';
  String maxStay = '30';
  String checkIn = '12:00 PM';
  String checkOut = '11:00 AM';
  String availableDates = 'All Year';
  String instantBooking = 'Yes';
  String cancellationPolicy = 'Flexible';
  String advanceDeposit = 'None';

  String hostName = '';
  String phone = '';
  String email = '';
  String hostBio = '';
  String languagesSpoken = '';

  String hostAvailable = 'Always';
  String availabilityHours = '24/7';
  String familyAssistance = 'Yes';
  String contactPerson = 'Host';
  String emergencyNum = '';
  String localInfoHelp = 'Yes';

  String firstAid = 'Yes';
  String fireExtinguisher = 'Yes';
  String smokeDetector = 'Yes';
  String emergencyExit = 'Yes';
  String doorLock = 'Yes';
  String cctvCommon = 'No';
  String nearestHospital = '';
  String safetyInstructions = '';

  String smoking = 'Not Allowed';
  String petsAllowed = 'Not Allowed';
  String parties = 'Not Allowed';
  String quietHours = '10 PM - 7 AM';
  String visitorsAllowed = 'Yes';
  String childrenAllowed = 'Yes';
  String commercialPhotography = 'Not Allowed';
  String events = 'Not Allowed';
  String houseRulesOther = '';

  String culturalExperience = 'No';
  String experienceType = 'None';
  String homeCookedFood = 'No';
  String localGuide = 'No';
  String activitiesOffered = '';
  String recommendedPlaces = '';
  String expCostExtra = 'No';
  String expPrice = '';

  String vehicleAvailable = 'No';
  String vehicleType = 'None';
  String driverOption = 'Without Driver';
  String vehicleCapacity = '4';
  String vehiclePrice = '';
  String pickupDrop = 'No';

  String idVerification = 'Pending';
  String ownershipDoc = 'Pending';
  String propertyVerificationStatus = 'Pending';

  PropertyListingData();

  factory PropertyListingData.fromMap(Map<String, dynamic> map, String id) {
    return PropertyListingData()
      ..docId = id
      ..stayName = (map['stayName'] ?? '') as String
      ..propertyType = (map['propertyType'] ?? 'House') as String
      ..stayType = (map['stayType'] ?? 'Entire Property') as String
      ..shortDescription = (map['shortDescription'] ?? '') as String
      ..guests = (map['guests'] ?? '2') as String
      ..bedrooms = (map['bedrooms'] ?? '1') as String
      ..beds = (map['beds'] ?? '1') as String
      ..bathrooms = (map['bathrooms'] ?? '1') as String
      ..propertySize = (map['propertySize'] ?? '') as String
      ..suitableFor = (map['suitableFor'] ?? 'Families') as String
      ..availabilityPeriods = (map['availabilityPeriods'] as List? ?? [])
          .map((e) => Map<String, String>.from(e as Map))
          .toList()
      ..state = (map['state'] ?? '') as String
      ..city = (map['city'] ?? '') as String
      ..area = (map['area'] ?? '') as String
      ..fullAddress = (map['fullAddress'] ?? '') as String
      ..nearbyAttractions = (map['nearbyAttractions'] ?? '') as String
      ..transportDistance = (map['transportDistance'] ?? '') as String
      ..photos = List<String>.from(map['photos'] ?? [])
      ..liveWithHost = (map['liveWithHost'] ?? 'No') as String
      ..shareProperty = (map['shareProperty'] ?? 'No') as String
      ..sharedAreas = (map['sharedAreas'] ?? 'None') as String
      ..haveRoommates = (map['haveRoommates'] ?? 'No') as String
      ..otherPeopleCount = (map['otherPeopleCount'] ?? '0') as String
      ..familyCount = (map['familyCount'] ?? '0') as String
      ..familyRelation = (map['familyRelation'] ?? 'None') as String
      ..privateAreas = (map['privateAreas'] ?? '') as String
      ..amenities = List<String>.from(map['amenities'] ?? [])
      ..pricePerNight = (map['pricePerNight'] ?? '') as String
      ..extraCharges = (map['extraCharges'] ?? '') as String
      ..minStay = (map['minStay'] ?? '1') as String
      ..maxStay = (map['maxStay'] ?? '30') as String
      ..checkIn = (map['checkIn'] ?? '12:00 PM') as String
      ..checkOut = (map['checkOut'] ?? '11:00 AM') as String
      ..availableDates = (map['availableDates'] ?? 'All Year') as String
      ..instantBooking = (map['instantBooking'] ?? 'Yes') as String
      ..cancellationPolicy =
          (map['cancellationPolicy'] ?? 'Flexible') as String
      ..advanceDeposit = (map['advanceDeposit'] ?? 'None') as String
      ..hostName = (map['hostName'] ?? '') as String
      ..phone = (map['phone'] ?? '') as String
      ..email = (map['email'] ?? '') as String
      ..hostBio = (map['hostBio'] ?? '') as String
      ..languagesSpoken = (map['languagesSpoken'] ?? '') as String
      ..hostAvailable = (map['hostAvailable'] ?? 'Always') as String
      ..availabilityHours = (map['availabilityHours'] ?? '24/7') as String
      ..familyAssistance = (map['familyAssistance'] ?? 'Yes') as String
      ..contactPerson = (map['contactPerson'] ?? 'Host') as String
      ..emergencyNum = (map['emergencyNum'] ?? '') as String
      ..localInfoHelp = (map['localInfoHelp'] ?? 'Yes') as String
      ..firstAid = (map['firstAid'] ?? 'Yes') as String
      ..fireExtinguisher = (map['fireExtinguisher'] ?? 'Yes') as String
      ..smokeDetector = (map['smokeDetector'] ?? 'Yes') as String
      ..emergencyExit = (map['emergencyExit'] ?? 'Yes') as String
      ..doorLock = (map['doorLock'] ?? 'Yes') as String
      ..cctvCommon = (map['cctvCommon'] ?? 'No') as String
      ..nearestHospital = (map['nearestHospital'] ?? '') as String
      ..safetyInstructions = (map['safetyInstructions'] ?? '') as String
      ..smoking = (map['smoking'] ?? 'Not Allowed') as String
      ..petsAllowed = (map['petsAllowed'] ?? 'Not Allowed') as String
      ..parties = (map['parties'] ?? 'Not Allowed') as String
      ..quietHours = (map['quietHours'] ?? '10 PM - 7 AM') as String
      ..visitorsAllowed = (map['visitorsAllowed'] ?? 'Yes') as String
      ..childrenAllowed = (map['childrenAllowed'] ?? 'Yes') as String
      ..commercialPhotography =
          (map['commercialPhotography'] ?? 'Not Allowed') as String
      ..events = (map['events'] ?? 'Not Allowed') as String
      ..houseRulesOther = (map['houseRulesOther'] ?? '') as String
      ..culturalExperience = (map['culturalExperience'] ?? 'No') as String
      ..experienceType = (map['experienceType'] ?? 'None') as String
      ..homeCookedFood = (map['homeCookedFood'] ?? 'No') as String
      ..localGuide = (map['localGuide'] ?? 'No') as String
      ..activitiesOffered = (map['activitiesOffered'] ?? '') as String
      ..recommendedPlaces = (map['recommendedPlaces'] ?? '') as String
      ..expCostExtra = (map['expCostExtra'] ?? 'No') as String
      ..expPrice = (map['expPrice'] ?? '') as String
      ..vehicleAvailable = (map['vehicleAvailable'] ?? 'No') as String
      ..vehicleType = (map['vehicleType'] ?? 'None') as String
      ..driverOption = (map['driverOption'] ?? 'Without Driver') as String
      ..vehicleCapacity = (map['vehicleCapacity'] ?? '4') as String
      ..vehiclePrice = (map['vehiclePrice'] ?? '') as String
      ..pickupDrop = (map['pickupDrop'] ?? 'No') as String
      ..idVerification = (map['idVerification'] ?? 'Pending') as String
      ..ownershipDoc = (map['ownershipDoc'] ?? 'Pending') as String
      ..propertyVerificationStatus =
          (map['propertyVerificationStatus'] ?? 'Pending') as String;
  }
}