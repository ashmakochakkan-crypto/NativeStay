import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/property_listing_data.dart';
import 'host_wizard_step1_screen.dart';
import '../../models/indian_place.dart';

class ConfirmAddressScreen extends StatefulWidget {
  final String userName;
  final IndianPlace selectedPlace;

  const ConfirmAddressScreen({
    super.key,
    required this.userName,
    required this.selectedPlace,
  });

  @override
  State<ConfirmAddressScreen> createState() => _ConfirmAddressScreenState();
}

class _ConfirmAddressScreenState extends State<ConfirmAddressScreen> {
  late TextEditingController _countryController;
  late TextEditingController _flatHouseController;
  late TextEditingController _streetController;
  late TextEditingController _landmarkController;
  late TextEditingController _districtController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pinCodeController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final place = widget.selectedPlace;

    _countryController = TextEditingController(
      text: (place.country != null && place.country!.isNotEmpty)
          ? place.country
          : 'India',
    );
    _flatHouseController = TextEditingController();
    _streetController = TextEditingController(text: place.street ?? '');
    _landmarkController = TextEditingController();
    _districtController = TextEditingController(
      text: place.subLocality?.isNotEmpty == true
          ? place.subLocality
          : (place.subAdministrativeArea ?? ''),
    );
    _cityController = TextEditingController(
      text: place.locality?.isNotEmpty == true
          ? place.locality
          : (place.subAdministrativeArea ?? ''),
    );
    _stateController =
        TextEditingController(text: place.administrativeArea ?? '');
    _pinCodeController = TextEditingController(text: place.postalCode ?? '');
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Future<void> _handleNext() async {
    final flatHouse = _flatHouseController.text.trim();
    final pinCode = _pinCodeController.text.trim();

    if (flatHouse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter flat, house, etc.')),
      );
      return;
    }

    if (pinCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter PIN code')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    final formattedDate = _formatCurrentDate();

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'hostListingStartedDate': formattedDate,
          'hostAddress': {
            'country': _countryController.text.trim(),
            'flatHouse': flatHouse,
            'street': _streetController.text.trim(),
            'landmark': _landmarkController.text.trim(),
            'district': _districtController.text.trim(),
            'city': _cityController.text.trim(),
            'state': _stateController.text.trim(),
            'pinCode': pinCode,
          },
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Error saving host address: $e");
      }
    }

    if (mounted) {
      setState(() => _isSaving = false);

      final initialListing = PropertyListingData();
      initialListing.state = _stateController.text.trim();
      initialListing.city = _cityController.text.trim();
      initialListing.fullAddress =
          '$flatHouse, ${_streetController.text.trim()}, ${_cityController.text.trim()}, ${_stateController.text.trim()} - $pinCode';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HostWizardStep1Screen(
            userName: widget.userName,
            existingData: initialListing,
          ),
        ),
      );
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hintText,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
              color: Colors.black38,
              fontSize: 14,
              fontWeight: FontWeight.normal),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Confirm your address',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black26),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Country / region',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.black54)),
                              const SizedBox(height: 2),
                              Text(
                                _countryController.text,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              color: Colors.black),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black26),
                      ),
                      child: Column(
                        children: [
                          _buildField(
                              controller: _flatHouseController,
                              hintText: 'Flat, house, etc. (required)'),
                          const Divider(height: 1, color: Colors.black12),
                          _buildField(
                              controller: _streetController,
                              hintText: 'Street address'),
                          const Divider(height: 1, color: Colors.black12),
                          _buildField(
                              controller: _landmarkController,
                              hintText: 'Nearby landmark (if applicable)'),
                          const Divider(height: 1, color: Colors.black12),
                          _buildField(
                              controller: _districtController,
                              hintText: 'District / locality (if applicable)'),
                          const Divider(height: 1, color: Colors.black12),
                          _buildField(
                              controller: _cityController,
                              hintText: 'City / town'),
                          const Divider(height: 1, color: Colors.black12),
                          _buildField(
                              controller: _stateController,
                              hintText: 'State / union territory'),
                          const Divider(height: 1, color: Colors.black12),
                          _buildField(
                              controller: _pinCodeController,
                              hintText: 'PIN code (required)'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isSaving ? null : _handleNext,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Next',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}