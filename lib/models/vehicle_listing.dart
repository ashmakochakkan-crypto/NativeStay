import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class VehicleListing {
  final String docId;
  final String userId;
  final String nickname;
  final String vehicleType;
  final String make;
  final String model;
  final String year;
  final String registrationNumber;
  final String color;
  final String fuelType;
  final String transmission;
  final String seats;
  final String luggage;
  final String acType;
  final String mileage;

  final String state;
  final String city;
  final String area;
  final String deliveryAvailable;
  final String deliveryFee;

  final String rentalMode; // Self-drive | Chauffeur-driven | Both
  final String driverName;
  final String driverPhone;
  final String driverExperience;
  final String driverLanguages;

  final String pricingModel; // Per Hour | Per Day | Per Km | Per Person
  final String basePrice;
  final String minBilling;
  final String extraKmCharge;
  final String extraHourCharge;
  final String driverAllowance;
  final String fuelPolicy; // Included | Not Included | Same-to-Same
  final String securityDeposit;

  final String cancellationPolicy;
  final String lateReturnFee;
  final String cleaningFee;
  final String smokingPolicy;
  final String petPolicy;
  final String mileageLimit;
  final String interstateAllowed;

  final List<String> features;
  final List<String> photos;
  final bool isPublished;
  final DateTime? submittedAt;
  final double rating;
  final int reviewCount;

  const VehicleListing({
    required this.docId,
    required this.userId,
    required this.nickname,
    required this.vehicleType,
    required this.make,
    required this.model,
    required this.year,
    required this.registrationNumber,
    required this.color,
    required this.fuelType,
    required this.transmission,
    required this.seats,
    required this.luggage,
    required this.acType,
    required this.mileage,
    required this.state,
    required this.city,
    required this.area,
    required this.deliveryAvailable,
    required this.deliveryFee,
    required this.rentalMode,
    required this.driverName,
    required this.driverPhone,
    required this.driverExperience,
    required this.driverLanguages,
    required this.pricingModel,
    required this.basePrice,
    required this.minBilling,
    required this.extraKmCharge,
    required this.extraHourCharge,
    required this.driverAllowance,
    required this.fuelPolicy,
    required this.securityDeposit,
    required this.cancellationPolicy,
    required this.lateReturnFee,
    required this.cleaningFee,
    required this.smokingPolicy,
    required this.petPolicy,
    required this.mileageLimit,
    required this.interstateAllowed,
    required this.features,
    required this.photos,
    required this.isPublished,
    required this.submittedAt,
    required this.rating,
    required this.reviewCount,
  });

  String get coverPhoto => photos.isNotEmpty ? photos.first : '';

  String get displayTitle {
    if (make.isEmpty && model.isEmpty) return nickname;
    return '$make $model $year'.trim();
  }

  String get locationLabel {
    final parts = [city, state].where((e) => e.trim().isNotEmpty).toList();
    return parts.isEmpty ? 'India' : parts.join(', ');
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
      case 'Per Km':
        return ' / km';
      case 'Per Person':
        return ' / person';
      default:
        return '';
    }
  }

  String get ratingLabel {
    if (reviewCount == 0) return 'New';
    return rating.toStringAsFixed(1);
  }

  String get modeShort {
    switch (rentalMode) {
      case 'Self-drive':
        return 'Self-drive';
      case 'Chauffeur-driven':
        return 'With driver';
      case 'Both':
        return 'Self-drive · With driver';
      default:
        return rentalMode;
    }
  }

  factory VehicleListing.fromDoc(String id, Map<String, dynamic> map) {
    DateTime? submitted;
    final raw = map['submittedAt'];
    if (raw is Timestamp) {
      submitted = raw.toDate();
    } else if (raw is DateTime) {
      submitted = raw;
    }

    return VehicleListing(
      docId: id,
      userId: (map['userId'] ?? '').toString(),
      nickname: (map['nickname'] ?? 'Vehicle').toString(),
      vehicleType: (map['vehicleType'] ?? 'Car').toString(),
      make: (map['make'] ?? '').toString(),
      model: (map['model'] ?? '').toString(),
      year: (map['year'] ?? '').toString(),
      registrationNumber: (map['registrationNumber'] ?? '').toString(),
      color: (map['color'] ?? '').toString(),
      fuelType: (map['fuelType'] ?? 'Petrol').toString(),
      transmission: (map['transmission'] ?? 'Manual').toString(),
      seats: (map['seats'] ?? '').toString(),
      luggage: (map['luggage'] ?? '').toString(),
      acType: (map['acType'] ?? 'AC').toString(),
      mileage: (map['mileage'] ?? '').toString(),
      state: (map['state'] ?? '').toString(),
      city: (map['city'] ?? '').toString(),
      area: (map['area'] ?? '').toString(),
      deliveryAvailable: (map['deliveryAvailable'] ?? 'No').toString(),
      deliveryFee: (map['deliveryFee'] ?? '').toString(),
      rentalMode: (map['rentalMode'] ?? 'Self-drive').toString(),
      driverName: (map['driverName'] ?? '').toString(),
      driverPhone: (map['driverPhone'] ?? '').toString(),
      driverExperience: (map['driverExperience'] ?? '').toString(),
      driverLanguages: (map['driverLanguages'] ?? '').toString(),
      pricingModel: (map['pricingModel'] ?? 'Per Day').toString(),
      basePrice: (map['basePrice'] ?? '').toString(),
      minBilling: (map['minBilling'] ?? '').toString(),
      extraKmCharge: (map['extraKmCharge'] ?? '').toString(),
      extraHourCharge: (map['extraHourCharge'] ?? '').toString(),
      driverAllowance: (map['driverAllowance'] ?? '').toString(),
      fuelPolicy: (map['fuelPolicy'] ?? 'Included').toString(),
      securityDeposit: (map['securityDeposit'] ?? '').toString(),
      cancellationPolicy:
          (map['cancellationPolicy'] ?? 'Flexible').toString(),
      lateReturnFee: (map['lateReturnFee'] ?? '').toString(),
      cleaningFee: (map['cleaningFee'] ?? '').toString(),
      smokingPolicy: (map['smokingPolicy'] ?? 'Not Allowed').toString(),
      petPolicy: (map['petPolicy'] ?? 'Not Allowed').toString(),
      mileageLimit: (map['mileageLimit'] ?? '').toString(),
      interstateAllowed: (map['interstateAllowed'] ?? 'No').toString(),
      features: List<String>.from(map['features'] ?? []),
      photos: List<String>.from(map['photos'] ?? []),
      isPublished: map['isPublished'] == true,
      submittedAt: submitted,
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: (map['reviewCount'] ?? 0).toInt(),
    );
  }
}

