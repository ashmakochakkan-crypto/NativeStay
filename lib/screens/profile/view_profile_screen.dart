import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'interests_data.dart';

class ViewProfileScreen extends StatelessWidget {
  final String firstName;
  final Map<String, String>? profileData;
  final List<String>? interests;
  final Function(Map<String, String>, List<String>)? onUpdateProfile;

  const ViewProfileScreen({
    super.key,
    required this.firstName,
    this.profileData,
    this.interests,
    this.onUpdateProfile,
  });

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black),
          const SizedBox(width: 14),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to view your profile")),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
                child:
                    CircularProgressIndicator(color: Color(0xFFF3BDC3))),
          );
        }

        final data = snapshot.data?.data() ?? {};
        final Map<String, String> liveData = {
          'born': data['born'] ?? '',
          'destination': data['destination'] ?? '',
          'work': data['work'] ?? '',
          'pets': data['pets'] ?? '',
          'skill': data['skill'] ?? '',
          'funFact': data['funFact'] ?? '',
          'song': data['song'] ?? '',
          'languages': data['languages'] ?? '',
          'love': data['love'] ?? '',
          'live': data['live'] ?? '',
          'about': data['about'] ?? '',
        };
        final List<String> liveInterests =
            List<String>.from(data['interests'] ?? []);
        final bool hasData =
            liveData.values.any((v) => v.isNotEmpty) || liveInterests.isNotEmpty;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final result = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                        initialData: liveData,
                        initialInterests: liveInterests,
                      ),
                    ),
                  );

                  if (result != null && onUpdateProfile != null) {
                    onUpdateProfile!(
                      Map<String, String>.from(result['data'] ?? {}),
                      List<String>.from(result['interests'] ?? []),
                    );
                  }
                },
                child: const Text('Edit',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline)),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: const BoxDecoration(
                              color: Color(0xFFF3BDC3),
                              shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              firstName.isNotEmpty
                                  ? firstName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(firstName,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!hasData) ...[
                    const Text('Complete your profile',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    const SizedBox(height: 8),
                    const Text(
                        'Your profile is an important part of every reservation. Complete yours to help other hosts and guests get to know you.',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.4)),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 140,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3BDC3),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(
                              initialData: liveData,
                              initialInterests: liveInterests,
                            ),
                          ),
                        ),
                        child: const Text('Get started',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ] else ...[
                    if (liveData['born']?.isNotEmpty == true)
                      _buildInfoRow(Icons.lightbulb_outline,
                          'Born in the ${liveData['born']}'),
                    if (liveData['destination']?.isNotEmpty == true)
                      _buildInfoRow(Icons.public,
                          'Where I\'ve always wanted to go: ${liveData['destination']}'),
                    if (liveData['work']?.isNotEmpty == true)
                      _buildInfoRow(
                          Icons.work_outline, 'My work: ${liveData['work']}'),
                    if (liveData['pets']?.isNotEmpty == true)
                      _buildInfoRow(
                          Icons.pets, 'Pets: ${liveData['pets']}'),
                    if (liveData['skill']?.isNotEmpty == true)
                      _buildInfoRow(Icons.auto_fix_high,
                          'Skill: ${liveData['skill']}'),
                    if (liveData['funFact']?.isNotEmpty == true)
                      _buildInfoRow(Icons.psychology,
                          'Fun fact: ${liveData['funFact']}'),
                    if (liveData['song']?.isNotEmpty == true)
                      _buildInfoRow(Icons.music_note,
                          'Favorite song: ${liveData['song']}'),
                    if (liveData['languages']?.isNotEmpty == true)
                      _buildInfoRow(Icons.translate,
                          'Languages: ${liveData['languages']}'),
                    if (liveData['love']?.isNotEmpty == true)
                      _buildInfoRow(Icons.favorite_border,
                          'Obsessed with: ${liveData['love']}'),
                    if (liveData['live']?.isNotEmpty == true)
                      _buildInfoRow(Icons.location_on_outlined,
                          'Where I live: ${liveData['live']}'),
                    if (liveData['about']?.isNotEmpty == true) ...[
                      const SizedBox(height: 16),
                      Text(liveData['about']!,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black87)),
                    ],
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(color: Colors.black12)),
                    if (liveInterests.isNotEmpty) ...[
                      const Text('My interests',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: liveInterests
                            .map((title) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border:
                                          Border.all(color: Colors.black12)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(getInterestIcon(title),
                                          size: 18, color: Colors.black),
                                      const SizedBox(width: 8),
                                      Text(title,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}