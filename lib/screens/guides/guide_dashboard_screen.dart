import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/tour_guide.dart';
import '../../services/tour_guides_service.dart';
import '../../widgets/badges.dart';
import '../booking/host_bookings_screen.dart';
import 'guide_tours_management_screen.dart';
import 'guide_wizard_step1_screen.dart';

class GuideDashboardScreen extends StatefulWidget {
  const GuideDashboardScreen({super.key});

  @override
  State<GuideDashboardScreen> createState() => _GuideDashboardScreenState();
}

class _GuideDashboardScreenState extends State<GuideDashboardScreen> {
  bool _isLoading = true;
  TourGuide? _guide;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final g = await TourGuidesService.fetchUserGuideProfile(user.uid);
      if (mounted) {
        setState(() {
          _guide = g;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDelete() async {
    if (_guide == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete your guide profile?'),
        content: const Text(
          'Warning: Your guide profile will be permanently deleted from everywhere — travelers will no longer find you.\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    try {
      setState(() => _isLoading = true);

      await FirebaseFirestore.instance
          .collection('listing_blocks')
          .doc(_guide!.docId)
          .delete()
          .catchError((_) {});

      await FirebaseFirestore.instance
          .collection('tour_guides')
          .doc(_guide!.docId)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Guide profile deleted successfully')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      debugPrint('Delete guide error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('Exit',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF3BDC3)))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Guide Dashboard',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),

                    if (_guide != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFF0F3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _guide!.initial,
                                      style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFF3BDC3)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(_guide!.displayName,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight:
                                                  FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      Text(_guide!.tagline,
                                          maxLines: 2,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.green, size: 18),
                                const SizedBox(width: 6),
                                const Text('Published & Live',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green)),
                                const Spacer(),
                                GestureDetector(
                                  onTap: _confirmDelete,
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 32),

                    const Text('Manage',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.edit_note_rounded,
                          color: Colors.black, size: 24),
                      title: const Text('Edit your guide profile',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.black45),
                      onTap: () {
                        if (_guide == null) return;
                        final data = GuideProfileData.fromGuide(_guide!);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GuideWizardStep1Screen(
                                existingData: data),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, color: Colors.black12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.tour_rounded,
                          color: Colors.black, size: 24),
                      title: const Text('Manage tour packages',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.black45),
                      onTap: () {
                        if (_guide == null) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                GuideToursManagementScreen(guide: _guide!),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, color: Colors.black12),
                    StreamBuilder<User?>(
                      stream: FirebaseAuth.instance.authStateChanges(),
                      builder: (context, snap) {
                        final uid = snap.data?.uid ?? '';
                        final tile = ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.receipt_long_rounded,
                              color: Colors.black, size: 24),
                          title: const Text('Manage guide bookings',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          subtitle: const Text(
                              'Confirm or decline tour reservations',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54)),
                          trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Colors.black45),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HostBookingsScreen(
                                    listingType: 'guide',
                                    title: 'Guide bookings'),
                              ),
                            );
                          },
                        );
                        if (uid.isEmpty) return tile;
                        return PendingHostBookingsBadge(
                            hostId: uid, listingType: 'guide', child: tile);
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}