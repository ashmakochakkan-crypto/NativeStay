import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/home_listing.dart';
import '../../services/wishlist_service.dart';
import '../home/listing_detail_screen.dart';

class WishlistDetailScreen extends StatelessWidget {
  const WishlistDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Wishlists',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: user == null
          ? const Center(
              child: Text('Log in to see your wishlist',
                  style: TextStyle(color: Colors.black54)),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: WishlistService.stream(user.uid),
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
                          Icon(Icons.favorite_border_rounded,
                              size: 64, color: Colors.black38),
                          SizedBox(height: 16),
                          Text('Your wishlist is empty',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          SizedBox(height: 8),
                          Text(
                            'Tap the heart on any stay to save it here.',
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
                    final photo = (data['coverPhoto'] ?? '').toString();
                    final name = (data['stayName'] ?? 'Untitled').toString();
                    final city = (data['city'] ?? '').toString();
                    final state = (data['state'] ?? '').toString();
                    final price = (data['pricePerNight'] ?? '').toString();
                    final type = (data['propertyType'] ?? '').toString();
                    final stayType = (data['stayType'] ?? '').toString();

                    return GestureDetector(
                      onTap: () async {
                        try {
                          final doc = await FirebaseFirestore.instance
                              .collection('property_listings')
                              .doc(docs[index].id)
                              .get();
                          if (!doc.exists) return;
                          final listing = HomeListing.fromDoc(
                              doc.id, doc.data()!);
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ListingDetailScreen(listing: listing),
                            ),
                          );
                        } catch (e) {
                          debugPrint('Open from wishlist error: $e');
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
                                            Container(
                                              color: const Color(
                                                  0xFFFFF0F3),
                                              child: const Icon(
                                                  Icons.home_work_rounded,
                                                  color:
                                                      Color(0xFFF3BDC3)),
                                            ))
                                    : Container(
                                        color: const Color(0xFFFFF0F3),
                                        child: const Icon(
                                            Icons.home_work_rounded,
                                            color: Color(0xFFF3BDC3)),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                  const SizedBox(height: 4),
                                  Text('$city, $state',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54)),
                                  const SizedBox(height: 6),
                                  Text('$type · $stayType',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black45)),
                                  const SizedBox(height: 8),
                                  Text('₹$price / night',
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
                                await WishlistService.remove(
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
}