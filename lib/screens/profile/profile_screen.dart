import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login_screen.dart';
import '../host/become_a_host_intro_screen.dart';
import '../host/host_dashboard_screen.dart';
import 'account_settings_screen.dart';
import '../settings/get_help_screen.dart';
import '../settings/legal_screen.dart';
import 'view_profile_screen.dart';

// ==========================================
// PROFILE TAB CONTROLLER
// ==========================================
class ProfileTabController extends StatelessWidget {
  final bool isGuestMode;
  final Map<String, String> profileData;
  final Map<String, String> personalData;
  final List<String> interests;
  final Function(Map<String, String>, List<String>)? onUpdateProfile;
  final Function(Map<String, String>)? onPersonalDataUpdated;
  final Function(String?, String?, String?)? onAuthSuccess;

  const ProfileTabController({
    super.key,
    this.isGuestMode = false,
    required this.profileData,
    required this.personalData,
    required this.interests,
    this.onUpdateProfile,
    this.onPersonalDataUpdated,
    this.onAuthSuccess,
  });

  Future<void> _handleDeactivateAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final email = user.email;
    if (email == null) return;

    final pwd = await _askForPassword(context);
    if (pwd == null) return;

    try {
      final cred = EmailAuthProvider.credential(email: email, password: pwd);
      await user.reauthenticateWithCredential(cred);
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Re-authentication failed: ${e.message ?? e.code}')),
        );
      }
      return;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Re-authentication failed: $e')),
        );
      }
      return;
    }

    final db = FirebaseFirestore.instance;

    try {
      final guideSnap = await db
          .collection('tour_guides')
          .where('userId', isEqualTo: user.uid)
          .get();
      for (final g in guideSnap.docs) {
        final toursSnap = await db
            .collection('tour_packages')
            .where('guideId', isEqualTo: g.id)
            .get();
        final b = db.batch();
        for (final t in toursSnap.docs) {
          b.delete(t.reference);
        }
        await b.commit();
      }
    } catch (e) {
      debugPrint('Cleanup tour_packages failed: $e');
    }

    for (final coll in const [
      'property_listings',
      'tour_guides',
      'vehicle_listings',
    ]) {
      try {
        final snap = await db
            .collection(coll)
            .where('userId', isEqualTo: user.uid)
            .get();
        final b = db.batch();
        for (final d in snap.docs) {
          b.delete(d.reference);
        }
        await b.commit();
      } catch (e) {
        debugPrint('Cleanup $coll failed: $e');
      }
    }

    for (final field in const ['travelerId']) {
      try {
        final snap = await db
            .collection('bookings')
            .where(field, isEqualTo: user.uid)
            .get();
        final b = db.batch();
        for (final d in snap.docs) {
          b.delete(d.reference);
        }
        await b.commit();
      } catch (e) {
        debugPrint('Cleanup bookings ($field) failed: $e');
      }
    }

    try {
      final snap = await db
          .collection('reviews')
          .where('reviewerId', isEqualTo: user.uid)
          .get();
      final b = db.batch();
      for (final d in snap.docs) {
        b.delete(d.reference);
      }
      await b.commit();
    } catch (e) {
      debugPrint('Cleanup reviews failed: $e');
    }

    try {
      final snap = await db
          .collection('chat_threads')
          .where('participants', arrayContains: user.uid)
          .get();
      for (final d in snap.docs) {
        try {
          final msgs = await d.reference.collection('messages').get();
          final b = db.batch();
          for (final m in msgs.docs) {
            b.delete(m.reference);
          }
          await b.commit();
        } catch (_) {}
        await d.reference.delete();
      }
    } catch (e) {
      debugPrint('Cleanup chat_threads failed: $e');
    }

    for (final sub in const [
      'notifications',
      'wishlist',
      'vehicle_wishlist',
      'guide_wishlist',
    ]) {
      try {
        final snap =
            await db.collection('users').doc(user.uid).collection(sub).get();
        final b = db.batch();
        for (final d in snap.docs) {
          b.delete(d.reference);
        }
        await b.commit();
      } catch (e) {
        debugPrint('Cleanup $sub failed: $e');
      }
    }

    try {
      await db.collection('users').doc(user.uid).delete();
    } catch (e) {
      debugPrint('User doc delete failed: $e');
    }

    try {
      await user.delete();
    } catch (e) {
      debugPrint('Auth delete failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account delete failed: $e')),
        );
      }
      return;
    }
    await FirebaseAuth.instance.signOut();
  }

  Future<String?> _askForPassword(BuildContext context) async {
    final ctrl = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirm your password'),
          content: TextField(
            controller: ctrl,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Password'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    } finally {
      ctrl.dispose();
    }
  }

  void _onLogout() async {
    await FirebaseAuth.instance.signOut();
  }

  void _onNameUpdated(String newName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updateDisplayName(newName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (isGuestMode || user == null) {
          return LoginScreen(
            onLoginSuccess: onAuthSuccess ?? (name, email, phone) {},
          );
        }

        final displayName =
            user.displayName?.isNotEmpty == true ? user.displayName! : 'User';

        return ProfileScreen(
          firstName: displayName,
          userEmail: user.email ?? '',
          userPhone: user.phoneNumber ?? '',
          profileData: profileData,
          personalData: personalData,
          interests: interests,
          onLogout: _onLogout,
          onNameUpdated: _onNameUpdated,
          onUpdateProfile: onUpdateProfile,
          onPersonalDataUpdated: onPersonalDataUpdated,
          onDeactivateAccount: () => _handleDeactivateAccount(context),
        );
      },
    );
  }
}

