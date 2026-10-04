import 'package:flutter/material.dart';
import '../../models/property_listing_data.dart';
import 'host_wizard_step3_screen.dart';
import 'wizard_helpers.dart';

class PropertyTypeOption {
  final String label;
  final IconData icon;
  const PropertyTypeOption(this.label, this.icon);
}

const List<PropertyTypeOption> kPropertyTypes = [
  PropertyTypeOption('House', Icons.home_rounded),
  PropertyTypeOption('Apartment', Icons.apartment_rounded),
  PropertyTypeOption('Villa', Icons.villa_rounded),
  PropertyTypeOption('Bungalow', Icons.house_rounded),
  PropertyTypeOption('Cottage', Icons.cottage_rounded),
  PropertyTypeOption('Cabin', Icons.cabin_rounded),
  PropertyTypeOption('Farmhouse', Icons.agriculture_rounded),
  PropertyTypeOption('Farm', Icons.grass_rounded),
  PropertyTypeOption('Guesthouse', Icons.holiday_village_rounded),
  PropertyTypeOption('Hotel', Icons.hotel_rounded),
  PropertyTypeOption('Resort', Icons.beach_access_rounded),
  PropertyTypeOption('Houseboat', Icons.directions_boat_rounded),
  PropertyTypeOption('Treehouse', Icons.park_rounded),
  PropertyTypeOption('Haveli', Icons.account_balance_rounded),
  PropertyTypeOption('Palace', Icons.castle_rounded),
  PropertyTypeOption('Homestay', Icons.family_restroom_rounded),
  PropertyTypeOption('Mud House', Icons.landslide_rounded),
  PropertyTypeOption('Eco-lodge', Icons.eco_rounded),
  PropertyTypeOption('Tent / Glamping', Icons.cabin_rounded),
  PropertyTypeOption('Penthouse', Icons.location_city_rounded),
  PropertyTypeOption('Studio', Icons.single_bed_rounded),
  PropertyTypeOption('Dharamshala', Icons.temple_hindu_rounded),
];

class StayTypeOption {
  final String label;
  final String subtitle;
  final IconData icon;
  const StayTypeOption(this.label, this.subtitle, this.icon);
}

const List<StayTypeOption> kStayTypes = [
  StayTypeOption('Entire Property', 'Guests have the whole place',
      Icons.home_work_rounded),
  StayTypeOption('Private Room', 'A room just for guests',
      Icons.bedroom_parent_rounded),
  StayTypeOption('Shared Room', 'Shared with others',
      Icons.people_alt_rounded),
];

class HostWizardStep2Screen extends StatefulWidget {
  final String userName;
  final PropertyListingData data;
  const HostWizardStep2Screen(
      {super.key, required this.userName, required this.data});

  @override
  State<HostWizardStep2Screen> createState() => _HostWizardStep2ScreenState();
}

class _HostWizardStep2ScreenState extends State<HostWizardStep2Screen> {
  void _handleNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HostWizardStep3Screen(userName: widget.userName, data: widget.data),
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
                    const Text(
                      'What type of place?',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Pick the one that fits best',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
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
                      itemCount: kPropertyTypes.length,
                      itemBuilder: (context, index) {
                        final option = kPropertyTypes[index];
                        final isSelected =
                            widget.data.propertyType == option.label;
                        return GestureDetector(
                          onTap: () => setState(
                              () => widget.data.propertyType = option.label),
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
                                  option.icon,
                                  size: 32,
                                  color: isSelected
                                      ? const Color(0xFFF3BDC3)
                                      : Colors.black87,
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: Text(
                                    option.label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
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
                    const SizedBox(height: 32),
                    const Text(
                      'What will guests book?',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Choose how much of the place guests get',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    ...kStayTypes.map((stay) {
                      final isSelected = widget.data.stayType == stay.label;
                      return GestureDetector(
                        onTap: () => setState(
                            () => widget.data.stayType = stay.label),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
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
                          child: Row(
                            children: [
                              Icon(
                                stay.icon,
                                size: 28,
                                color: isSelected
                                    ? const Color(0xFFF3BDC3)
                                    : Colors.black87,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stay.label,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      stay.subtitle,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: Color(0xFFF3BDC3), size: 22),
                            ],
                          ),
                        ),
                      );
                    }),
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
