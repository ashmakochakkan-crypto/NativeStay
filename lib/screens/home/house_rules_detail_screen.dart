import 'package:flutter/material.dart';
import '../../models/home_listing.dart';

class HouseRulesDetailScreen extends StatelessWidget {
  final HomeListing listing;
  const HouseRulesDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final l = listing;

    final rows = <Map<String, dynamic>>[
      if (l.liveWithHost == 'Yes')
        {'icon': Icons.home_outlined, 'label': 'Host stays here', 'value': 'Yes'},
      if (l.shareProperty == 'Yes')
        {
          'icon': Icons.people_outline_rounded,
          'label': 'Shared with family',
          'value': 'Yes'
        },
      if (l.haveRoommates == 'Yes')
        {
          'icon': Icons.group_outlined,
          'label': 'Other guests',
          'value': l.otherPeopleCount != '0' && l.otherPeopleCount.isNotEmpty
              ? l.otherPeopleCount
              : 'Present',
        },
      if (l.familyCount != '0' && l.familyCount.isNotEmpty)
        {
          'icon': Icons.family_restroom_rounded,
          'label': 'Family members',
          'value': l.familyRelation.isNotEmpty && l.familyRelation != 'None'
              ? '${l.familyCount} ($l.familyRelation)'
              : l.familyCount,
        },
      if (l.sharedAreas.isNotEmpty && l.sharedAreas != 'None')
        {
          'icon': Icons.meeting_room_outlined,
          'label': 'Shared areas',
          'value': l.sharedAreas
        },
      if (l.privateAreas.isNotEmpty)
        {
          'icon': Icons.lock_outline_rounded,
          'label': 'Private for guest',
          'value': l.privateAreas
        },
      if (l.houseRulesOther.trim().isNotEmpty)
        {
          'icon': Icons.edit_note_rounded,
          'label': 'Other rules',
          'value': l.houseRulesOther.trim()
        },
      {
        'icon': Icons.login_rounded,
        'label': 'Check-in',
        'value': 'After ${l.checkIn}'
      },
      {
        'icon': Icons.logout_rounded,
        'label': 'Check-out',
        'value': 'Before ${l.checkOut}'
      },
      {'icon': Icons.smoking_rooms_rounded, 'label': 'Smoking', 'value': l.smoking},
      {'icon': Icons.pets_rounded, 'label': 'Pets', 'value': l.petsAllowed},
      {
        'icon': Icons.celebration_rounded,
        'label': 'Parties & events',
        'value': l.parties
      },
      {
        'icon': Icons.group_add_rounded,
        'label': 'Visitors',
        'value': l.visitorsAllowed == 'Yes' ? 'Allowed' : 'Not allowed'
      },
      {
        'icon': Icons.child_care_rounded,
        'label': 'Children',
        'value': l.childrenAllowed
      },
      {
        'icon': Icons.volume_off_rounded,
        'label': 'Quiet hours',
        'value': l.quietHours
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('House rules',
            style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text('During your stay',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 6),
            const Text("Here's what the host expects from guests.",
                style: TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 24),
            ...rows.map((row) {
              final value = (row['value'] ?? '').toString();
              if (value.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(row['icon'] as IconData,
                        size: 22, color: const Color(0xFFF3BDC3)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(row['label'] as String,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black)),
                    ),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                  ],
                ),
              );
            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}