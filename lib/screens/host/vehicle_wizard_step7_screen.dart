import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/vehicle_listing.dart';
import '../rentals/vehicle_dashboard_screen.dart';
import 'wizard_helpers.dart';

class VehicleWizardStep7Screen extends StatefulWidget {
  final VehicleListingData data;
  const VehicleWizardStep7Screen({super.key, required this.data});

  @override
  State<VehicleWizardStep7Screen> createState() =>
      _VehicleWizardStep7ScreenState();
}

class _VehicleWizardStep7ScreenState extends State<VehicleWizardStep7Screen> {
  bool _isSubmitting = false;

  Future<void> _publish() async {
    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) setState(() => _isSubmitting = false);
      return;
    }

    try {
      final payload = {
        'userId': user.uid,
        'nickname': widget.data.nickname,
        'vehicleType': widget.data.vehicleType,
        'make': widget.data.make,
        'model': widget.data.model,
        'year': widget.data.year,
        'registrationNumber': widget.data.registrationNumber,
        'color': widget.data.color,
        'fuelType': widget.data.fuelType,
        'transmission': widget.data.transmission,
        'seats': widget.data.seats,
        'luggage': widget.data.luggage,
        'acType': widget.data.acType,
        'mileage': widget.data.mileage,
        'state': widget.data.state,
        'city': widget.data.city,
        'area': widget.data.area,
        'deliveryAvailable': widget.data.deliveryAvailable,
        'deliveryFee': widget.data.deliveryFee,
        'rentalMode': widget.data.rentalMode,
        'driverName': widget.data.driverName,
        'driverPhone': widget.data.driverPhone,
        'driverExperience': widget.data.driverExperience,
        'driverLanguages': widget.data.driverLanguages,
        'pricingModel': widget.data.pricingModel,
        'basePrice': widget.data.basePrice,
        'minBilling': widget.data.minBilling,
        'extraKmCharge': widget.data.extraKmCharge,
        'extraHourCharge': widget.data.extraHourCharge,
        'driverAllowance': widget.data.driverAllowance,
        'fuelPolicy': widget.data.fuelPolicy,
        'securityDeposit': widget.data.securityDeposit,
        'cancellationPolicy': widget.data.cancellationPolicy,
        'lateReturnFee': widget.data.lateReturnFee,
        'cleaningFee': widget.data.cleaningFee,
        'smokingPolicy': widget.data.smokingPolicy,
        'petPolicy': widget.data.petPolicy,
        'mileageLimit': widget.data.mileageLimit,
        'interstateAllowed': widget.data.interstateAllowed,
        'features': widget.data.features,
        'photos': widget.data.photos,
        'isPublished': true,
      };

      if (widget.data.docId != null && widget.data.docId!.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('vehicle_listings')
            .doc(widget.data.docId)
            .update(payload);
      } else {
        await FirebaseFirestore.instance.collection('vehicle_listings').add({
          ...payload,
          'submittedAt': FieldValue.serverTimestamp(),
          'rating': 0,
          'reviewCount': 0,
        });
      }
    } catch (e) {
      debugPrint('Publish vehicle error: $e');
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not publish vehicle: $e')),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => const VehicleDashboardScreen()),
      (route) => route.isFirst,
    );
  }

  Widget _summaryRow(IconData icon, String label, String val) {
    if (val.trim().isEmpty) return const SizedBox.shrink();
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
    final d = widget.data;

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
                          child: Text('Almost there!',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('Review your listing before publishing',
                        style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.nickname,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('${d.make} ${d.model} ${d.year}',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54)),
                          const Divider(height: 24),
                          _summaryRow(Icons.directions_car_rounded, 'Type',
                              d.vehicleType),
                          _summaryRow(Icons.location_on_outlined, 'Location',
                              '${d.city}, ${d.state}'),
                          _summaryRow(Icons.swap_horiz_rounded, 'Mode',
                              d.rentalMode),
                          _summaryRow(Icons.event_seat_outlined, 'Seats',
                              d.seats),
                          _summaryRow(Icons.local_gas_station_outlined,
                              'Fuel', d.fuelType),
                          _summaryRow(Icons.settings_outlined,
                              'Transmission', d.transmission),
                          _summaryRow(Icons.currency_rupee_rounded, 'Price',
                              '₹${d.basePrice} ${d.pricingModel}'),
                          _summaryRow(Icons.shield_outlined, 'Deposit',
                              '₹${d.securityDeposit}'),
                          _summaryRow(Icons.event_busy_rounded,
                              'Cancellation', d.cancellationPolicy),
                          _summaryRow(Icons.star_outline_rounded, 'Features',
                              '${d.features.length} selected'),
                          _summaryRow(Icons.photo_library_outlined, 'Photos',
                              '${d.photos.length} added'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            WizardBottomBar(
              onPrevious: () => Navigator.pop(context),
              onNext: _publish,
              nextLabel: 'Publish listing',
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}