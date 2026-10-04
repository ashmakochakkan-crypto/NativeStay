import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/tour_guide.dart';
import '../host/wizard_helpers.dart';
import 'guide_wizard_step2_screen.dart';

class GuideWizardStep1Screen extends StatefulWidget {
  final GuideProfileData? existingData;
  const GuideWizardStep1Screen({super.key, this.existingData});

  @override
  State<GuideWizardStep1Screen> createState() => _GuideWizardStep1ScreenState();
}

class _GuideWizardStep1ScreenState extends State<GuideWizardStep1Screen> {
  late GuideProfileData _data;
  final _fullNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _data = widget.existingData ?? GuideProfileData();
    _prefill();
  }

  Future<void> _prefill() async {
    _fullNameController.text = _data.fullName;
    _displayNameController.text = _data.displayName;
    _phoneController.text = _data.phone;
    _emailController.text = _data.email;

    if (_fullNameController.text.isEmpty) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          final data = doc.data() ?? {};
          final firstName = (data['firstName'] ?? '').toString().trim();
          final lastName = (data['lastName'] ?? '').toString().trim();
          final full = '$firstName $lastName'.trim();
          if (mounted) {
            setState(() {
              if (_fullNameController.text.isEmpty && full.isNotEmpty) {
                _fullNameController.text = full;
              }
              if (_phoneController.text.isEmpty) {
                _phoneController.text = (data['phone'] ?? '').toString();
              }
              if (_emailController.text.isEmpty) {
                _emailController.text =
                    (data['email'] ?? user.email ?? '').toString();
              }
            });
          }
        }
      } catch (e) {
        debugPrint('Guide prefill error: $e');
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _displayNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    try {
      final files = await _picker.pickMultiImage(
        imageQuality: 75,
        maxWidth: 1600,
      );
      if (files.isEmpty) return;
      setState(() => _data.localPhotos.addAll(files));
    } catch (e) {
      debugPrint('Pick error: $e');
    }
  }

  void _removeLocalPhoto(int i) {
    setState(() => _data.localPhotos.removeAt(i));
  }

  void _removeUploadedPhoto(int i) {
    setState(() => _data.photos.removeAt(i));
  }

  Future<void> _handleNext() async {
    final fullName = _fullNameController.text.trim();
    final displayName = _displayNameController.text.trim();
    final phone = _phoneController.text.trim();

    if (_data.photos.isEmpty && _data.localPhotos.isEmpty) {
      _snack('Please add at least 1 photo');
      return;
    }
    if (fullName.isEmpty) {
      _snack('Please enter your full name');
      return;
    }
    if (displayName.isEmpty) {
      _snack('Please enter a display name travelers will see');
      return;
    }
    if (phone.isEmpty) {
      _snack('Please enter your phone number');
      return;
    }

    if (_data.localPhotos.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _snack('You must be logged in');
        return;
      }
      setState(() => _isUploading = true);
      try {
        final urls = await WizardPhotoUploadHelper.uploadAll(
          files: _data.localPhotos,
          userId: user.uid,
          onProgress: (_, __) {},
        );
        _data.photos.addAll(urls);
        _data.localPhotos.clear();
        if (_data.photoUrl.isEmpty && _data.photos.isNotEmpty) {
          _data.photoUrl = _data.photos.first;
        }
      } catch (e) {
        debugPrint('Upload error: $e');
        if (mounted) {
          setState(() => _isUploading = false);
          _snack('Upload failed: $e');
        }
        return;
      }
      if (mounted) setState(() => _isUploading = false);
    }

    _data.fullName = fullName;
    _data.displayName = displayName;
    _data.phone = phone;
    _data.email = _emailController.text.trim();
    if (_data.photoUrl.isEmpty && _data.photos.isNotEmpty) {
      _data.photoUrl = _data.photos.first;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuideWizardStep2Screen(data: _data),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38),
            prefixIcon: Icon(icon, color: const Color(0xFFF3BDC3)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFFF3BDC3), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _photoTile({required Widget child, required VoidCallback onRemove}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox.expand(child: child),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                  color: Colors.black54, shape: BoxShape.circle),
              child:
                  const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[];
    for (int i = 0; i < _data.photos.length; i++) {
      tiles.add(_photoTile(
        child: Image.network(_data.photos[i], fit: BoxFit.cover),
        onRemove: () => _removeUploadedPhoto(i),
      ));
    }
    for (int i = 0; i < _data.localPhotos.length; i++) {
      tiles.add(_photoTile(
        child: Image.file(File(_data.localPhotos[i].path),
            fit: BoxFit.cover),
        onRemove: () => _removeLocalPhoto(i),
      ));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(color: Color(0xFFF3BDC3)))
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.person_outline,
                                  color: Color(0xFFF3BDC3), size: 28),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text('Your guide profile',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'First photo will be your profile picture',
                            style: TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              const Icon(Icons.photo_library_outlined,
                                  size: 20, color: Color(0xFFF3BDC3)),
                              const SizedBox(width: 8),
                              Text(
                                'Photos (${tiles.length}) *',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            children: [
                              GestureDetector(
                                onTap: _isUploading ? null : _pickPhotos,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF0F3),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: const Color(0xFFF3BDC3),
                                        width: 2),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo_outlined,
                                          size: 28,
                                          color: Color(0xFFF3BDC3)),
                                      SizedBox(height: 6),
                                      Text('Add',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight:
                                                  FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                              ...tiles,
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add photos of yourself, your group visits, and places you have guided.',
                            style: TextStyle(
                                fontSize: 12, color: Colors.black45),
                          ),

                          const SizedBox(height: 24),
                          const Divider(height: 1, color: Colors.black12),
                          const SizedBox(height: 20),

                          _field(
                            controller: _fullNameController,
                            label: 'Full legal name *',
                            hint: 'e.g. Rohan Sharma',
                            icon: Icons.person_outline,
                          ),
                          _field(
                            controller: _displayNameController,
                            label: 'Display name travelers see *',
                            hint: 'e.g. Rohan the Himalayan Guide',
                            icon: Icons.badge_outlined,
                          ),
                          _field(
                            controller: _phoneController,
                            label: 'Phone number *',
                            hint: '10-digit number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          _field(
                            controller: _emailController,
                            label: 'Email (optional)',
                            hint: 'your@email.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ],
                      ),
                    ),
                  ),
                  WizardBottomBar(
                    onPrevious: () => Navigator.pop(context),
                    onNext: _handleNext,
                    isLoading: _isUploading,
                  ),
                ],
              ),
      ),
    );
  }
}