import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../helpers/text_utils.dart';
import '../../models/vehicle_listing.dart';
import '../../services/vehicle_listings_service.dart';
import '../../widgets/badges.dart';
import '../../widgets/common_tiles.dart';
import '../auth/login_modal_sheet.dart';
import '../home/address_search_sheet.dart';
import 'vehicle_dashboard_screen.dart';
import 'vehicle_detail_screen.dart';
import '../../models/indian_place.dart';

// ==========================================
// VEHICLE CONSTANTS
// ==========================================
class VehicleTypeOption {
  final String label;
  final IconData icon;
  const VehicleTypeOption(this.label, this.icon);
}

const List<VehicleTypeOption> kVehicleTypes = [
  VehicleTypeOption('Scooter', Icons.two_wheeler_rounded),
  VehicleTypeOption('Bike', Icons.motorcycle_rounded),
  VehicleTypeOption('Hatchback', Icons.directions_car_rounded),
  VehicleTypeOption('Sedan', Icons.directions_car_filled_rounded),
  VehicleTypeOption('SUV', Icons.directions_car_filled_rounded),
  VehicleTypeOption('MUV', Icons.airport_shuttle_rounded),
  VehicleTypeOption('Tempo Traveller', Icons.airport_shuttle_rounded),
  VehicleTypeOption('Van', Icons.airport_shuttle_rounded),
  VehicleTypeOption('4x4', Icons.terrain_rounded),
  VehicleTypeOption('Electric Car', Icons.electric_car_rounded),
  VehicleTypeOption('Luxury Car', Icons.directions_car_filled_rounded),
  VehicleTypeOption('Convertible', Icons.directions_car_filled_rounded),
];

const List<String> kFuelTypes = ['Petrol', 'Diesel', 'CNG', 'Electric', 'Hybrid'];
const List<String> kTransmissionTypes = ['Manual', 'Automatic'];
const List<String> kAcTypes = ['AC', 'Non-AC'];
const List<String> kRentalModes = ['Self-drive', 'Chauffeur-driven', 'Both'];
const List<String> kVehiclePricingModels = ['Per Hour', 'Per Day', 'Per Km', 'Per Person'];
const List<String> kFuelPolicies = ['Included', 'Not Included', 'Same-to-Same'];
const List<String> kVehicleCancellationPolicies = ['Flexible', 'Moderate', 'Strict'];
const List<String> kYesNo = ['Yes', 'No'];
const List<String> kAllowedNotAllowed = ['Allowed', 'Not Allowed'];

class VehicleFeatureOption {
  final String label;
  final IconData icon;
  const VehicleFeatureOption(this.label, this.icon);
}

const List<VehicleFeatureOption> kVehicleFeatures = [
  VehicleFeatureOption('Music System', Icons.music_note_rounded),
  VehicleFeatureOption('Bluetooth', Icons.bluetooth_rounded),
  VehicleFeatureOption('USB Charger', Icons.usb_rounded),
  VehicleFeatureOption('First Aid Kit', Icons.medical_services_rounded),
  VehicleFeatureOption('Child Seat', Icons.child_friendly_rounded),
  VehicleFeatureOption('GPS', Icons.gps_fixed_rounded),
  VehicleFeatureOption('Reverse Camera', Icons.videocam_rounded),
  VehicleFeatureOption('Sunroof', Icons.wb_sunny_rounded),
  VehicleFeatureOption('Roof Carrier', Icons.luggage_rounded),
  VehicleFeatureOption('Pet Friendly', Icons.pets_rounded),
  VehicleFeatureOption('Phone Holder', Icons.phone_android_rounded),
  VehicleFeatureOption('Helmet', Icons.sports_motorsports_rounded),
];

// ==========================================
// RENTAL VEHICLES DISCOVERY SCREEN
// ==========================================
class RentalVehicles extends StatefulWidget {
  const RentalVehicles({super.key});

  @override
  State<RentalVehicles> createState() => _RentalVehiclesState();
}

class _RentalVehiclesState extends State<RentalVehicles> {
  final TextEditingController _searchController = TextEditingController();

  List<VehicleListing> _allVehicles = [];
  bool _isLoading = true;
  bool _userHasVehicles = false;
  int _selectedFilterIndex = 0;
  String _appliedSearch = '';
  StreamSubscription<User?>? _authSub;
  String? _lastUid;

