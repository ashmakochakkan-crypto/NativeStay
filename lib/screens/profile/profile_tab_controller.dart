import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_screen.dart';
import 'profile_screen.dart';

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
            content: Text('Re-authentication failed: ${e.message ?? e.code}'),
          ),
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

    try {
      final snap = await db
          .collection('bookings')
          .where('travelerId', isEqualTo: user.uid)
          .get();
      final b = db.batch();
      for (final d in snap.docs) {
        b.delete(d.reference);
      }
      await b.commit();
    } catch (e) {
      debugPrint('Cleanup bookings failed: $e');
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
        final snap = await db
            .collection('users')
            .doc(user.uid)
            .collection(sub)
            .get();
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
    if (user != null) await user.updateDisplayName(newName);
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

        final displayName = user.displayName?.isNotEmpty == true
            ? user.displayName!
            : 'User';

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