/// Data carrier for the vehicle wizard.
class VehicleListingData {
  String? docId;
  String nickname = '';
  String vehicleType = 'Car';
  String make = '';
  String model = '';
  String year = '';
  String registrationNumber = '';
  String color = '';
  String fuelType = 'Petrol';
  String transmission = 'Manual';
  String seats = '4';
  String luggage = '2';
  String acType = 'AC';
  String mileage = '';

  String state = '';
  String city = '';
  String area = '';
  String deliveryAvailable = 'No';
  String deliveryFee = '';

  String rentalMode = 'Self-drive';
  String driverName = '';
  String driverPhone = '';
  String driverExperience = '';
  String driverLanguages = '';

  String pricingModel = 'Per Day';
  String basePrice = '';
  String minBilling = '';
  String extraKmCharge = '';
  String extraHourCharge = '';
  String driverAllowance = '';
  String fuelPolicy = 'Included';
  String securityDeposit = '';

  String cancellationPolicy = 'Flexible';
  String lateReturnFee = '';
  String cleaningFee = '';
  String smokingPolicy = 'Not Allowed';
  String petPolicy = 'Not Allowed';
  String mileageLimit = '';
  String interstateAllowed = 'No';

  List<String> features = [];
  List<String> photos = [];
  List<XFile> localPhotos = [];
  bool isPublished = false;

  VehicleListingData();
}