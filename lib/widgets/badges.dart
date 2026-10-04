import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/auth/login_modal_sheet.dart';
import '../screens/chat/chats_list_screen.dart';

// ==========================================
// PENDING HOST BOOKINGS BADGE
// ==========================================
class PendingHostBookingsBadge extends StatelessWidget {
  final String hostId;
  final String? listingType;
  final Widget child;
  const PendingHostBookingsBadge({
    super.key,
    required this.hostId,
    this.listingType,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('hostId', isEqualTo: hostId)
          .snapshots(),
      builder: (context, snap) {
        var docs = snap.data?.docs ?? [];
        if (listingType != null) {
          docs = docs
              .where((d) => d.data()['listingType'] == listingType)
              .toList();
        }
        final count = docs
            .where((d) => d.data()['status'] == 'requested')
            .length;
        if (count == 0) return child;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
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
  }
}

// ==========================================
// CHAT ICON BUTTON (with unread badge)
// ==========================================
class ChatIconButton extends StatelessWidget {
  const ChatIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        final user = authSnap.data;

        if (user == null) {
          return IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.chat_bubble_outline_rounded,
                color: Colors.black, size: 26),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) =>
                  LoginModalSheet(onAuthSuccess: (n, e, p) {}),
            ),
          );
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('chat_threads')
              .where('participants', arrayContains: user.uid)
              .snapshots(),
          builder: (context, snap) {
            int total = 0;
            for (final d in snap.data?.docs ?? []) {
              final m = d.data()['unreadCounts'];
              if (m is Map) {
                final v = m[user.uid];
                if (v is num) total += v.toInt();
              }
            }
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.chat_bubble_outline_rounded,
                      color: Colors.black, size: 26),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ChatsListScreen()),
                  ),
                ),
                if (total > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        total > 9 ? '9+' : '$total',
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
    );
  }
}