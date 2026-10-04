import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/vehicle_listing.dart';
import 'vehicle_wizard_step2_screen.dart';
import 'wizard_helpers.dart';

class VehicleWizardStep1Screen extends StatefulWidget {
  final VehicleListingData? existingData;
  const VehicleWizardStep1Screen({super.key, this.existingData});

  @override
  State<VehicleWizardStep1Screen> createState() =>
      _VehicleWizardStep1ScreenState();
}

class _VehicleWizardStep1ScreenState extends State<VehicleWizardStep1Screen> {
  late VehicleListingData _data;
  final _nicknameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _data = widget.existingData ?? VehicleListingData();
    _nicknameController.text = _data.nickname;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
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
    final nick = _nicknameController.text.trim();

    if (_data.photos.isEmpty && _data.localPhotos.isEmpty) {
      _snack('Please add at least 1 photo of your vehicle');
      return;
    }
    if (nick.isEmpty) {
      _snack('Please give your vehicle a nickname');
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

    _data.nickname = nick;

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleWizardStep2Screen(data: _data),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.directions_car_filled_rounded,
                            color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('List your vehicle',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'First photo will be your cover photo',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
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
                              fontSize: 14, fontWeight: FontWeight.bold),
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
                                  color: const Color(0xFFF3BDC3), width: 2),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined,
                                    size: 28, color: Color(0xFFF3BDC3)),
                                SizedBox(height: 6),
                                Text('Add',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        ...tiles,
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Front, back, sides, interior, odometer. Show the vehicle clearly.',
                      style: TextStyle(fontSize: 12, color: Colors.black45),
                    ),

                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Colors.black12),
                    const SizedBox(height: 20),

                    const Text('Vehicle nickname *',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nicknameController,
                      maxLength: 40,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'e.g. White Innova in Manali',
                        hintStyle: const TextStyle(color: Colors.black38),
                        counterText: '',
                        prefixIcon: const Icon(Icons.badge_outlined,
                            color: Color(0xFFF3BDC3)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFFF3BDC3), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'A short title travelers see at a glance',
                      style: TextStyle(fontSize: 12, color: Colors.black45),
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