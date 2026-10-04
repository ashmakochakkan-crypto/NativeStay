import 'package:flutter/material.dart';

final List<Map<String, dynamic>> kAllInterestsMaster = [
  {'title': 'Adrenaline sports', 'icon': Icons.speed},
  {'title': 'American football', 'icon': Icons.sports_football},
  {'title': 'Animals', 'icon': Icons.pets},
  {'title': 'Anime', 'icon': Icons.auto_awesome},
  {'title': 'Archery', 'icon': Icons.track_changes},
  {'title': 'Architecture', 'icon': Icons.apartment},
  {'title': 'Art', 'icon': Icons.palette_outlined},
  {'title': 'Artisanal crafts', 'icon': Icons.architecture},
  {'title': 'Cooking', 'icon': Icons.restaurant},
  {'title': 'Coffee', 'icon': Icons.local_cafe_outlined},
  {'title': 'Fitness', 'icon': Icons.fitness_center},
  {'title': 'Food scenes', 'icon': Icons.ramen_dining},
  {'title': 'Live music', 'icon': Icons.music_note},
  {'title': 'Local culture', 'icon': Icons.center_focus_strong},
  {'title': 'Movies', 'icon': Icons.movie_outlined},
  {'title': 'Nightlife', 'icon': Icons.wb_twilight},
  {'title': 'Outdoors', 'icon': Icons.landscape},
  {'title': 'Photography', 'icon': Icons.camera_alt_outlined},
  {'title': 'Reading', 'icon': Icons.menu_book},
  {'title': 'Swimming', 'icon': Icons.pool},
];

IconData getInterestIcon(String title) {
  final found = kAllInterestsMaster.firstWhere(
    (element) => element['title'] == title,
    orElse: () => {'icon': Icons.star_border},
  );
  return found['icon'] as IconData;
}