// ==========================================
// PROFILE SCREEN
// ==========================================
class ProfileScreen extends StatelessWidget {
  final String? firstName;
  final String userEmail;
  final String userPhone;
  final Map<String, String> profileData;
  final Map<String, String> personalData;
  final List<String> interests;
  final VoidCallback? onLogout;
  final Function(String)? onNameUpdated;
  final Function(Map<String, String>, List<String>)? onUpdateProfile;
  final Function(Map<String, String>)? onPersonalDataUpdated;
  final Future<void> Function()? onDeactivateAccount;

  const ProfileScreen({
    super.key,
    this.firstName,
    required this.userEmail,
    required this.userPhone,
    required this.profileData,
    required this.personalData,
    required this.interests,
    this.onLogout,
    this.onNameUpdated,
    this.onUpdateProfile,
    this.onPersonalDataUpdated,
    this.onDeactivateAccount,
  });

  Widget _buildListTile(BuildContext context, IconData icon, String title,
      Widget destinationScreen) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black, size: 22),
      title: Text(title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 16, color: Colors.black38),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationScreen),
        );
      },
    );
  }

  void _navigateToBecomeAHost(BuildContext context, String displayName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final querySnap = await FirebaseFirestore.instance
            .collection('property_listings')
            .where('userId', isEqualTo: user.uid)
            .get();

        if (querySnap.docs.isNotEmpty && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HostDashboardScreen(
                userName: displayName,
                listingDate: querySnap.docs.first.data()['listingStartedDate'] ??
                    'September 20, 2026',
              ),
            ),
          );
          return;
        }
      } catch (e) {
        debugPrint("Error checking host listing status: $e");
      }
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BecomeAHostIntroScreen(userName: displayName)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayName =
        (firstName != null && firstName!.trim().isNotEmpty)
            ? firstName!.trim()
            : 'User';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Profile',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.3)),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewProfileScreen(
                        firstName: displayName,
                        profileData: profileData,
                        interests: interests,
                        onUpdateProfile: onUpdateProfile,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3BDC3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Center(
                          child: Text(
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(displayName,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () => _navigateToBecomeAHost(context, displayName),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                      const Icon(Icons.home_work_outlined,
                          color: Colors.black, size: 24),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Become a host',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            SizedBox(height: 2),
                            Text(
                                'It\'s easy to start hosting and earn extra income.',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _buildListTile(
                context,
                Icons.person_outline_rounded,
                'View profile',
                ViewProfileScreen(
                  firstName: displayName,
                  profileData: profileData,
                  interests: interests,
                  onUpdateProfile: onUpdateProfile,
                ),
              ),
              const Divider(height: 1, color: Colors.black12),

              _buildListTile(
                context,
                Icons.settings_outlined,
                'Account settings',
                AccountSettingsScreen(
                  currentLegalName: displayName,
                  userEmail: userEmail,
                  userPhone: personalData['phone']?.isNotEmpty == true
                      ? personalData['phone']!
                      : userPhone,
                  personalData: personalData,
                  onNameUpdated: onNameUpdated ?? (val) {},
                  onPersonalDataUpdated: onPersonalDataUpdated ?? (val) {},
                  onDeactivateAccount: onDeactivateAccount ?? () async {},
                ),
              ),
              const Divider(height: 1, color: Colors.black12),

              _buildListTile(context, Icons.help_outline_rounded, 'Get help',
                  const GetHelpScreen()),
              const Divider(height: 1, color: Colors.black12),

              _buildListTile(context, Icons.menu_book_outlined, 'Legal',
                  const LegalScreen()),
              const Divider(height: 1, color: Colors.black12),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.exit_to_app_rounded,
                    color: Colors.black, size: 22),
                title: const Text('Log out',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black)),
                onTap: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Do you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('No',
                              style: TextStyle(color: Colors.black54)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3BDC3),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Yes',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true) {
                    if (!context.mounted) return;
                    if (onLogout != null) {
                      onLogout!();
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}