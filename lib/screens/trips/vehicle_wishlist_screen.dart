import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/vehicle_listing.dart';
import '../../services/wishlist_service.dart';
import '../rentals/vehicle_detail_screen.dart';

class VehicleWishlistScreen extends StatelessWidget {
  const VehicleWishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Saved Vehicles',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: user == null
          ? const Center(
              child: Text('Log in to see your saved vehicles',
                  style: TextStyle(color: Colors.black54)),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: VehicleWishlistService.stream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFF3BDC3)));
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_car_outlined,
                              size: 64, color: Colors.black38),
                          SizedBox(height: 16),
                          Text('No saved vehicles yet',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          SizedBox(height: 8),
                          Text(
                            'Tap the heart on any vehicle to save it here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final photo = (data['photo'] ?? '').toString();
                    final nickname =
                        (data['nickname'] ?? 'Vehicle').toString();
                    final title = (data['displayTitle'] ?? '').toString();
                    final city = (data['city'] ?? '').toString();
                    final state = (data['state'] ?? '').toString();
                    final price = (data['pricePerDay'] ?? '').toString();
                    final pricingModel =
                        (data['pricingModel'] ?? 'Per Day').toString();
                    final vehicleType =
                        (data['vehicleType'] ?? '').toString();
                    final rentalMode = (data['rentalMode'] ?? '').toString();

                    String suffix = '';
                    switch (pricingModel) {
                      case 'Per Hour':
                        suffix = ' / hour';
                        break;
                      case 'Per Day':
                        suffix = ' / day';
                        break;
                      case 'Per Km':
                        suffix = ' / km';
                        break;
                      case 'Per Person':
                        suffix = ' / person';
                        break;
                    }

                    return GestureDetector(
                      onTap: () async {
                        try {
                          final doc = await FirebaseFirestore.instance
                              .collection('vehicle_listings')
                              .doc(docs[index].id)
                              .get();
                          if (!doc.exists) return;
                          final vehicle = VehicleListing.fromDoc(
                              doc.id, doc.data()!);
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VehicleDetailScreen(vehicle: vehicle),
                            ),
                          );
                        } catch (e) {
                          debugPrint('Open from vehicle wishlist error: $e');
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: photo.isNotEmpty
                                    ? Image.network(photo,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _placeholder())
                                    : _placeholder(),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title.isNotEmpty ? title : nickname,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('$city, $state',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54)),
                                  const SizedBox(height: 6),
                                  Text('$vehicleType · $rentalMode',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black45)),
                                  const SizedBox(height: 8),
                                  Text('₹$price$suffix',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                  Icons.favorite_rounded,
                                  color: Color(0xFFE91E63)),
                              onPressed: () async {
                                final u =
                                    FirebaseAuth.instance.currentUser;
                                if (u == null) return;
                                await VehicleWishlistService.remove(
                                    u.uid, docs[index].id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
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
}