  final List<Map<String, dynamic>> _filters = [
    {'title': 'All', 'icon': Icons.grid_view_rounded},
    {'title': 'Scooter', 'icon': Icons.two_wheeler_rounded},
    {'title': 'Bike', 'icon': Icons.motorcycle_rounded},
    {'title': 'Sedan', 'icon': Icons.directions_car_filled_rounded},
    {'title': 'SUV', 'icon': Icons.directions_car_filled_rounded},
    {'title': 'Tempo Traveller', 'icon': Icons.airport_shuttle_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
    _lastUid = FirebaseAuth.instance.currentUser?.uid;
    _checkUserHasVehicles();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user?.uid != _lastUid) {
        _lastUid = user?.uid;
        _checkUserHasVehicles();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    if (mounted) setState(() => _isLoading = true);
    final list = await VehicleListingsService.fetchPublished();
    if (!mounted) return;
    setState(() {
      _allVehicles = list;
      _isLoading = false;
    });
  }

  Future<void> _checkUserHasVehicles() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _userHasVehicles = false);
      return;
    }
    final has = await VehicleListingsService.userHasVehicles(user.uid);
    if (mounted) setState(() => _userHasVehicles = has);
  }

  Future<void> _openLocationSearch() async {
    final IndianPlace? selectedPlace =
        await showModalBottomSheet<IndianPlace>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddressSearchSheet(),
    );
    if (selectedPlace != null) {
      setState(() {
        _searchController.text = selectedPlace.displayLabel;
        _appliedSearch = selectedPlace.displayLabel;
      });
    }
  }

  Future<void> _handleHostVehicle() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => LoginModalSheet(onAuthSuccess: (n, e, p) {}),
      );
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VehicleDashboardScreen()),
    ).then((_) {
      _loadVehicles();
      _checkUserHasVehicles();
    });
  }

  Future<void> _openVehicle(VehicleListing v) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VehicleDetailScreen(vehicle: v)),
    );
    _checkUserHasVehicles();
  }

  Widget _buildStateSection(String state, List<VehicleListing> vehicles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 4),
              if (stateTagline(state).isNotEmpty)
                Text(
                  stateTagline(state),
                  style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontStyle: FontStyle.italic),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: vehicles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              return SizedBox(
                width: 200,
                child: VehicleTile(
                  vehicle: vehicles[i],
                  onTap: () => _openVehicle(vehicles[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVehiclesArea() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child:
            Center(child: CircularProgressIndicator(color: Color(0xFFF3BDC3))),
      );
    }

    final type = _filters[_selectedFilterIndex]['title'] as String;
    final filtered = VehicleListingsService.applyFilters(
      source: _allVehicles,
      query: _appliedSearch,
      vehicleType: type,
    );

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.directions_car_outlined,
                size: 44, color: Colors.black26),
            const SizedBox(height: 12),
            Text(
              _appliedSearch.isEmpty
                  ? (type == 'All'
                      ? 'No vehicles listed yet.\nBe the first to list! 🚗'
                      : 'No $type rentals yet.')
                  : 'No vehicles found for "$_appliedSearch"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.black45, fontSize: 14, height: 1.4),
            ),
          ],
        ),
      );
    }

    final grouped = VehicleListingsService.groupByState(filtered);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries
          .map((e) => _buildStateSection(e.key, e.value))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFF3BDC3),
          onRefresh: _loadVehicles,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Rentals',
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          const ChatIconButton(),
                          const SizedBox(width: 8),
                          if (_userHasVehicles)
                            GestureDetector(
                              onTap: _handleHostVehicle,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0F3),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: const Color(0xFFF3BDC3),
                                      width: 1.5),
                                ),
                                child: const Icon(
                                    Icons.directions_car_rounded,
                                    color: Color(0xFFF3BDC3),
                                    size: 20),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Find the perfect ride',
                      style:
                          TextStyle(fontSize: 14, color: Colors.black54)),
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: _openLocationSearch,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.black12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search,
                              size: 20, color: Color(0xFFF3BDC3)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Pick-up location',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54)),
                                const SizedBox(height: 2),
                                Text(
                                  _searchController.text.isNotEmpty
                                      ? _searchController.text
                                      : 'Search city or region',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                        _searchController.text.isNotEmpty
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color:
                                        _searchController.text.isNotEmpty
                                            ? Colors.black
                                            : Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () => setState(() {
                                _searchController.clear();
                                _appliedSearch = '';
                              }),
                              child: const Icon(Icons.close,
                                  size: 18, color: Colors.black54),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3BDC3),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () {
                        if (_searchController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please pick a pick-up location first')),
                          );
                          return;
                        }
                        setState(() {
                          _appliedSearch = _searchController.text.trim();
                        });
                      },
                      child: const Text('Search',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedFilterIndex == index;
                        return GestureDetector(
                          onTap: () => setState(
                              () => _selectedFilterIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFF3BDC3)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFF3BDC3)
                                    : Colors.black12,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(_filters[index]['icon'] as IconData,
                                    size: 18, color: Colors.black),
                                const SizedBox(width: 8),
                                Text(
                                  _filters[index]['title'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildVehiclesArea(),
                const SizedBox(height: 24),

                if (!_userHasVehicles)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: _handleHostVehicle,
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFFF3BDC3), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                  color: Color(0xFFF3BDC3),
                                  shape: BoxShape.circle),
                              child: const Icon(
                                  Icons.directions_car_filled_rounded,
                                  color: Colors.black,
                                  size: 26),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('List your vehicle',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 2),
                                  Text(
                                      'Earn money by renting out your car or bike',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 16, color: Colors.black45),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}