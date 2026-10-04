import 'package:flutter/material.dart';
import 'auth/login_modal_sheet.dart';
import 'home/travel_home_screen.dart';
import 'rentals/rental_vehicles.dart';
import 'guides/tour_guides_screen.dart';
import 'trips/trips_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final bool isLoggedIn;
  final Map<String, String> userProfileData;
  final Map<String, String> personalInfoData;
  final List<String> userInterests;
  final Function(Map<String, String>, List<String>) onUpdateProfile;
  final Function(Map<String, String>) onPersonalDataUpdated;
  final Function(String?, String?, String?) onAuthSuccess;

  const MainNavigationScreen({
    super.key,
    this.isLoggedIn = false,
    required this.userProfileData,
    required this.personalInfoData,
    required this.userInterests,
    required this.onUpdateProfile,
    required this.onPersonalDataUpdated,
    required this.onAuthSuccess,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void _handleNavTap(int index) {
    if (index == 4 && !widget.isLoggedIn) {
      _openLoginModal();
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _openLoginModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LoginModalSheet(onAuthSuccess: widget.onAuthSuccess),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const TravelHomeScreen(),
      const RentalVehicles(),
      const TourGuidesScreen(),
      const TripsScreen(),
      ProfileTabController(
        isGuestMode: !widget.isLoggedIn,
        profileData: widget.userProfileData,
        personalData: widget.personalInfoData,
        interests: widget.userInterests,
        onUpdateProfile: widget.onUpdateProfile,
        onPersonalDataUpdated: widget.onPersonalDataUpdated,
        onAuthSuccess: widget.onAuthSuccess,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFF3BDC3),
        unselectedItemColor: Colors.black38,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _handleNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.vpn_key_outlined), activeIcon: Icon(Icons.vpn_key), label: 'Rentals'),
          BottomNavigationBarItem(icon: Icon(Icons.person_search_outlined), activeIcon: Icon(Icons.person_search), label: 'Guides'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline_rounded), activeIcon: Icon(Icons.work_rounded), label: 'Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}