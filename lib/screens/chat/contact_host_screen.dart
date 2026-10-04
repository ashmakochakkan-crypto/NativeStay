import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/chat.dart';
import '../../models/home_listing.dart';
import '../../services/chat_service.dart';
import 'chat_room_screen.dart';

class ContactHostScreen extends StatefulWidget {
  final HomeListing listing;
  const ContactHostScreen({super.key, required this.listing});

  @override
  State<ContactHostScreen> createState() => _ContactHostScreenState();
}

class _ContactHostScreenState extends State<ContactHostScreen> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    final me = FirebaseAuth.instance.currentUser;
    if (me == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'login';
        });
      }
      return;
    }
    if (widget.listing.userId == me.uid) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'owner';
        });
      }
      return;
    }

    String myName = me.displayName ?? 'Me';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(me.uid)
          .get();
      final d = doc.data() ?? {};
      final full =
          '${(d['firstName'] ?? '').toString().trim()} ${(d['lastName'] ?? '').toString().trim()}'
              .trim();
      if (full.isNotEmpty) myName = full;
    } catch (_) {}

    try {
      final tid = await ChatService.ensureThread(
        listingId: widget.listing.docId,
        listingType: 'homestay',
        listingName: widget.listing.stayName,
        listingPhoto: widget.listing.coverPhoto,
        myUid: me.uid,
        myName: myName,
        otherUid: widget.listing.userId,
        otherName: widget.listing.hostName,
        hostUid: widget.listing.userId,
      );
      if (!mounted) return;
      final snap = await FirebaseFirestore.instance
          .collection('chat_threads')
          .doc(tid)
          .get();
      if (!mounted) return;
      final thread = ChatThread.fromDoc(tid, snap.data() ?? {});
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ChatRoomScreen(thread: thread)),
      );
    } catch (e) {
      debugPrint('Chat open error: $e');
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
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
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text('Contact ${widget.listing.hostName}',
            style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFF3BDC3)));
    }
    if (_error == 'login') {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
            child: Text('Please log in to message this host.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54))),
      );
    }
    if (_error == 'owner') {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
            child: Text("This is your own listing.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54))),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text('Could not open chat',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_error ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3BDC3)),
              onPressed: () => setState(() {
                _loading = true;
                _error = null;
                _open();
              }),
              child:
                  const Text('Retry', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}