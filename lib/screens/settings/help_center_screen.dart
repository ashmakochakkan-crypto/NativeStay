import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  Widget _buildHelpCard(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 6),
          Text(description,
              style: const TextStyle(
                  fontSize: 13, color: Colors.black87, height: 1.4)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context)),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: Color(0xFFF3BDC3),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black45,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(text: 'Guest / Traveler'),
              Tab(text: 'Home Host'),
              Tab(text: 'Tour Guide'),
              Tab(text: 'Vehicle Host'),
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Text(
                'How can we help?',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildHelpCard('Searching Homestays',
                          'Filter stays by destination, dates, adults, children, and room requirements.'),
                      _buildHelpCard('Renting Vehicles',
                          'Select pick-up and drop-off dates and locations to find cars or bikes for your trip.'),
                      _buildHelpCard('Booking Tour Guides',
                          'Discover verified local experts and select dates for customized city experiences.'),
                      _buildHelpCard('Wishlists & Saved Trips',
                          'Save homestays and experiences by tapping the heart icon, accessible anytime under Wishlists.'),
                      _buildHelpCard('Cancellations & Refunds',
                          'Review provider-specific terms before booking. Request cancellations from your Trips tab.'),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildHelpCard('Creating a Listing',
                          'Add photos, descriptions, house rules, and amenities to list your homestay.'),
                      _buildHelpCard('Pricing & Calendar',
                          'Set custom nightly pricing and mark blocked dates directly on your availability calendar.'),
                      _buildHelpCard('Guest Messaging',
                          'Chat directly with guests to answer questions, send check-in directions, and confirm arrival times.'),
                      _buildHelpCard('Payments',
                          'Guests pay the host directly on arrival. Track confirmed bookings from your dashboard.'),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildHelpCard('Listing Experiences',
                          'Create tailored tours, specify group sizes, and outline unique itinerary highlights.'),
                      _buildHelpCard('Credentials & Verification',
                          'Submit local guide licenses and ID to receive a verified profile badge.'),
                      _buildHelpCard('Managing Tour Dates',
                          'Update upcoming schedule slots and track traveler bookings in real time.'),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildHelpCard('Vehicle Listings',
                          'List cars and motorbikes with vehicle specs, rental terms, and deposit details.'),
                      _buildHelpCard('Pickup & Drop-off Hubs',
                          'Designate airport, station, or city locations for seamless key exchange.'),
                      _buildHelpCard('Driver Verification',
                          'Ensure valid driving licenses and ID verification prior to vehicle handover.'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}