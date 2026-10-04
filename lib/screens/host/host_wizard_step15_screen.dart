import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/property_listing_data.dart';
import 'host_dashboard_screen.dart';
import 'wizard_helpers.dart';

class HostWizardStep15Screen extends StatefulWidget {
  final String userName;
  final PropertyListingData data;
  const HostWizardStep15Screen(
      {super.key, required this.userName, required this.data});

  @override
  State<HostWizardStep15Screen> createState() => _HostWizardStep15ScreenState();
}

class _HostWizardStep15ScreenState extends State<HostWizardStep15Screen> {
  bool _isSubmitting = false;

  String _formatCurrentDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Future<void> _submitListing() async {
    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;
    final formattedDate = _formatCurrentDate();

    if (user != null) {
      try {
        final payload = {
          'userId': user.uid,
          'listingStartedDate': formattedDate,
          'stayName': widget.data.stayName,
          'propertyType': widget.data.propertyType,
          'stayType': widget.data.stayType,
          'shortDescription': widget.data.shortDescription,
          'guests': widget.data.guests,
          'bedrooms': widget.data.bedrooms,
          'beds': widget.data.beds,
          'bathrooms': widget.data.bathrooms,
          'propertySize': widget.data.propertySize,
          'suitableFor': widget.data.suitableFor,
          'state': widget.data.state,
          'city': widget.data.city,
          'area': widget.data.area,
          'fullAddress': widget.data.fullAddress,
          'nearbyAttractions': widget.data.nearbyAttractions,
          'transportDistance': widget.data.transportDistance,
          'photos': widget.data.photos,
          'amenities': widget.data.amenities,
          'availabilityPeriods': widget.data.availabilityPeriods,
          'pricePerNight': widget.data.pricePerNight,
          'extraCharges': widget.data.extraCharges,
          'hostName': widget.data.hostName,
          'phone': widget.data.phone,
          'email': widget.data.email,
          'hostBio': widget.data.hostBio,
          'languagesSpoken': widget.data.languagesSpoken,
          'hostAvailable': widget.data.hostAvailable,
          'emergencyNum': widget.data.emergencyNum,
          'smoking': widget.data.smoking,
          'petsAllowed': widget.data.petsAllowed,
          'parties': widget.data.parties,
          'visitorsAllowed': widget.data.visitorsAllowed,
          'childrenAllowed': widget.data.childrenAllowed,
          'quietHours': widget.data.quietHours,
          'checkIn': widget.data.checkIn,
          'checkOut': widget.data.checkOut,
          'commercialPhotography': widget.data.commercialPhotography,
          'events': widget.data.events,
          'houseRulesOther': widget.data.houseRulesOther,
          'culturalExperience': widget.data.culturalExperience,
          'homeCookedFood': widget.data.homeCookedFood,
          'vehicleAvailable': widget.data.vehicleAvailable,
          'vehicleType': widget.data.vehicleType,
          'driverOption': widget.data.driverOption,
          'vehiclePrice': widget.data.vehiclePrice,
          'liveWithHost': widget.data.liveWithHost,
          'shareProperty': widget.data.shareProperty,
          'sharedAreas': widget.data.sharedAreas,
          'haveRoommates': widget.data.haveRoommates,
          'otherPeopleCount': widget.data.otherPeopleCount,
          'familyCount': widget.data.familyCount,
          'familyRelation': widget.data.familyRelation,
          'privateAreas': widget.data.privateAreas,
          'minStay': widget.data.minStay,
          'maxStay': widget.data.maxStay,
          'availableDates': widget.data.availableDates,
          'instantBooking': widget.data.instantBooking,
          'cancellationPolicy': widget.data.cancellationPolicy,
          'advanceDeposit': widget.data.advanceDeposit,
          'availabilityHours': widget.data.availabilityHours,
          'familyAssistance': widget.data.familyAssistance,
          'contactPerson': widget.data.contactPerson,
          'localInfoHelp': widget.data.localInfoHelp,
          'firstAid': widget.data.firstAid,
          'fireExtinguisher': widget.data.fireExtinguisher,
          'smokeDetector': widget.data.smokeDetector,
          'emergencyExit': widget.data.emergencyExit,
          'doorLock': widget.data.doorLock,
          'cctvCommon': widget.data.cctvCommon,
          'nearestHospital': widget.data.nearestHospital,
          'safetyInstructions': widget.data.safetyInstructions,
          'experienceType': widget.data.experienceType,
          'localGuide': widget.data.localGuide,
          'activitiesOffered': widget.data.activitiesOffered,
          'recommendedPlaces': widget.data.recommendedPlaces,
          'expCostExtra': widget.data.expCostExtra,
          'expPrice': widget.data.expPrice,
          'vehicleCapacity': widget.data.vehicleCapacity,
          'pickupDrop': widget.data.pickupDrop,
          'idVerification': widget.data.idVerification,
          'ownershipDoc': widget.data.ownershipDoc,
          'propertyVerificationStatus': widget.data.propertyVerificationStatus,
        };

        final isEdit =
            widget.data.docId != null && widget.data.docId!.isNotEmpty;

        if (isEdit) {
          await FirebaseFirestore.instance
              .collection('property_listings')
              .doc(widget.data.docId)
              .update(payload);
        } else {
          await FirebaseFirestore.instance.collection('property_listings').add({
            ...payload,
            'isPublished': true,
            'verificationStatus': 'Pending',
            'submittedAt': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'hostListingStartedDate': formattedDate,
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Error saving property listing: $e");
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not publish listing: $e')),
          );
        }
        return;
      }
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HostDashboardScreen(
            userName: widget.userName,
            listingDate: formattedDate,
          ),
        ),
        (route) => route.isFirst,
      );
    }
  }

  Widget _summaryRow(IconData icon, String label, String val) {
    if (val.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFF3BDC3)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(color: Colors.black54, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              val,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPhotos = widget.data.photos.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Almost done!',
                              style: TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Review your listing before publishing',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.data.stayName,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 16, color: Colors.black54),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${widget.data.city}, ${widget.data.state}',
                                  style: const TextStyle(
                                      color: Colors.black54, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _summaryRow(Icons.home_rounded, 'Type',
                              widget.data.propertyType),
                          _summaryRow(Icons.home_work_rounded, 'Stay Type',
                              widget.data.stayType),
                          _summaryRow(Icons.group_outlined, 'Guests',
                              widget.data.guests),
                          _summaryRow(Icons.bedroom_parent_outlined,
                              'Bedrooms / Baths',
                              '${widget.data.bedrooms} / ${widget.data.bathrooms}'),
                          _summaryRow(Icons.square_foot_rounded, 'Size',
                              widget.data.propertySize),
                          _summaryRow(Icons.photo_library_outlined, 'Photos',
                              '$totalPhotos added'),
                          _summaryRow(Icons.room_service_outlined, 'Amenities',
                              '${widget.data.amenities.length} selected'),
                          _summaryRow(Icons.currency_rupee_rounded,
                              'Price / night', '₹${widget.data.pricePerNight}'),
                          _summaryRow(Icons.person_outline, 'Host',
                              widget.data.hostName),
                          _summaryRow(Icons.phone_outlined, 'Phone',
                              widget.data.phone),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            WizardBottomBar(
              onPrevious: () => Navigator.pop(context),
              onNext: _submitListing,
              nextLabel: 'Publish Listing',
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}