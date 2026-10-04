import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../helpers/text_utils.dart';
import '../../models/home_listing.dart';
import '../../services/home_listings_service.dart';
import '../../widgets/badges.dart';
import '../../widgets/common_tiles.dart';
import '../auth/login_modal_sheet.dart';
import '../notifications/notifications_screen.dart';
import 'address_search_sheet.dart';
import 'listing_detail_screen.dart';
import '../host/host_dashboard_screen.dart';

class TravelHomeScreen extends StatefulWidget {
  const TravelHomeScreen({super.key});

  @override
  State<TravelHomeScreen> createState() => _TravelHomeScreenState();
}

class _TravelHomeScreenState extends State<TravelHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int? _adults;
  int? _children;
  int? _rooms;
  int _selectedFilterIndex = 0;

  String _appliedSearch = '';
  DateTime? _appliedCheckIn;
  DateTime? _appliedCheckOut;
  int? _appliedAdults;
  int? _appliedChildren;
  int? _appliedRooms;

  List<HomeListing> _allListings = [];
  bool _isLoadingListings = true;
  bool _hasListingsError = false;

  bool _userHasListings = false;

  StreamSubscription<User?>? _authSub;
  String? _lastUid;

  List<Map<String, dynamic>> _filters = [
    {'title': 'All', 'icon': Icons.grid_view_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _loadListings();
    _listenToAuthChanges();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _listenToAuthChanges() {
    _lastUid = FirebaseAuth.instance.currentUser?.uid;
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      final newUid = user?.uid;
      if (newUid != _lastUid) {
        _lastUid = newUid;
        _resetHomeState();
        _loadListings();
        _checkUserHasListings();
      }
    });
  }

  void _resetHomeState() {
    if (!mounted) return;
    setState(() {
      _searchController.clear();
      _checkInDate = null;
      _checkOutDate = null;
      _adults = null;
      _children = null;
      _rooms = null;
      _selectedFilterIndex = 0;
      _appliedSearch = '';
      _appliedCheckIn = null;
      _appliedCheckOut = null;
      _appliedAdults = null;
      _appliedChildren = null;
      _appliedRooms = null;
    });
  }

  Future<void> _loadListings() async {
    if (mounted) {
      setState(() {
        _isLoadingListings = true;
        _hasListingsError = false;
      });
    }
    try {
      final list = await HomeListingsService.fetchPublished();
      if (!mounted) return;

      final stateSet = <String>{};
      for (final l in list) {
        final s = l.state.trim();
        if (s.isNotEmpty) stateSet.add(normalizeState(s));
      }
      final sortedStates = stateSet.toList()..sort();

      setState(() {
        _allListings = list;
        _filters = [
          {'title': 'All', 'icon': Icons.grid_view_rounded},
          ...sortedStates
              .map((s) => {'title': s, 'icon': Icons.place_outlined}),
        ];
        if (_selectedFilterIndex >= _filters.length) {
          _selectedFilterIndex = 0;
        }
        _isLoadingListings = false;
        _hasListingsError = false;
      });
      _checkUserHasListings();
    } catch (e) {
      debugPrint('_loadListings error: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingListings = false;
        _hasListingsError = true;
      });
    }
  }

  Future<void> _checkUserHasListings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _userHasListings = false);
      return;
    }
    final has = await HomeListingsService.userHasListings(user.uid);
    if (mounted) setState(() => _userHasListings = has);
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? (_checkInDate ?? DateTime.now())
          : (_checkOutDate ?? DateTime.now().add(const Duration(days: 1))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                const ColorScheme.light(primary: Color(0xFFF3BDC3)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate != null &&
              _checkOutDate!.isBefore(_checkInDate!)) {
            _checkOutDate = _checkInDate!.add(const Duration(days: 1));
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    final List<String> weekdays = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
    ];
    final List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showGuestPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Widget buildCounterRow(String label, int? value,
                VoidCallback onDec, VoidCallback onInc) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black)),
                  Row(
                    children: [
                      IconButton(
                          onPressed: onDec,
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Color(0xFFF3BDC3))),
                      Text(value != null ? '$value' : '-',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(
                          onPressed: onInc,
                          icon: const Icon(Icons.add_circle_outline,
                              color: Color(0xFFF3BDC3))),
                    ],
                  ),
                ],
              );
            }

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Guests & Rooms',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  buildCounterRow('Adults', _adults, () {
                    if (_adults != null && _adults! > 0) {
                      setModalState(() => _adults = _adults! - 1);
                      setState(() {});
                    }
                  }, () {
                    setModalState(() => _adults = (_adults ?? 0) + 1);
                    setState(() {});
                  }),
                  buildCounterRow('Children', _children, () {
                    if (_children != null && _children! > 0) {
                      setModalState(() => _children = _children! - 1);
                      setState(() {});
                    }
                  }, () {
                    setModalState(() => _children = (_children ?? 0) + 1);
                    setState(() {});
                  }),
                  buildCounterRow('Rooms', _rooms, () {
                    if (_rooms != null && _rooms! > 0) {
                      setModalState(() => _rooms = _rooms! - 1);
                      setState(() {});
                    }
                  }, () {
                    setModalState(() => _rooms = (_rooms ?? 0) + 1);
                    setState(() {});
                  }),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3BDC3),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
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

  Future<void> _handleHostIconTap() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => LoginModalSheet(
          onAuthSuccess: (name, email, phone) {},
        ),
      );
      return;
    }

    final userName = user.displayName?.isNotEmpty == true
        ? user.displayName!
        : 'Host';

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HostDashboardScreen(
          userName: userName,
          listingDate: '—',
        ),
      ),
    );
  }

  void _openListing(HomeListing listing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListingDetailScreen(listing: listing),
      ),
    );
  }

  Widget _buildStateSection(String state, List<HomeListing> listings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          state,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        if (stateTagline(state).isNotEmpty)
          Text(
            stateTagline(state),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        const SizedBox(height: 14),
        Transform.translate(
          offset: const Offset(-20, 0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: listings.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                return SizedBox(
                  width: 200,
                  child: HomeTile(
                    listing: listings[i],
                    onTap: () => _openListing(listings[i]),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListingsArea() {
    if (_isLoadingListings) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFF3BDC3)),
        ),
      );
    }

    if (_hasListingsError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 40, color: Colors.black26),
            const SizedBox(height: 10),
            const Text(
              "Couldn't load stays. Pull to refresh.",
              style: TextStyle(color: Colors.black45, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadListings,
              child: const Text(
                'Retry',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    final filterTitle = _filters[_selectedFilterIndex]['title'] as String;
    final filtered = HomeListingsService.applyFilters(
      source: _allListings,
      query: _appliedSearch,
      filter: filterTitle,
      checkIn: _appliedCheckIn,
      checkOut: _appliedCheckOut,
      totalGuests: (_appliedAdults ?? 0) + (_appliedChildren ?? 0),
      roomsNeeded: _appliedRooms ?? 0,
    );

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded,
                size: 44, color: Colors.black26),
            const SizedBox(height: 12),
            Text(
              _appliedSearch.isEmpty
                  ? (filterTitle == 'All'
                      ? 'No stays listed yet.\nBe the first host! 🏡'
                      : 'No $filterTitle to show yet.')
                  : 'No stays found for "$_appliedSearch"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black45,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    final grouped = HomeListingsService.groupByState(filtered);
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
          onRefresh: _loadListings,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StreamBuilder<User?>(
                      stream: FirebaseAuth.instance.authStateChanges(),
                      builder: (context, authSnap) {
                        final uid = authSnap.data?.uid;
                        return StreamBuilder<
                            QuerySnapshot<Map<String, dynamic>>>(
                          stream: uid == null
                              ? const Stream.empty()
                              : FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .collection('notifications')
                                  .where('read', isEqualTo: false)
                                  .snapshots(),
                          builder: (context, snap) {
                            final count = snap.data?.docs.length ?? 0;
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                      Icons.notifications_none_rounded,
                                      color: Colors.black,
                                      size: 26),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const NotificationsScreen()),
                                  ),
                                ),
                                if (count > 0)
                                  Positioned(
                                    right: -2,
                                    top: -2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        count > 9 ? '9+' : '$count',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    Row(
                      children: [
                        if (_userHasListings)
                          StreamBuilder<User?>(
                            stream: FirebaseAuth.instance.authStateChanges(),
                            builder: (context, snap) {
                              final uid = snap.data?.uid ?? '';
                              if (uid.isEmpty) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: PendingHostBookingsBadge(
                                  hostId: uid,
                                  listingType: 'homestay',
                                  child: GestureDetector(
                                    onTap: _handleHostIconTap,
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
                                        Icons.home_work_rounded,
                                        color: Color(0xFFF3BDC3),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        const ChatIconButton(),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Where Would You Like to Explore?',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.3),
                ),
                const SizedBox(height: 24),

                GestureDetector(
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
                                    : 'Search destination',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      _searchController.text.isNotEmpty
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color: _searchController.text.isNotEmpty
                                      ? Colors.black
                                      : Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _searchController.clear();
                                _appliedSearch = '';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black12,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  size: 14, color: Colors.black87),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.black12),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 18, color: Color(0xFFF3BDC3)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text('Check-in date',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54)),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _formatDate(_checkInDate),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight:
                                                  _checkInDate != null
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                              color: _checkInDate != null
                                                  ? Colors.black
                                                  : Colors.black38,
                                            ),
                                          ),
                                        ),
                                        if (_checkInDate != null)
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _checkInDate = null;
                                                _appliedCheckIn = null;
                                              });
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(3),
                                              decoration:
                                                  const BoxDecoration(
                                                color: Colors.black12,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                  Icons.close,
                                                  size: 12,
                                                  color: Colors.black87),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.black12),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 18, color: Color(0xFFF3BDC3)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text('Check-out date',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54)),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _formatDate(_checkOutDate),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight:
                                                  _checkOutDate != null
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                              color:
                                                  _checkOutDate != null
                                                      ? Colors.black
                                                      : Colors.black38,
                                            ),
                                          ),
                                        ),
                                        if (_checkOutDate != null)
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _checkOutDate = null;
                                                _appliedCheckOut = null;
                                              });
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(3),
                                              decoration:
                                                  const BoxDecoration(
                                                color: Colors.black12,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                  Icons.close,
                                                  size: 12,
                                                  color: Colors.black87),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                GestureDetector(
                  onTap: () => _showGuestPicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Adults',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54)),
                              const SizedBox(height: 2),
                              Text(_adults != null ? '$_adults' : '-',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ],
                          ),
                        ),
                        Container(
                            width: 1, height: 28, color: Colors.black12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text('Children',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54)),
                                const SizedBox(height: 2),
                                Text(
                                    _children != null
                                        ? '$_children'
                                        : '-',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ],
                            ),
                          ),
                        ),
                        Container(
                            width: 1, height: 28, color: Colors.black12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text('Rooms',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54)),
                                const SizedBox(height: 2),
                                Text(_rooms != null ? '$_rooms' : '-',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ],
                            ),
                          ),
                        ),
                        if (_adults != null ||
                            _children != null ||
                            _rooms != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _adults = null;
                                _children = null;
                                _rooms = null;
                                _appliedAdults = null;
                                _appliedChildren = null;
                                _appliedRooms = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black12,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  size: 14, color: Colors.black87),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3BDC3),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {
                      final missing = <String>[];
                      if (_searchController.text.trim().isEmpty) {
                        missing.add('destination');
                      }
                      if (_checkInDate == null) missing.add('check-in date');
                      if (_checkOutDate == null) missing.add('check-out date');
                      if (_adults == null || _adults! < 1) {
                        missing.add('guests');
                      }

                      if (missing.isNotEmpty) {
                        final msg = missing.length == 1
                            ? 'Please add your ${missing.first}'
                            : 'Please add: ${missing.join(', ')}';

                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(msg)));
                        return;
                      }

                      setState(() {
                        _appliedSearch = _searchController.text.trim();
                        _appliedCheckIn = _checkInDate;
                        _appliedCheckOut = _checkOutDate;
                        _appliedAdults = _adults;
                        _appliedChildren = _children;
                        _appliedRooms = _rooms;
                      });
                    },
                    child: const Text('Search',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  height: 42,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedFilterIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilterIndex = index;
                          });
                        },
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
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: const Color(0xFFF3BDC3)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                            ],
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
                const SizedBox(height: 16),

                _buildListingsArea(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}