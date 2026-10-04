import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../helpers/text_utils.dart';
import '../../models/tour_guide.dart';
import '../../services/tour_guides_service.dart';
import '../../widgets/badges.dart';
import '../../widgets/common_tiles.dart';
import '../auth/login_modal_sheet.dart';
import '../home/address_search_sheet.dart';
import 'guide_dashboard_screen.dart';
import 'guide_profile_screen.dart';
import 'guide_wizard_step1_screen.dart';

class TourGuidesScreen extends StatefulWidget {
  const TourGuidesScreen({super.key});

  @override
  State<TourGuidesScreen> createState() => _TourGuidesScreenState();
}

class _TourGuidesScreenState extends State<TourGuidesScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<TourGuide> _allGuides = [];
  bool _isLoading = true;
  bool _userIsGuide = false;
  int _selectedFilterIndex = 0;
  String _appliedSearch = '';
  StreamSubscription<User?>? _authSub;
  String? _lastUid;

  final List<Map<String, dynamic>> _filters = [
    {'title': 'All', 'icon': Icons.grid_view_rounded},
    {'title': 'City Tours', 'icon': Icons.location_city_rounded},
    {'title': 'Trekking', 'icon': Icons.hiking_rounded},
    {'title': 'Food Walks', 'icon': Icons.restaurant_rounded},
    {'title': 'Cultural', 'icon': Icons.temple_hindu_rounded},
    {'title': 'Wildlife', 'icon': Icons.pets_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _loadGuides();
    _lastUid = FirebaseAuth.instance.currentUser?.uid;
    _checkIfUserIsGuide();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user?.uid != _lastUid) {
        _lastUid = user?.uid;
        _checkIfUserIsGuide();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGuides() async {
    if (mounted) setState(() => _isLoading = true);
    final list = await TourGuidesService.fetchPublished();
    if (!mounted) return;
    setState(() {
      _allGuides = list;
      _isLoading = false;
    });
  }

  Future<void> _checkIfUserIsGuide() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _userIsGuide = false);
      return;
    }
    final has = await TourGuidesService.userHasGuideProfile(user.uid);
    if (mounted) setState(() => _userIsGuide = has);
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

  Future<void> _handleBecomeGuide() async {
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

    final existing = await TourGuidesService.fetchUserGuideProfile(user.uid);
    if (!mounted) return;

    if (existing != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GuideDashboardScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GuideWizardStep1Screen()),
      );
    }
  }

  Future<void> _openGuide(TourGuide g) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GuideProfileScreen(guide: g)),
    );
    _checkIfUserIsGuide();
  }

  Widget _buildGuideSection(String region, List<TourGuide> guides) {
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
                region,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              if (stateTagline(region).isNotEmpty)
                Text(
                  stateTagline(region),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: guides.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              return SizedBox(
                width: 200,
                child: GuideTile(
                  guide: guides[i],
                  onTap: () => _openGuide(guides[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGuidesArea() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child:
            Center(child: CircularProgressIndicator(color: Color(0xFFF3BDC3))),
      );
    }

    final specialty = _filters[_selectedFilterIndex]['title'] as String;
    final filtered = TourGuidesService.applyFilters(
      source: _allGuides,
      query: _appliedSearch,
      specialty: specialty,
    );

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.person_search_outlined,
                size: 44, color: Colors.black26),
            const SizedBox(height: 12),
            Text(
              _appliedSearch.isEmpty
                  ? (specialty == 'All'
                      ? 'No guides listed yet.\nBe the first guide! 🧭'
                      : 'No $specialty guides yet.')
                  : 'No guides found for "$_appliedSearch"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.black45, fontSize: 14, height: 1.4),
            ),
          ],
        ),
      );
    }

    final grouped = TourGuidesService.groupByRegion(filtered);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries
          .map((e) => _buildGuideSection(e.key, e.value))
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
          onRefresh: _loadGuides,
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
                      const Text('Tour Guides',
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          const ChatIconButton(),
                          const SizedBox(width: 8),
                          if (_userIsGuide)
                            GestureDetector(
                              onTap: _handleBecomeGuide,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0F3),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: const Color(0xFFF3BDC3),
                                      width: 1.5),
                                ),
                                child: const Icon(Icons.explore_rounded,
                                    color: Color(0xFFF3BDC3), size: 20),
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
                  child: Text('Travel with local experts',
                      style: TextStyle(fontSize: 14, color: Colors.black54)),
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
                                const Text('Destination',
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
                                content:
                                    Text('Please pick a destination first')),
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
                          onTap: () =>
                              setState(() => _selectedFilterIndex = index),
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildGuidesArea(),
                ),
                const SizedBox(height: 24),

                if (!_userIsGuide)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: _handleBecomeGuide,
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
                              child: const Icon(Icons.explore_rounded,
                                  color: Colors.black, size: 28),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Become a tour guide',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 2),
                                  Text(
                                      'Share your city with travelers and earn',
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