import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/property_listing_data.dart';
import 'host_wizard_step6_screen.dart';
import 'wizard_helpers.dart';

class HostWizardStep5Screen extends StatefulWidget {
  final String userName;
  final PropertyListingData data;
  const HostWizardStep5Screen(
      {super.key, required this.userName, required this.data});

  @override
  State<HostWizardStep5Screen> createState() => _HostWizardStep5ScreenState();
}

class _HostWizardStep5ScreenState extends State<HostWizardStep5Screen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  int _uploadedCount = 0;
  int _totalToUpload = 0;

  static const int _minPhotos = 5;

  Future<void> _pickImages() async {
    try {
      final files = await _picker.pickMultiImage(
        imageQuality: 75,
        maxWidth: 1600,
      );
      if (files.isEmpty) return;
      setState(() {
        widget.data.localPhotos.addAll(files);
      });
    } catch (e) {
      debugPrint('Error picking images: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick images: $e')),
        );
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      widget.data.localPhotos.removeAt(index);
    });
  }

  Future<void> _handleNext() async {
    final total = widget.data.localPhotos.length + widget.data.photos.length;

    if (total < _minPhotos) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add more photos?'),
          content: Text(
            'We recommend at least $_minPhotos photos so guests get a real feel for the place.\n\nYou have $total. Continue anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Add more', style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3BDC3),
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    if (widget.data.localPhotos.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to upload photos')),
        );
        return;
      }

      setState(() {
        _isUploading = true;
        _totalToUpload = widget.data.localPhotos.length;
        _uploadedCount = 0;
      });

      try {
        final urls = await WizardPhotoUploadHelper.uploadAll(
          files: widget.data.localPhotos,
          userId: user.uid,
          onProgress: (done, total) {
            if (mounted) setState(() => _uploadedCount = done);
          },
        );
        widget.data.photos.addAll(urls);
        widget.data.localPhotos.clear();
      } catch (e) {
        debugPrint('Upload error: $e');
        if (mounted) {
          setState(() => _isUploading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')),
          );
        }
        return;
      }

      if (!mounted) return;
      setState(() => _isUploading = false);
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HostWizardStep6Screen(userName: widget.userName, data: widget.data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allPhotos = <Widget>[];

    for (int i = 0; i < widget.data.photos.length; i++) {
      allPhotos.add(_photoTile(
        child: Image.network(widget.data.photos[i], fit: BoxFit.cover),
        onRemove: () => setState(() => widget.data.photos.removeAt(i)),
      ));
    }

    for (int i = 0; i < widget.data.localPhotos.length; i++) {
      allPhotos.add(_photoTile(
        child: Image.file(
          File(widget.data.localPhotos[i].path),
          fit: BoxFit.cover,
        ),
        onRemove: () => _removePhoto(i),
      ));
    }

    final totalPhotos = widget.data.photos.length + widget.data.localPhotos.length;

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
                        Icon(Icons.photo_library_outlined,
                            color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Text('Add some photos',
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Minimum $_minPhotos photos. Show the space, rooms, and views.',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$totalPhotos / $_minPhotos added',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: totalPhotos >= _minPhotos
                            ? Colors.green
                            : const Color(0xFFF3BDC3),
                      ),
                    ),
                    const SizedBox(height: 20),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: [
                        GestureDetector(
                          onTap: _isUploading ? null : _pickImages,
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
                                    size: 32, color: Color(0xFFF3BDC3)),
                                SizedBox(height: 6),
                                Text('Add',
                                    style: TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        ...allPhotos,
                      ],
                    ),

                    if (_isUploading) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Uploading $_uploadedCount of $_totalToUpload...',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: _totalToUpload == 0
                                  ? 0
                                  : _uploadedCount / _totalToUpload,
                              backgroundColor: Colors.white,
                              color: const Color(0xFFF3BDC3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            WizardBottomBar(
              onPrevious: _isUploading ? null : () => Navigator.pop(context),
              onNext: _handleNext,
              isLoading: _isUploading,
            ),
          ],
        ),
      ),
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
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}