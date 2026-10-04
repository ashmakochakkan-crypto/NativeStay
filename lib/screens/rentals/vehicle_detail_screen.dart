import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/review.dart';
import '../../models/vehicle_listing.dart';
import '../../services/review_service.dart';
import '../../services/wishlist_service.dart';
import '../../widgets/common_tiles.dart';
import '../booking/booking_sheet.dart';
import 'contact_vehicle_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final VehicleListing vehicle;
  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  final PageController _photoController = PageController();
  int _currentPhoto = 0;
  bool _isSaved = false;
  String _ownerName = '';
  String _ownerInitial = 'V';

  VehicleListing get v => widget.vehicle;

  @override
  void initState() {
    super.initState();
    _loadSavedState();
    _loadOwnerProfile();
  }

  Future<void> _loadOwnerProfile() async {
    if (v.userId.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users').doc(v.userId).get();
      final d = doc.data() ?? {};
      final fn = (d['firstName'] ?? '').toString().trim();
      final ln = (d['lastName'] ?? '').toString().trim();
      final full = '$fn $ln'.trim();
      if (!mounted) return;
      setState(() {
        _ownerName = full.isNotEmpty ? full : 'Vehicle owner';
        _ownerInitial =
            _ownerName.isNotEmpty ? _ownerName[0].toUpperCase() : 'V';
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final saved = await VehicleWishlistService.isSaved(user.uid, v.docId);
      if (mounted) setState(() => _isSaved = saved);
    } catch (e) {
      debugPrint('Vehicle wishlist load error: $e');
    }
  }

  Future<void> _toggleSave() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Log in to save to your vehicle wishlist')),
      );
      return;
    }

    final wasSaved = _isSaved;
    setState(() => _isSaved = !wasSaved);

    try {
      if (wasSaved) {
        await VehicleWishlistService.remove(user.uid, v.docId);
      } else {
        await VehicleWishlistService.add(user.uid, v);
      }
    } catch (e) {
      debugPrint('Vehicle wishlist toggle error: $e');
      if (mounted) setState(() => _isSaved = wasSaved);
    }
  }

  Widget _buildOwnerRow() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ContactVehicleScreen(vehicle: v),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black12),
            bottom: BorderSide(color: Colors.black12),
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFCE4EC),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _ownerInitial,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE91E63),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_rounded,
                        color: Colors.white, size: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hosted by ${_ownerName.isNotEmpty ? _ownerName : "Vehicle owner"}',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 2),
                  const Text('Vehicle owner · Tap to message',
                      style:
                          TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF3BDC3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 14, color: Color(0xFFE91E63)),
                  SizedBox(width: 4),
                  Text('Chat',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE91E63))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoArea() {
    final photos = v.photos;
    final hasPhotos = photos.isNotEmpty;

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        children: [
          if (hasPhotos)
            PageView.builder(
              controller: _photoController,
              itemCount: photos.length,
              onPageChanged: (i) => setState(() => _currentPhoto = i),
              itemBuilder: (context, i) => Image.network(
                photos[i],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return _placeholder();
                },
              ),
            )
          else
            _placeholder(),

          if (hasPhotos && photos.length > 1)
            Positioned(
              right: 16,
              bottom: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentPhoto + 1}/${photos.length}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

          Positioned(
            left: 16,
            top: 16,
            right: 16,
            child: Row(
              children: [
                _circleBtn(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
                const Spacer(),
                _circleBtn(
                  icon: _isSaved
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  iconColor:
                      _isSaved ? const Color(0xFFE91E63) : Colors.black87,
                  onTap: _toggleSave,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFFCE4EC),
      child: const Center(
        child: Icon(Icons.directions_car_rounded,
            size: 90, color: Color(0xFFE91E63)),
      ),
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.black87,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2)),
          ],
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }

  Widget _factRow(IconData icon, String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFF3BDC3)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: Colors.black54)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _infoBlock(IconData icon, String title, String body) {
    if (body.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.black87),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(body,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return StreamBuilder<List<Review>>(
      stream: ReviewService.streamForListing(v.docId),
      builder: (context, snap) {
        final reviews = snap.data ?? [];
        final stats = ReviewService.stats(reviews);
        final double avg = stats['average'] as double;
        final int count = stats['count'] as int;

        if (reviews.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Reviews',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFCE4EC)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.rate_review_outlined,
                        color: Color(0xFFE91E63)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No reviews yet. Be the first to rent and share your experience!',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star_rounded,
                    color: Color(0xFFE91E63), size: 22),
                const SizedBox(width: 8),
                Text(
                  '${avg.toStringAsFixed(1)} · $count review${count > 1 ? 's' : ''}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: reviews.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final r = reviews[i];
                  return Container(
                    width: 240,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFCE4EC),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(r.initial,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE91E63))),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(r.reviewerName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                  Text(r.relativeDate,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black54)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        StarRow(rating: r.rating.toDouble(), size: 14),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            r.text.isEmpty
                                ? '⭐ ${r.rating}/5 — no comment'
                                : r.text,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Colors.black12)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(v.priceLabel,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(v.priceSuffix,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContactVehicleScreen(vehicle: v),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF3BDC3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            size: 12, color: Color(0xFFE91E63)),
                        SizedBox(width: 4),
                        Text('Message owner',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE91E63))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('✓ ${v.cancellationPolicy} cancellation',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => BookingSheet(
                      listingId: v.docId,
                      listingType: 'vehicle',
                      listingName: v.displayTitle.isNotEmpty
                          ? v.displayTitle
                          : v.nickname,
                      listingPhoto: v.coverPhoto,
                      hostId: v.userId,
                      hostName: 'Vehicle owner',
                      pricePerNightOrDay: v.basePrice,
                      pricingSuffix: v.priceSuffix,
                    ),
                  );
                },
                child: const Text('Reserve',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
              ),
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
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPhotoArea(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.displayTitle.isNotEmpty
                                ? v.displayTitle
                                : v.nickname,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.25),
                          ),
                          const SizedBox(height: 6),
                          Text(v.nickname,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54)),
                          const SizedBox(height: 12),
                          StreamBuilder<List<Review>>(
                            stream: ReviewService.streamForListing(v.docId),
                            builder: (context, snap) {
                              final reviews = snap.data ?? [];
                              final stats = ReviewService.stats(reviews);
                              final double avg = stats['average'] as double;
                              final int count = stats['count'] as int;
                              return Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      size: 16, color: Color(0xFFE91E63)),
                                  const SizedBox(width: 4),
                                  Text(
                                    count == 0
                                        ? 'New'
                                        : avg.toStringAsFixed(1),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                      '($count review${count == 1 ? '' : 's'})',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54)),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.place_outlined,
                                      size: 14, color: Colors.black54),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(v.locationLabel,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54)),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 18),
                          _buildOwnerRow(),
                          const SizedBox(height: 18),

                          const Divider(height: 1, color: Colors.black12),
                          const SizedBox(height: 12),

                          _factRow(Icons.directions_car_rounded,
                              'Type', v.vehicleType),
                          _factRow(Icons.event_seat_outlined, 'Seats',
                              v.seats),
                          _factRow(Icons.luggage_outlined, 'Luggage',
                              v.luggage),
                          _factRow(Icons.ac_unit_rounded, 'AC',
                              v.acType),
                          _factRow(Icons.local_gas_station_outlined,
                              'Fuel', v.fuelType),
                          _factRow(Icons.settings_outlined,
                              'Transmission', v.transmission),
                          if (v.mileage.isNotEmpty)
                            _factRow(Icons.speed_rounded, 'Mileage',
                                v.mileage),
                          _factRow(Icons.swap_horiz_rounded,
                              'Rental mode', v.modeShort),

                          if (v.driverName.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            const Text('Driver details',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            _factRow(Icons.person_outline, 'Driver',
                                v.driverName),
                            if (v.driverPhone.isNotEmpty)
                              _factRow(Icons.phone_outlined, 'Phone',
                                  v.driverPhone),
                            if (v.driverExperience.isNotEmpty)
                              _factRow(Icons.timelapse_rounded,
                                  'Experience',
                                  '${v.driverExperience} years'),
                            if (v.driverLanguages.isNotEmpty)
                              _factRow(Icons.translate_rounded,
                                  'Languages', v.driverLanguages),
                          ],

                          const SizedBox(height: 20),

                          if (v.features.isNotEmpty) ...[
                            const Text('Features',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: v.features
                                  .map((f) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF0F3),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(f,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight:
                                                    FontWeight.w600)),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 20),
                          ],

                          _buildReviewsSection(),
                          const SizedBox(height: 20),

                          const Text('Policies',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          _infoBlock(Icons.event_busy_rounded,
                              'Cancellation', v.cancellationPolicy),
                          if (v.lateReturnFee.isNotEmpty)
                            _infoBlock(Icons.schedule_rounded,
                                'Late return fee', '₹${v.lateReturnFee}'),
                          if (v.cleaningFee.isNotEmpty)
                            _infoBlock(Icons.cleaning_services_rounded,
                                'Cleaning fee', '₹${v.cleaningFee}'),
                          if (v.mileageLimit.isNotEmpty)
                            _infoBlock(Icons.speed_rounded,
                                'Mileage limit', v.mileageLimit),
                          _infoBlock(Icons.smoking_rooms_rounded,
                              'Smoking', v.smokingPolicy),
                          _infoBlock(Icons.pets_rounded, 'Pets',
                              v.petPolicy),
                          _infoBlock(Icons.map_outlined,
                              'Interstate travel', v.interstateAllowed),

                          if (v.securityDeposit.isNotEmpty)
                            _infoBlock(Icons.shield_outlined,
                                'Security deposit',
                                '₹${v.securityDeposit}'),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }
}