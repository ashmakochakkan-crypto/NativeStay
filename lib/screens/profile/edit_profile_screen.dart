import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'interests_data.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, String> initialData;
  final List<String> initialInterests;

  const EditProfileScreen({
    super.key,
    required this.initialData,
    required this.initialInterests,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late Map<String, String> _data;
  late List<String> _interests;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _data = Map<String, String>.from(widget.initialData);
    _interests = List<String>.from(widget.initialInterests);
  }

  Future<void> _saveToFirestore() async {
    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'born': _data['born'] ?? '',
          'destination': _data['destination'] ?? '',
          'work': _data['work'] ?? '',
          'pets': _data['pets'] ?? '',
          'skill': _data['skill'] ?? '',
          'funFact': _data['funFact'] ?? '',
          'song': _data['song'] ?? '',
          'languages': _data['languages'] ?? '',
          'love': _data['love'] ?? '',
          'live': _data['live'] ?? '',
          'about': _data['about'] ?? '',
          'interests': _interests,
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Error updating profile in Firestore: $e");
      }
    }

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context, {
        'data': _data,
        'interests': _interests,
      });
    }
  }

  void _openTextDialog(String key, String title, String hint) {
    final controller = TextEditingController(text: _data[key] ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: hint,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black12)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFF3BDC3))),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3BDC3),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    setState(() => _data[key] = controller.text.trim());
                    Navigator.pop(context);
                  },
                  child: const Text('Save',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openAlphabeticalInterestsSheet() {
    String searchQuery = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = kAllInterestsMaster.where((item) {
              final title = (item['title'] as String).toLowerCase();
              return title.contains(searchQuery.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Interests',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (val) =>
                        setModalState(() => searchQuery = val),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFFF3BDC3)),
                      hintText: 'Search for interests',
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide:
                              const BorderSide(color: Colors.black12)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide:
                              const BorderSide(color: Color(0xFFF3BDC3))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: Colors.black12),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final String title = item['title'];
                        final IconData icon = item['icon'];
                        final isSelected = _interests.contains(title);

                        return CheckboxListTile(
                          value: isSelected,
                          activeColor: const Color(0xFFF3BDC3),
                          checkColor: Colors.black,
                          title: Row(
                            children: [
                              Icon(icon, size: 20, color: Colors.black),
                              const SizedBox(width: 12),
                              Text(title,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black)),
                            ],
                          ),
                          onChanged: (val) {
                            setModalState(() {
                              if (val == true) {
                                _interests.add(title);
                              } else {
                                _interests.remove(title);
                              }
                            });
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3BDC3),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEditTile(
      IconData icon, String label, String key, String hint) {
    final value = _data[key];
    final bool hasValue = value != null && value.isNotEmpty;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black, size: 22),
      title: Text(hasValue ? '$label: $value' : label,
          style: TextStyle(
              fontSize: 15,
              fontWeight: hasValue ? FontWeight.bold : FontWeight.normal,
              color: Colors.black)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 16, color: Colors.black38),
      onTap: () => _openTextDialog(key, label, hint),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title:
            const Text('Edit profile', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('My profile',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 4),
              const Text(
                  'Hosts and guests can see your profile to help build trust.',
                  style: TextStyle(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 16),

              _buildEditTile(
                  Icons.lightbulb_outline, 'Year I was born', 'born', 'e.g., 2000s'),
              const Divider(height: 1, color: Colors.black12),
              _buildEditTile(Icons.public, 'Where I\'ve always wanted to go',
                  'destination', 'e.g., Poland'),
              const Divider(height: 1, color: Colors.black12),
              _buildEditTile(Icons.work_outline, 'My work', 'work',
                  'e.g., Student'),
              const Divider(height: 1, color: Colors.black12),
              _buildEditTile(
                  Icons.pets, 'Pets', 'pets', 'e.g., Dog named Bruno'),
              const Divider(height: 1, color: Colors.black12),
              _buildEditTile(Icons.auto_fix_high, 'My most useless skill',
                  'skill', 'e.g., Wiggling ears'),
              const Divider(height: 1, color: Colors.black12),
              _buildEditTile(Icons.psychology, 'My fun fact', 'funFact',
                  'e.g., I love coding late'),
              const Divider(height: 1, color: Colors.black12),
              _buildEditTile(Icons.music_note, 'My favorite song', 'song',
                  'e.g., Hotel California'),
              const Divider(height: 1, color: Colors.black12),
              _buildEditTile(Icons.translate, 'Languages I speak', 'languages',
                  'e.g., English, Hindi'),
              const Divider(height: 1, color: Colors.black12),
              _buildEditTile(Icons.favorite_border, 'What I love to do', 'love',
                  'e.g., Travelling'),
              const Divider(height: 1, color: Colors.black12),
              _buildEditTile(
                  Icons.location_on_outlined, 'Where I live', 'live', 'e.g., Mumbai'),
              const Divider(height: 1, color: Colors.black12),

              const SizedBox(height: 24),

              const Text('About me',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _openTextDialog(
                    'about', 'About me', 'Write something fun and punchy...'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12)),
                  child: Text(
                    _data['about']?.isNotEmpty == true
                        ? _data['about']!
                        : 'Write something fun and punchy.',
                    style: TextStyle(
                        color: _data['about']?.isNotEmpty == true
                            ? Colors.black
                            : Colors.black38),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text('My interests',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 8),
              const Text(
                  'Find common ground with other guests and hosts.',
                  style: TextStyle(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _interests
                    .map((item) => Chip(
                          backgroundColor: const Color(0xFFF3BDC3),
                          label:
                              Text(item, style: const TextStyle(color: Colors.black)),
                          deleteIconColor: Colors.black54,
                          onDeleted: () =>
                              setState(() => _interests.remove(item)),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: _openAlphabeticalInterestsSheet,
                child: const Text('Show all interests',
                    style: TextStyle(color: Colors.black)),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3BDC3),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: _isSaving ? null : _saveToFirestore,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('Done',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}