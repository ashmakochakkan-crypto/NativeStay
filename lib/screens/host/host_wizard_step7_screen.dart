import 'package:flutter/material.dart';
import '../../models/property_listing_data.dart';
import 'host_wizard_step8_screen.dart';
import 'wizard_helpers.dart';

class AmenityOption {
  final String label;
  final IconData icon;
  const AmenityOption(this.label, this.icon);
}

const List<AmenityOption> kAllAmenities = [
  AmenityOption('Wi-Fi', Icons.wifi_rounded),
  AmenityOption('AC', Icons.ac_unit_rounded),
  AmenityOption('TV', Icons.tv_rounded),
  AmenityOption('Kitchen', Icons.kitchen_rounded),
  AmenityOption('Parking', Icons.local_parking_rounded),
  AmenityOption('Pool', Icons.pool_rounded),
  AmenityOption('Hot Water', Icons.hot_tub_rounded),
  AmenityOption('Washing Machine', Icons.local_laundry_service_rounded),
  AmenityOption('Dryer', Icons.dry_rounded),
  AmenityOption('Heating', Icons.local_fire_department_rounded),
  AmenityOption('Balcony', Icons.balcony_rounded),
  AmenityOption('Garden', Icons.yard_rounded),
  AmenityOption('Power Backup', Icons.battery_charging_full_rounded),
  AmenityOption('Elevator', Icons.elevator_rounded),
  AmenityOption('Gym', Icons.fitness_center_rounded),
  AmenityOption('Workspace', Icons.laptop_mac_rounded),
  AmenityOption('Fireplace', Icons.fireplace_rounded),
  AmenityOption('BBQ Grill', Icons.outdoor_grill_rounded),
  AmenityOption('Breakfast', Icons.free_breakfast_rounded),
  AmenityOption('Dining Area', Icons.restaurant_rounded),
  AmenityOption('Refrigerator', Icons.kitchen_outlined),
  AmenityOption('Microwave', Icons.microwave_rounded),
  AmenityOption('Coffee Maker', Icons.coffee_rounded),
  AmenityOption('First Aid Kit', Icons.medical_services_rounded),
  AmenityOption('Fire Extinguisher', Icons.fire_extinguisher_rounded),
  AmenityOption('Smoke Alarm', Icons.doorbell_rounded),
  AmenityOption('CCTV', Icons.videocam_rounded),
  AmenityOption('Security Guard', Icons.security_rounded),
  AmenityOption('Pet Friendly', Icons.pets_rounded),
  AmenityOption('Wheelchair Access', Icons.accessible_rounded),
  AmenityOption('Long-term Stays', Icons.calendar_month_rounded),
  AmenityOption('Self Check-in', Icons.key_rounded),
  AmenityOption('Free Parking', Icons.directions_car_rounded),
  AmenityOption('Beach Access', Icons.beach_access_rounded),
  AmenityOption('Mountain View', Icons.landscape_rounded),
  AmenityOption('Lake View', Icons.water_rounded),
  AmenityOption('Bicycle', Icons.pedal_bike_rounded),
];

class HostWizardStep7Screen extends StatefulWidget {
  final String userName;
  final PropertyListingData data;
  const HostWizardStep7Screen(
      {super.key, required this.userName, required this.data});

  @override
  State<HostWizardStep7Screen> createState() => _HostWizardStep7ScreenState();
}

class _HostWizardStep7ScreenState extends State<HostWizardStep7Screen> {
  void _handleNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HostWizardStep8Screen(userName: widget.userName, data: widget.data),
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
                        Icon(Icons.room_service_outlined,
                            color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Text('Amenities',
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tap everything your place offers',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.data.amenities.length} selected',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF3BDC3),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: kAllAmenities.length,
                      itemBuilder: (context, index) {
                        final amenity = kAllAmenities[index];
                        final isSelected =
                            widget.data.amenities.contains(amenity.label);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                widget.data.amenities.remove(amenity.label);
                              } else {
                                widget.data.amenities.add(amenity.label);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFFF0F3)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFF3BDC3)
                                    : Colors.black12,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  amenity.icon,
                                  size: 30,
                                  color: isSelected
                                      ? const Color(0xFFF3BDC3)
                                      : Colors.black87,
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: Text(
                                    amenity.label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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