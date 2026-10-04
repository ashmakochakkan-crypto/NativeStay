import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/vehicle_listing.dart';
import '../../services/vehicle_listings_service.dart';
import '../../widgets/badges.dart';
import '../booking/host_bookings_screen.dart';
import '../host/vehicle_wizard_step1_screen.dart';

class VehicleDashboardScreen extends StatefulWidget {
  const VehicleDashboardScreen({super.key});

  @override
  State<VehicleDashboardScreen> createState() =>
      _VehicleDashboardScreenState();
}

class _VehicleDashboardScreenState extends State<VehicleDashboardScreen> {
  bool _isLoading = true;
  List<VehicleListing> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final list = await VehicleListingsService.fetchAllForUser(user.uid);
      if (mounted) {
        setState(() {
          _vehicles = list;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteVehicle(VehicleListing v) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete this vehicle?'),
        content: Text(
            'Warning: "${v.nickname}" will be permanently deleted from everywhere. This cannot be undone.'),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('listing_blocks')
          .doc(v.docId)
          .delete()
          .catchError((_) {});

      await FirebaseFirestore.instance
          .collection('vehicle_listings')
          .doc(v.docId)
          .delete();

      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle deleted')),
        );
      }
    } catch (e) {
      debugPrint('Delete vehicle error: $e');
    }
  }

  Widget _vehicleTile(VehicleListing v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: v.coverPhoto.isNotEmpty
                  ? Image.network(v.coverPhoto,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${v.make} ${v.model}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(v.locationLabel,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black45)),
                const SizedBox(height: 6),
                Text('₹${v.basePrice}${v.priceSuffix}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.redAccent, size: 22),
            onPressed: () => _deleteVehicle(v),
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
            color: Color(0xFFE91E63)),
      ),
    );
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
                    const Text('Vehicle Dashboard',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text('Manage your listed vehicles',
                        style: TextStyle(
                            fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3BDC3),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const VehicleWizardStep1Screen()),
                          ).then((_) => _load());
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add new vehicle',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                      ),
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
                          title: const Text('Manage vehicle bookings',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          subtitle:
                              const Text('Confirm or decline rentals',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54)),
                          trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Colors.black45),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HostBookingsScreen(
                                    listingType: 'vehicle',
                                    title: 'Vehicle bookings'),
                              ),
                            );
                          },
                        );
                        if (uid.isEmpty) return tile;
                        return PendingHostBookingsBadge(
                            hostId: uid,
                            listingType: 'vehicle',
                            child: tile);
                      },
                    ),
                    const SizedBox(height: 24),

                    if (_vehicles.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.directions_car_outlined,
                                  size: 52, color: Colors.black26),
                              SizedBox(height: 12),
                              Text('No vehicles listed yet',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54)),
                              SizedBox(height: 6),
                              Text('Add your first vehicle above',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black45)),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._vehicles.map(_vehicleTile),
                  ],
                ),
              ),
            ),
    );
  }
}