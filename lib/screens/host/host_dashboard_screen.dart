import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/badges.dart';
import '../booking/host_bookings_screen.dart';
import '../settings/help_center_screen.dart';
import 'edit_existing_listing_screen.dart';
import 'host_wizard_step1_screen.dart';
import 'quick_availability_edit_screen.dart';

class HostDashboardScreen extends StatelessWidget {
  final String userName;
  final String listingDate;

  const HostDashboardScreen({
    super.key,
    required this.userName,
    required this.listingDate,
  });

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HelpCenterScreen()),
                );
              },
              child: const Text('Questions?',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $userName',
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 20),
              const Text(
                'Finish your listing',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.black12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 190,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F3),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.home_work_rounded,
                          size: 80,
                          color: Color(0xFFF3BDC3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      listingDate == '—'
                          ? 'Manage your listings below'
                          : 'Your listing started $listingDate',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Bookings',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 12),
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snap) {
                  final uid = snap.data?.uid ?? '';
                  final tile = ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.receipt_long_rounded,
                        color: Colors.black, size: 24),
                    title: const Text('Manage booking requests',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    subtitle: const Text(
                        'Confirm, decline, or complete reservations',
                        style: TextStyle(
                            fontSize: 12, color: Colors.black54)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: Colors.black45),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HostBookingsScreen(
                              listingType: 'homestay',
                              title: 'Homestay bookings'),
                        ),
                      );
                    },
                  );
                  if (uid.isEmpty) return tile;
                  return PendingHostBookingsBadge(
                      hostId: uid, listingType: 'homestay', child: tile);
                },
              ),
              const Divider(height: 1, color: Colors.black12),
              const SizedBox(height: 24),

              const Text(
                'Start a new listing',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 12),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.add_home_outlined,
                    color: Colors.black, size: 24),
                title: const Text('Create a new listing',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: Colors.black45),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HostWizardStep1Screen(userName: userName)),
                  );
                },
              ),
              const Divider(height: 1, color: Colors.black12),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.edit_note_rounded,
                    color: Colors.black, size: 24),
                title: const Text('Edit existing listing',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: Colors.black45),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const EditExistingListingScreen()),
                  );
                },
              ),
              const Divider(height: 1, color: Colors.black12),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_available_rounded,
                    color: Colors.black, size: 24),
                title: const Text('Edit availability only',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                subtitle: const Text(
                    'Quickly update when guests can book',
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: Colors.black45),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const QuickAvailabilityEditScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}