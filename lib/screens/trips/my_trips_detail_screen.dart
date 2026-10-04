import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../services/booking_service.dart';
import '../../widgets/booking_card.dart';

class MyTripsDetailScreen extends StatelessWidget {
  const MyTripsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Bookings',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: user == null
          ? const Center(
              child: Text('Log in to see your bookings',
                  style: TextStyle(color: Colors.black54)))
          : StreamBuilder<List<Booking>>(
              stream: BookingService.streamBookingsForTraveler(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFF3BDC3)));
                }
                final bookings = snapshot.data ?? [];
                if (bookings.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.luggage_outlined,
                              size: 64, color: Colors.black38),
                          SizedBox(height: 16),
                          Text('No bookings yet',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text(
                              'Your booking requests will appear here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  height: 1.4)),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: bookings.length,
                  itemBuilder: (context, i) => BookingCard(
                      booking: bookings[i], isHostView: false),
                );
              },
            ),
    );
  }
}