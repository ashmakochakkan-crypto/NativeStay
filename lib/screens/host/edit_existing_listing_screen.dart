import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/property_listing_data.dart';
import 'host_wizard_step1_screen.dart';

class EditExistingListingScreen extends StatefulWidget {
  const EditExistingListingScreen({super.key});

  @override
  State<EditExistingListingScreen> createState() =>
      _EditExistingListingScreenState();
}

class _EditExistingListingScreenState
    extends State<EditExistingListingScreen> {
  bool _isLoading = true;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _listings = [];

  @override
  void initState() {
    super.initState();
    _fetchListings();
  }

  Future<void> _fetchListings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final snap = await FirebaseFirestore.instance
          .collection('property_listings')
          .where('userId', isEqualTo: user.uid)
          .get();
      if (!mounted) return;
      setState(() {
        _listings = snap.docs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching listings: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded,
                color: Colors.redAccent, size: 28),
            SizedBox(width: 10),
            Expanded(child: Text('Delete Listing Permanently?')),
          ],
        ),
        content: const Text(
          'Warning: This action cannot be undone. Your property listing '
          'will be permanently deleted, including its blocked dates.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance
                    .collection('listing_blocks')
                    .doc(docId)
                    .delete()
                    .catchError((_) {});

                await FirebaseFirestore.instance
                    .collection('property_listings')
                    .doc(docId)
                    .delete();

                _fetchListings();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Listing deleted successfully')),
                  );
                }
              } catch (e) {
                debugPrint('Delete listing error: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Delete failed: $e')),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Existing Property Listings',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF3BDC3)))
          : _listings.isEmpty
              ? const Center(
                  child: Text('No property listings found',
                      style: TextStyle(color: Colors.black54)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _listings.length,
                  itemBuilder: (context, index) {
                    final doc = _listings[index];
                    final data = doc.data();
                    return GestureDetector(
                      onTap: () {
                        final listingData =
                            PropertyListingData.fromMap(data, doc.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HostWizardStep1Screen(
                              userName: listingData.hostName.isNotEmpty
                                  ? listingData.hostName
                                  : 'Host',
                              existingData: listingData,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                      data['stayName'] ?? 'Unnamed Stay',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.redAccent),
                                  onPressed: () => _confirmDelete(doc.id),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                                '${data['propertyType'] ?? 'Home'} · ${data['city'] ?? ''}, ${data['state'] ?? ''}',
                                style:
                                    const TextStyle(color: Colors.black54)),
                            const SizedBox(height: 10),
                            Text(
                                'Price: ₹${data['pricePerNight'] ?? '0'} / night',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            const Text(
                                'Tap anywhere on card to edit this listing',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.blueGrey)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}