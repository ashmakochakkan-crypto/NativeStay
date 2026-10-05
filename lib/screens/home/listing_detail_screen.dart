import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../models/home_listing.dart';
import '../../models/review.dart';
import '../../services/booking_service.dart';
import '../../services/review_service.dart';
import '../../services/wishlist_service.dart';
import '../../widgets/common_tiles.dart';
import '../booking/booking_sheet.dart';
import '../chat/contact_host_screen.dart';
import 'cancellation_policy_screen.dart';       
import 'house_rules_detail_screen.dart';        
import 'safety_detail_screen.dart';            

// ==========================================
// LISTING DETAIL SCREEN
// ==========================================
class ListingDetailScreen extends StatefulWidget {
  final HomeListing listing;
  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  final PageController _photoController = PageController();
  int _currentPhoto = 0;
  bool _isSaved = false;

  HomeListing get l => widget.listing;

  @override
  void initState() {
    super.initState();
    _loadSavedState();
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
      final saved = await WishlistService.isSaved(user.uid, l.docId);
      if (mounted) setState(() => _isSaved = saved);
    } catch (e) {
      debugPrint('Wishlist load error: $e');
    }
  }

  Future<void> _toggleSave() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log in to save to your wishlist')),
      );
      return;
    }

    final wasSaved = _isSaved;
    setState(() => _isSaved = !wasSaved);

    try {
      if (wasSaved) {
        await WishlistService.remove(user.uid, l.docId);
      } else {
        await WishlistService.add(user.uid, l);
      }
    } catch (e) {
      debugPrint('Wishlist toggle error: $e');
      if (mounted) setState(() => _isSaved = wasSaved);
    }
  }

  void _openHostProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HostProfileSheet(listing: l),
    );
  }

  void _openReportSheet() {
    final reasons = [
      'Inaccurate listing details',
      "Photos don't match the property",
      'Property is not as described',
      'Safety concern',
      'Fraud or scam',
      'Offensive or inappropriate content',
      'Host is unresponsive',
      'Other',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Report this listing',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'What would you like to report?',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: reasons.length,
                  separatorBuilder: (_, i) =>
                      const Divider(height: 1, color: Colors.black12),
                  itemBuilder: (_, i) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        reasons[i],
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          size: 20, color: Colors.black38),
                      onTap: () {
                        Navigator.pop(ctx);
                        _submitReport(reasons[i]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitReport(String reason) async {
    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'listingId': l.docId,
        'listingName': l.stayName,
        'reportedUserId': l.userId,
        'reportedBy': FirebaseAuth.instance.currentUser?.uid ?? 'guest',
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Report error: $e');
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Report submitted. Thanks for keeping the community safe.'),
      ),
    );
  }

  Widget _buildPhotoArea() {
    final photos = l.photos;
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
              itemBuilder: (context, i) {
                return Image.network(
                  photos[i],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _photoPlaceholder(),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: const Color(0xFFFFF0F3),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFF3BDC3),
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                );
              },
            )
          else
            _photoPlaceholder(),

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
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          Positioned(
            left: 16,
            top: 16,
            right: 16,
            child: Row(
              children: [
                _circleIconButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
                const Spacer(),
                _circleIconButton(
                  icon: Icons.ios_share_rounded,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sharing coming soon')),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _circleIconButton(
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

  Widget _photoPlaceholder() {
    return Container(
      color: const Color(0xFFFFF0F3),
      child: const Center(
        child: Icon(Icons.home_work_rounded,
            size: 80, color: Color(0xFFF3BDC3)),
      ),
    );
  }

  Widget _circleIconButton({
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
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }

  Widget _buildHostedByRow() {
    return GestureDetector(
      onTap: _openHostProfile,
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
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFFFCE4EC),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  l.hostInitial,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hosted by ${l.hostName}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'New host',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.black54, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildFactsRow() {
    final facts = <String>[];
    facts.add(l.stayType);
    if (l.nearestAttraction.isNotEmpty) {
      facts.add('Near ${l.nearestAttraction}');
    }
    return Text(
      facts.join(' · '),
      style: const TextStyle(fontSize: 13, color: Colors.black54),
    );
  }

  Widget _buildRatingStrip() {
    return StreamBuilder<List<Review>>(
      stream: ReviewService.streamForListing(l.docId),
      builder: (context, snap) {
        final reviews = snap.data ?? [];
        final stats = ReviewService.stats(reviews);
        final double avg = stats['average'] as double;
        final int count = stats['count'] as int;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    count == 0 ? 'New' : avg.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 2),
                  StarRow(rating: avg, size: 14),
                  const SizedBox(height: 4),
                  Text(
                    count == 0
                        ? 'No reviews yet'
                        : '$count review${count > 1 ? 's' : ''}',
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 50, color: Colors.black12),
            Expanded(
              child: Column(
                children: [
                  Opacity(
                    opacity: count >= 5 ? 1.0 : 0.3,
                    child: const Icon(Icons.emoji_events_rounded,
                        size: 30, color: Color(0xFFE91E63)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count >= 5 ? 'Guest favorite' : 'Getting there',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color:
                            count >= 5 ? Colors.black87 : Colors.black38),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 50, color: Colors.black12),
            Expanded(
              child: Column(
                children: [
                  if (count == 0)
                    const Icon(Icons.rate_review_outlined,
                        size: 26, color: Colors.black26)
                  else
                    Text(
                      '${avg.toStringAsFixed(1)}/5',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    count == 0 ? 'Be the first' : 'Average rating',
                    style: const TextStyle(
                        fontSize: 10, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAmenitiesSection() {
    if (l.amenities.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What this place offers',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 14),
        ...l.amenities.map((name) {
          final icon = _amenityIcon(name);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Icon(icon, size: 22, color: Colors.black87),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  IconData _amenityIcon(String name) {
    for (final a in kAllAmenities) {
      if (a.label == name) return a.icon;
    }
    return Icons.check_circle_outline_rounded;
  }

  Widget _buildMeetHostCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFCE4EC),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        l.hostInitial,
                        style: const TextStyle(
                          fontSize: 30,
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
                          color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              StreamBuilder<List<Review>>(
                stream: ReviewService.streamForHost(l.userId),
                builder: (context, snap) {
                  final reviews = snap.data ?? [];
                  final stats = ReviewService.stats(reviews);
                  final double avg = stats['average'] as double;
                  final int count = stats['count'] as int;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$count',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const SizedBox(height: 2),
                      const Text('Reviews',
                          style: TextStyle(
                              fontSize: 11, color: Colors.black54)),
                      const SizedBox(height: 10),
                      Text(
                          count == 0 ? 'New' : avg.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const SizedBox(height: 2),
                      const Text('Rating',
                          style: TextStyle(
                              fontSize: 11, color: Colors.black54)),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            l.hostName,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
          const SizedBox(height: 2),
          const Text('Host',
              style: TextStyle(fontSize: 12, color: Colors.black54)),
          if (l.hostBio.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              l.hostBio,
              style: const TextStyle(
                  fontSize: 13, color: Colors.black87, height: 1.4),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black12),
                backgroundColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactHostScreen(listing: l),
                  ),
                );
              },
              child: const Text(
                'Message host',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return StreamBuilder<List<Review>>(
      stream: ReviewService.streamForListing(l.docId),
      builder: (context, snap) {
        final reviews = snap.data ?? [];
        if (reviews.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Reviews',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
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
                        'No reviews yet. Be the first to stay and share your experience!',
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

        final stats = ReviewService.stats(reviews);
        final double avg = stats['average'] as double;
        final int count = stats['count'] as int;

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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
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
                                child: Text(
                                  r.initial,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE91E63)),
                                ),
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

  Widget _buildHouseholdSection() {
    final l = widget.listing;

    final rows = <Map<String, dynamic>>[];

    if (l.liveWithHost == 'Yes') {
      rows.add({
        'icon': Icons.home_outlined,
        'title': 'Host lives on property',
        'body': 'The host or family lives here during your stay.',
      });
    }
    if (l.shareProperty == 'Yes') {
      rows.add({
        'icon': Icons.people_outline_rounded,
        'title': 'Shared with host family',
        'body': 'You may share some common areas with the family.',
      });
    }
    if (l.haveRoommates == 'Yes') {
      final count = l.otherPeopleCount;
      rows.add({
        'icon': Icons.group_outlined,
        'title': 'Other guests present',
        'body': count != '0' && count.isNotEmpty
            ? '$count other people stay here too.'
            : 'Other guests or roommates are present.',
      });
    }
    if (l.sharedAreas.isNotEmpty && l.sharedAreas != 'None') {
      rows.add({
        'icon': Icons.meeting_room_outlined,
        'title': 'Shared areas',
        'body': l.sharedAreas,
      });
    }
    if (l.familyCount != '0' && l.familyCount.isNotEmpty) {
      final rel = l.familyRelation;
      rows.add({
        'icon': Icons.family_restroom_rounded,
        'title': 'Household',
        'body': rel.isNotEmpty && rel != 'None'
            ? '${l.familyCount} family members ($rel) live here.'
            : '${l.familyCount} family members live here.',
      });
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Household & sharing',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        const SizedBox(height: 14),
        ...rows.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(r['icon'] as IconData,
                      size: 22, color: Colors.black87),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r['title'] as String,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        const SizedBox(height: 3),
                        Text(r['body'] as String,
                            style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildExperienceSection() {
    final l = widget.listing;

    final chips = <Map<String, dynamic>>[];
    if (l.culturalExperience == 'Yes') {
      chips.add(
          {'icon': Icons.temple_hindu_rounded, 'label': 'Cultural experience'});
    }
    if (l.homeCookedFood == 'Yes') {
      chips.add(
          {'icon': Icons.restaurant_rounded, 'label': 'Home-cooked meals'});
    }
    if (l.localGuide == 'Yes') {
      chips.add({
        'icon': Icons.person_search_rounded,
        'label': 'Local guide available'
      });
    }

    final hasActivities = l.activitiesOffered.trim().isNotEmpty;
    final hasVehicle = l.vehicleAvailable == 'Yes';
    final hasAnything = chips.isNotEmpty || hasActivities || hasVehicle;

    if (!hasAnything) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Local experience',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        const SizedBox(height: 14),

        if (chips.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map((c) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF3BDC3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(c['icon'] as IconData,
                              size: 16, color: const Color(0xFFE91E63)),
                          const SizedBox(width: 6),
                          Text(c['label'] as String,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black)),
                        ],
                      ),
                    ))
                .toList(),
          ),

        if (hasActivities) ...[
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.hiking_rounded,
                  size: 22, color: Colors.black87),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Activities offered',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    const SizedBox(height: 3),
                    Text(l.activitiesOffered,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            height: 1.4)),
                    if (l.expPrice.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('From ₹${l.expPrice}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE91E63))),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],

        if (hasVehicle) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7FA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFCE4EC)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.directions_car_rounded,
                    size: 22, color: Color(0xFFE91E63)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Vehicle available',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const SizedBox(height: 4),
                      if (l.vehicleType.isNotEmpty)
                        Text('Type: ${l.vehicleType}',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black87)),
                      if (l.driverOption.isNotEmpty)
                        Text('Driver: ${l.driverOption}',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black87)),
                      if (l.vehiclePrice.isNotEmpty)
                        Text('₹${l.vehiclePrice}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE91E63))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildThingsToKnow() {
    final houseRuleLines = <String>[
      'Check-in after ${l.checkIn}',
      'Checkout before ${l.checkOut}',
      if (l.smoking == 'Not Allowed') 'No smoking',
      if (l.petsAllowed == 'Allowed') 'Pets allowed',
      if (l.parties == 'Not Allowed') 'No parties or events',
      if (l.visitorsAllowed == 'No') 'No visitors',
      if (l.childrenAllowed == 'Not Allowed') 'Not suitable for children',
      'Quiet hours ${l.quietHours}',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Things to know',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        const SizedBox(height: 16),
        _knowRow(
          icon: Icons.event_busy_rounded,
          title: 'Cancellation policy',
          lines: [
            'Host selected: ${l.cancellationPolicy}',
            if (l.cancellationPolicy == 'Flexible')
              'Full refund up to 24 hours before check-in.'
            else if (l.cancellationPolicy == 'Moderate')
              'Full refund up to 5 days before check-in.'
            else
              'No refunds after booking.',
            'Tap for full policy.',
          ],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CancellationPolicyScreen(listing: l),
              ),
            );
          },
        ),
        _knowRow(
          icon: Icons.vpn_key_rounded,
          title: 'House rules',
          lines: houseRuleLines,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HouseRulesDetailScreen(listing: l),
              ),
            );
          },
        ),
        if (l.safetyFeatures.isNotEmpty ||
            l.smokeDetector == 'Yes' ||
            l.emergencyExit == 'Yes' ||
            l.doorLock == 'Yes' ||
            l.nearestHospital.isNotEmpty ||
            l.safetyInstructions.isNotEmpty)
          _knowRow(
            icon: Icons.shield_outlined,
            title: 'Safety & property',
            lines: [
              ...l.safetyFeatures,
              if (l.smokeDetector == 'Yes') 'Smoke detector installed',
              if (l.emergencyExit == 'Yes') 'Emergency exit available',
              if (l.doorLock == 'Yes') 'Door lock on private space',
              if (l.nearestHospital.isNotEmpty)
                'Nearest hospital: ${l.nearestHospital}',
            ],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SafetyDetailScreen(listing: l),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildBookedBanner() {
    return StreamBuilder<List<Booking>>(
      stream: BookingService.streamConfirmedForListing(l.docId),
      builder: (context, snap) {
        final list = snap.data ?? [];
        final now = DateTime.now();
        final active = list.where((b) =>
            b.checkOut == null ||
            b.checkOut!.isAfter(now.subtract(const Duration(days: 1)))).toList();
        if (active.isEmpty) return const SizedBox.shrink();
        final first = active.first;
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F3),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF3BDC3), width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_clock_rounded, color: Color(0xFFE91E63)),
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

  Widget _buildAvailabilitySection() {
    final periods = l.availabilityPeriods;

    if (periods.isEmpty) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final upcoming = periods.where((p) => !p.end.isBefore(now)).toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    final firstLabel = upcoming.isNotEmpty
        ? upcoming.first.label
        : periods.first.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _openAvailabilityCalendar,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF0F3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.event_available_rounded,
                      color: Color(0xFFF3BDC3), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Availability',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        upcoming.isNotEmpty
                            ? 'Next available: $firstLabel'
                            : 'Last window: $firstLabel',
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Colors.black38, size: 22),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openAvailabilityCalendar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AvailabilityCalendarSheet(
        periods: l.availabilityPeriods,
        listingId: l.docId,
      ),
    );
  }

  Widget _knowRow({
    required IconData icon,
    required String title,
    required List<String> lines,
    VoidCallback? onTap,
  }) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 4),
                ...lines.map((line) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(line,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              height: 1.4)),
                    )),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right_rounded,
                color: Colors.black38, size: 20),
        ],
      ),
    );

    if (onTap == null) return row;
    return GestureDetector(onTap: onTap, child: row);
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Colors.black12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
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
                    Text(
                      l.priceLabel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      ' / night',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '✓ ${l.cancellationPolicy} cancellation',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
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
                      listingId: l.docId,
                      listingType: 'homestay',
                      listingName: l.stayName,
                      listingPhoto: l.coverPhoto,
                      hostId: l.userId,
                      hostName: l.hostName,
                      pricePerNightOrDay: l.pricePerNight,
                      pricingSuffix: ' / night',
                    ),
                  );
                },
                child: const Text(
                  'Reserve',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
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
                            l.stayName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.locationLabel,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black54),
                          ),
                          const SizedBox(height: 4),
                          _buildFactsRow(),
                          const SizedBox(height: 12),
                          _buildBookedBanner(),
                          const SizedBox(height: 18),
                          _buildRatingStrip(),
                          const SizedBox(height: 18),
                          _buildHostedByRow(),
                          const SizedBox(height: 18),
                          if (l.nearestAttraction.isNotEmpty)
                            Row(children: [
                              const Icon(Icons.place_outlined,
                                  size: 16, color: Colors.black54),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text('Near ${l.nearestAttraction}',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54)),
                              ),
                            ]),
                          const SizedBox(height: 24),
                          if (l.shortDescription.isNotEmpty) ...[
                            Text(
                              l.shortDescription,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.5),
                            ),
                            const SizedBox(height: 24),
                          ],
                          _buildAvailabilitySection(),
                          const SizedBox(height: 24),
                          _buildAmenitiesSection(),
                          const SizedBox(height: 24),
                          _buildExperienceSection(),
                          const SizedBox(height: 24),
                          _buildHouseholdSection(),
                          const SizedBox(height: 24),
                          _buildMeetHostCard(),
                          const SizedBox(height: 24),
                          _buildReviewsSection(),
                          const SizedBox(height: 24),
                          _buildThingsToKnow(),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _openReportSheet,
                            child: const Text(
                              'Report this listing',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
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

// ==========================================
// HOST PROFILE SHEET
// ==========================================
class HostProfileSheet extends StatelessWidget {
  final HomeListing listing;
  const HostProfileSheet({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Meet your host',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 20),
            StreamBuilder<List<Review>>(
              stream: ReviewService.streamForHost(listing.userId),
              builder: (context, snap) {
                final reviews = snap.data ?? [];
                final stats = ReviewService.stats(reviews);
                final double avg = stats['average'] as double;
                final int count = stats['count'] as int;

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFCE4EC),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    listing.hostInitial,
                                    style: const TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE91E63),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 2,
                                bottom: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE91E63),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.verified_rounded,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(listing.hostName,
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                                const Text('Host',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('$count',
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)),
                                          const Text('Reviews',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.black54)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              count == 0
                                                  ? 'New'
                                                  : avg.toStringAsFixed(1),
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)),
                                          const Text('Rating',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.black54)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              listing.submittedAt == null
                                                  ? 'New'
                                                  : '${listing.submittedAt!.year}',
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)),
                                          const Text('Listed since',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.black54)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (listing.hostBio.isNotEmpty) ...[
                        Text(listing.hostBio,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.5)),
                        const SizedBox(height: 14),
                      ],
                      if (reviews.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Divider(height: 1, color: Colors.black12),
                        const SizedBox(height: 16),
                        const Text('Reviews',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        const SizedBox(height: 12),
                        ...reviews.take(4).map((r) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(r.reviewerName,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        StarRow(
                                            rating: r.rating.toDouble(),
                                            size: 14),
                                        const SizedBox(height: 4),
                                        Text(
                                            r.text.isEmpty
                                                ? '⭐ ${r.rating}/5'
                                                : r.text,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black87,
                                                height: 1.4)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  side: const BorderSide(color: Colors.black12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ContactHostScreen(listing: listing),
                    ),
                  );
                },
                child: const Text('Message host',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// AVAILABILITY CALENDAR SHEET
// ==========================================
class _AvailabilityCalendarSheet extends StatefulWidget {
  final List<AvailabilityPeriod> periods; // Fixed type
  final String listingId;
  const _AvailabilityCalendarSheet({
    required this.periods,
    required this.listingId,
  });

  @override
  State<_AvailabilityCalendarSheet> createState() =>
      _AvailabilityCalendarSheetState();
}

class _AvailabilityCalendarSheetState
    extends State<_AvailabilityCalendarSheet> {
  late DateTime _month;
  List<({DateTime start, DateTime end})> _blocked = [];
  bool _loadingBookings = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('listing_blocks')
          .doc(widget.listingId)
          .get();
      final raw = (snap.data()?['blocks'] as List?) ?? [];
      final list = <({DateTime start, DateTime end})>[];
      for (final b in raw) {
        final m = Map<String, dynamic>.from(b as Map);
        final s = (m['checkIn'] as Timestamp?)?.toDate();
        final e = (m['checkOut'] as Timestamp?)?.toDate();
        if (s != null && e != null) list.add((start: s, end: e));
      }
      if (!mounted) return;
      setState(() {
        _blocked = list;
        _loadingBookings = false;
      });
    } catch (e) {
      debugPrint('Load blocked dates error: $e');
      if (mounted) setState(() => _loadingBookings = false);
    }
  }

  bool _isBooked(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    for (final b in _blocked) {
      final s = DateTime(b.start.year, b.start.month, b.start.day);
      final e = DateTime(b.end.year, b.end.month, b.end.day);
      if (!d.isBefore(s) && d.isBefore(e)) return true;
    }
    return false;
  }

  bool _isAvailable(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    for (final p in widget.periods) {
      final s = DateTime(p.start.year, p.start.month, p.start.day);
      final e = DateTime(p.end.year, p.end.month, p.end.day);
      if (!d.isBefore(s) && !d.isAfter(e)) return true;
    }
    return false;
  }

  void _prevMonth() =>
      setState(() => _month = DateTime(_month.year, _month.month - 1, 1));
  void _nextMonth() =>
      setState(() => _month = DateTime(_month.year, _month.month + 1, 1));

  @override
  Widget build(BuildContext context) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final firstDay = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Availability',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              _loadingBookings
                  ? 'Loading booked dates...'
                  : '${widget.periods.length} window${widget.periods.length == 1 ? '' : 's'} · ${_blocked.length} booked',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: _prevMonth,
                    icon: const Icon(Icons.chevron_left_rounded)),
                Text('${months[_month.month - 1]} ${_month.year}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                    onPressed: _nextMonth,
                    icon: const Icon(Icons.chevron_right_rounded)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(d,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemCount: startWeekday + daysInMonth,
              itemBuilder: (context, index) {
                if (index < startWeekday) return const SizedBox.shrink();
                final day = index - startWeekday + 1;
                final date = DateTime(_month.year, _month.month, day);
                final booked = _isBooked(date);
                final available = !booked && _isAvailable(date);
                return Container(
                  decoration: BoxDecoration(
                    color: booked
                        ? const Color(0xFFE91E63)
                        : (available
                            ? const Color(0xFFF3BDC3)
                            : Colors.white),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: booked
                          ? const Color(0xFFE91E63)
                          : (available
                              ? const Color(0xFFF3BDC3)
                              : Colors.black12),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: (available || booked)
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: booked
                            ? Colors.white
                            : (available ? Colors.black : Colors.black54),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                        color: Color(0xFFF3BDC3), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text('Available',
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(width: 16),
                Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                        color: Color(0xFFE91E63), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text('Booked',
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(width: 16),
                Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12))),
                const SizedBox(width: 6),
                const Text('Blocked',
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// CORRECTED PLACEHOLDERS AT BOTTOM
// ==========================================

class Amenity {
  final String label;
  final IconData icon;
  const Amenity({required this.label, required this.icon});
}

const List<Amenity> kAllAmenities = [
  Amenity(label: 'Wi-Fi', icon: Icons.wifi),
  Amenity(label: 'Kitchen', icon: Icons.kitchen),
  Amenity(label: 'Free Parking', icon: Icons.local_parking),
  Amenity(label: 'Pool', icon: Icons.pool),
  Amenity(label: 'AC', icon: Icons.ac_unit),
  Amenity(label: 'TV', icon: Icons.tv),
  Amenity(label: 'Washing Machine', icon: Icons.local_laundry_service),
];

class CancellationPolicyScreen extends StatelessWidget {
  final HomeListing listing; // Added this
  const CancellationPolicyScreen({super.key, required this.listing}); // Added required this.listing

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cancellation Policy')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Cancellation policy for ${listing.stayName} goes here.'),
      ),
    );
  }
}

class HouseRulesDetailScreen extends StatelessWidget {
  final HomeListing listing; // Added this
  const HouseRulesDetailScreen({super.key, required this.listing}); // Added required this.listing

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('House Rules')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('House rules for ${listing.stayName} go here.'),
      ),
    );
  }
}