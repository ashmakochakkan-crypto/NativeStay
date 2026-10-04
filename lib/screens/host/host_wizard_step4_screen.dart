import 'package:flutter/material.dart';
import '../../models/property_listing_data.dart';
import 'host_wizard_step5_screen.dart';
import 'wizard_helpers.dart';

class HostWizardStep4Screen extends StatefulWidget {
  final String userName;
  final PropertyListingData data;
  const HostWizardStep4Screen(
      {super.key, required this.userName, required this.data});

  @override
  State<HostWizardStep4Screen> createState() => _HostWizardStep4ScreenState();
}

class _HostWizardStep4ScreenState extends State<HostWizardStep4Screen> {
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _fullAddrController = TextEditingController();
  final _attractionsController = TextEditingController();
  final _transportController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _stateController.text = widget.data.state;
    _cityController.text = widget.data.city;
    _areaController.text = widget.data.area;
    _fullAddrController.text = widget.data.fullAddress;
    _attractionsController.text = widget.data.nearbyAttractions;
    _transportController.text = widget.data.transportDistance;
  }

  @override
  void dispose() {
    _stateController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _fullAddrController.dispose();
    _attractionsController.dispose();
    _transportController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_stateController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _fullAddrController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required location fields')),
      );
      return;
    }
    widget.data.state = _stateController.text.trim();
    widget.data.city = _cityController.text.trim();
    widget.data.area = _areaController.text.trim();
    widget.data.fullAddress = _fullAddrController.text.trim();
    widget.data.nearbyAttractions = _attractionsController.text.trim();
    widget.data.transportDistance = _transportController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HostWizardStep5Screen(userName: widget.userName, data: widget.data),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38),
            prefixIcon:
                icon != null ? Icon(icon, color: const Color(0xFFF3BDC3)) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFF3BDC3), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        Icon(Icons.location_on_outlined,
                            color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Text('Where is it?',
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Guests will see this on the map',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    _field(
                      controller: _stateController,
                      label: 'State *',
                      hint: 'e.g. Kerala',
                      icon: Icons.map_outlined,
                    ),
                    _field(
                      controller: _cityController,
                      label: 'City *',
                      hint: 'e.g. Kochi',
                      icon: Icons.location_city_rounded,
                    ),
                    _field(
                      controller: _areaController,
                      label: 'Area / Locality',
                      hint: 'e.g. Fort Kochi',
                      icon: Icons.place_outlined,
                    ),
                    _field(
                      controller: _fullAddrController,
                      label: 'Full Address *',
                      hint: 'House no, street, landmark...',
                      icon: Icons.home_outlined,
                      maxLines: 2,
                    ),
                    _field(
                      controller: _attractionsController,
                      label: 'Nearby Attractions',
                      hint: 'e.g. Beach, Fort, Museum',
                      icon: Icons.attractions_outlined,
                    ),
                    _field(
                      controller: _transportController,
                      label: 'Distance from Major Transport',
                      hint: 'e.g. 5 km from airport',
                      icon: Icons.directions_transit_rounded,
                    ),
                  ],
                ),
              ),
            ),
            WizardBottomBar(
              onPrevious: () => Navigator.pop(context),
              onNext: _handleNext,
            ),
          ],
        ),
      ),
    );
  }
}