import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../models/review.dart';
import '../../models/tour_guide.dart';
import '../../services/booking_service.dart';
import '../../services/review_service.dart';
import '../../services/tour_guides_service.dart';
import '../../services/wishlist_service.dart';
import '../../widgets/common_tiles.dart';
import '../booking/booking_sheet.dart';
import 'contact_guide_screen.dart';

class GuideProfileScreen extends StatefulWidget {
  final TourGuide guide;
  const GuideProfileScreen({super.key, required this.guide});

  @override
  State<GuideProfileScreen> createState() => _GuideProfileScreenState();
}

class _GuideProfileScreenState extends State<GuideProfileScreen> {
  TourGuide get g => widget.guide;
  List<TourPackage> _tours = [];
  bool _isLoadingTours = true;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _loadTours();
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final saved = await GuideWishlistService.isSaved(user.uid, g.docId);
      if (mounted) setState(() => _isSaved = saved);
    } catch (e) {
      debugPrint('Guide wishlist load error: $e');
    }
  }

  Future<void> _toggleSave() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Log in to save guides to your wishlist')),
      );
      return;
    }

    final wasSaved = _isSaved;
    setState(() => _isSaved = !wasSaved);

    try {
      if (wasSaved) {
        await GuideWishlistService.remove(user.uid, g.docId);
      } else {
        await GuideWishlistService.add(user.uid, g);
      }
    } catch (e) {
      debugPrint('Guide wishlist toggle error: $e');
      if (mounted) setState(() => _isSaved = wasSaved);
    }
  }

  Future<void> _loadTours() async {
    final tours = await TourGuidesService.fetchToursForGuide(g.docId);
    if (mounted) {
      setState(() {
        _tours = tours;
        _isLoadingTours = false;
      });
    }
  }

  Widget _buildBookedBanner() {
    return StreamBuilder<List<Booking>>(
      stream: BookingService.streamConfirmedForListing(g.docId),
      builder: (context, snap) {
        final list = snap.data ?? [];
        final now = DateTime.now();
        final active = list
            .where((b) =>
                b.checkOut == null ||
                b.checkOut!.isAfter(now.subtract(const Duration(days: 1))))
            .toList();
        if (active.isEmpty) return const SizedBox.shrink();
        final first = active.first;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F3),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF3BDC3), width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_clock_rounded,
                  color: Color(0xFFE91E63)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Booked',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE91E63))),
                    const SizedBox(height: 2),
                    Text('Reserved for ${first.dateRangeLabel}',
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _factRow(IconData icon, String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _tourCard(TourPackage t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          if (t.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(t.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13, color: Colors.black54)),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              if (t.duration.isNotEmpty) ...[
                const Icon(Icons.timelapse_rounded,
                    size: 14, color: Colors.black54),
                const SizedBox(width: 4),
                Text(t.duration,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54)),
                const SizedBox(width: 12),
              ],
              if (t.groupSize.isNotEmpty) ...[
                const Icon(Icons.group_outlined,
                    size: 14, color: Colors.black54),
                const SizedBox(width: 4),
                Text(t.groupSize,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54)),
              ],
              const Spacer(),
              Text(t.priceLabel,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoArea() {
    final hasPhotos = g.photos.isNotEmpty;

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        children: [
          if (hasPhotos)
            PageView.builder(
              itemCount: g.photos.length,
              itemBuilder: (context, i) => Image.network(
                g.photos[i],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _photoPlaceholder(),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return _photoPlaceholder();
                },
              ),
            )
          else
            _photoPlaceholder(),

          if (hasPhotos && g.photos.length > 1)
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
                  '${g.photos.length} photos',
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
                GestureDetector(
                  onTap: () => Navigator.pop(context),
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
                    child: const Icon(Icons.arrow_back,
                        size: 20, color: Colors.black87),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _toggleSave,
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
                    child: Icon(
                      _isSaved
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 20,
                      color: _isSaved
                          ? const Color(0xFFE91E63)
                          : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      color: const Color(0xFFFFF0F3),
      child: Center(
        child: Text(
          g.initial,
          style: const TextStyle(
              fontSize: 100,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF3BDC3)),
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return StreamBuilder<List<Review>>(
      stream: ReviewService.streamForListing(g.docId),
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
                        'No reviews yet. Be the first to book a tour and share your experience!',
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
                    Text(g.priceLabel,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(g.priceSuffix,
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
                        builder: (_) => ContactGuideScreen(guide: g),
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
                        Text('Message guide',
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
                  child: Text('✓ ${g.cancellationPolicy} cancellation',
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
                      listingId: g.docId,
                      listingType: 'guide',
                      listingName: g.displayName.isNotEmpty
                          ? g.displayName
                          : g.fullName,
                      listingPhoto: g.coverPhoto,
                      hostId: g.userId,
                      hostName: g.displayName.isNotEmpty
                          ? g.displayName
                          : g.fullName,
                      pricePerNightOrDay: g.basePrice,
                      pricingSuffix: g.priceSuffix,
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
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  g.displayName.isNotEmpty
                                      ? g.displayName
                                      : g.fullName,
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Icon(Icons.verified_rounded,
                                  size: 20, color: Color(0xFFE91E63)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          StreamBuilder<List<Review>>(
                            stream: ReviewService.streamForListing(g.docId),
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
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          if (g.tagline.isNotEmpty)
                            Text(g.tagline,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black87)),
                          const SizedBox(height: 16),
                          const SizedBox(height: 16),
                          _buildBookedBanner(),
                          const Divider(height: 1, color: Colors.black12),
                          const SizedBox(height: 12),

                          _factRow(Icons.translate_rounded, 'Languages',
                              g.languages.join(', ')),
                          _factRow(Icons.timelapse_rounded, 'Experience',
                              '${g.yearsExperience} years'),
                          _factRow(Icons.place_outlined, 'Regions',
                              g.regionsCovered.join(', ')),
                          _factRow(Icons.group_outlined, 'Max group',
                              '${g.maxGroupSize} people'),
                          if (g.certifications.isNotEmpty)
                            _factRow(Icons.verified_user_rounded,
                                'Certifications',
                                g.certifications.join(', ')),

                          const SizedBox(height: 20),
                          if (g.bio.isNotEmpty) ...[
                            const Text('About',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(g.bio,
                                style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: Colors.black87)),
                            const SizedBox(height: 20),
                          ],

                          if (g.specialties.isNotEmpty) ...[
                            const Text('Specialties',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: g.specialties
                                  .map((s) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF0F3),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(s,
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

                          const Text('Tours offered',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          if (_isLoadingTours)
                            const Center(
                                child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                  color: Color(0xFFF3BDC3)),
                            ))
                          else if (_tours.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7FA),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                  'No specific tours listed yet. Contact the guide for a custom itinerary.',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54)),
                            )
                          else
                            ..._tours.map(_tourCard),

                          const SizedBox(height: 20),

                          if (g.meetingPoint.isNotEmpty)
                            _infoBlock(Icons.pin_drop_outlined,
                                'Meeting point', g.meetingPoint),
                          if (g.inclusions.isNotEmpty)
                            _infoBlock(
                                Icons.check_circle_outline_rounded,
                                "What's included",
                                g.inclusions),
                          if (g.exclusions.isNotEmpty)
                            _infoBlock(Icons.cancel_outlined,
                                'Not included', g.exclusions),
                          if (g.houseRules.isNotEmpty)
                            _infoBlock(Icons.rule_outlined,
                                'House rules', g.houseRules),
                          _infoBlock(Icons.event_busy_rounded,
                              'Cancellation policy', g.cancellationPolicy),

                          const SizedBox(height: 30),
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