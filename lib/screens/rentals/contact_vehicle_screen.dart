import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/chat.dart';
import '../../models/vehicle_listing.dart';
import '../../services/chat_service.dart';
import '../chat/chat_room_screen.dart';

class ContactVehicleScreen extends StatefulWidget {
  final VehicleListing vehicle;
  const ContactVehicleScreen({super.key, required this.vehicle});

  @override
  State<ContactVehicleScreen> createState() => _ContactVehicleScreenState();
}

class _ContactVehicleScreenState extends State<ContactVehicleScreen> {
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
    if (widget.vehicle.userId == me.uid) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'owner';
        });
      }
      return;
    }

    String myName = me.displayName ?? 'Me';
    String ownerName = 'Vehicle owner';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users').doc(me.uid).get();
      final d = doc.data() ?? {};
      final full =
          '${(d['firstName'] ?? '').toString().trim()} ${(d['lastName'] ?? '').toString().trim()}'
              .trim();
      if (full.isNotEmpty) myName = full;
    } catch (_) {}
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users').doc(widget.vehicle.userId).get();
      final d = doc.data() ?? {};
      final full =
          '${(d['firstName'] ?? '').toString().trim()} ${(d['lastName'] ?? '').toString().trim()}'
              .trim();
      if (full.isNotEmpty) ownerName = full;
    } catch (_) {}

    try {
      final tid = await ChatService.ensureThread(
        listingId: widget.vehicle.docId,
        listingType: 'vehicle',
        listingName: widget.vehicle.nickname,
        listingPhoto: widget.vehicle.coverPhoto,
        myUid: me.uid,
        myName: myName,
        otherUid: widget.vehicle.userId,
        otherName: ownerName,
        hostUid: widget.vehicle.userId,
      );
      if (!mounted) return;
      final snap = await FirebaseFirestore.instance
          .collection('chat_threads').doc(tid).get();
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
        title: const Text('Contact owner',
            style: TextStyle(
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
            child: Text('Please log in to message the owner.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54))),
      );
    }
    if (_error == 'owner') {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
            child: Text("This is your own vehicle listing.",
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