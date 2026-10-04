import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/tour_guides_service.dart';
import '../guides/guide_dashboard_screen.dart';
import '../guides/guide_wizard_step1_screen.dart';
import '../rentals/vehicle_dashboard_screen.dart';

class OtherHostingOptionsScreen extends StatefulWidget {
  const OtherHostingOptionsScreen({super.key});

  @override
  State<OtherHostingOptionsScreen> createState() =>
      _OtherHostingOptionsScreenState();
}

class _OtherHostingOptionsScreenState
    extends State<OtherHostingOptionsScreen> {
  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  String? _selectedOption;

  Widget _buildOptionCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedOption == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedOption = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFF3BDC3) : Colors.black12,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFFF3BDC3).withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0F3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFFF3BDC3), size: 28),
            ),
          ],
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
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What would you like to host?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),

              _buildOptionCard(
                id: 'Experience',
                title: 'Tour Guide Experience',
                subtitle:
                    'Lead travelers through local sights, culinary trails, and hidden spots.',
                icon: Icons.explore_rounded,
              ),

              _buildOptionCard(
                id: 'Vehicle',
                title: 'Vehicle Rental Service',
                subtitle: 'List your cars, motorbikes, or scooters for rent.',
                icon: Icons.directions_car_rounded,
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedOption != null
                        ? Colors.black
                        : Colors.grey.shade200,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _selectedOption != null
                      ? () async {
                          if (_selectedOption == 'Experience') {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) {
                              _snack('Please log in first');
                              return;
                            }

                            final existing =
                                await TourGuidesService.fetchUserGuideProfile(
                                    user.uid);
                            if (!mounted) return;

                            if (existing != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const GuideDashboardScreen(),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const GuideWizardStep1Screen(),
                                ),
                              );
                            }
                          } else if (_selectedOption == 'Vehicle') {
                            if (!mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const VehicleDashboardScreen(),
                              ),
                            );
                          }
                        }
                      : null,
                  child: Text(
                    'Next',
                    style: TextStyle(
                      color: _selectedOption != null
                          ? Colors.white
                          : Colors.black38,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}