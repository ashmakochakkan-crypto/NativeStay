import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Bottom bar with Previous + Next buttons used across all wizards.
class WizardBottomBar extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String nextLabel;
  final bool isLoading;

  const WizardBottomBar({
    super.key,
    this.onPrevious,
    required this.onNext,
    this.nextLabel = 'Next',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black26),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: onPrevious,
                child: const Text(
                  'Previous',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: isLoading ? null : onNext,
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        nextLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Handles uploading picked images to Firebase Storage.
class WizardPhotoUploadHelper {
  static Future<List<String>> uploadAll({
    required List<XFile> files,
    required String userId,
    void Function(int done, int total)? onProgress,
  }) async {
    final urls = <String>[];
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final bytes = await file.readAsBytes();
      final ext = file.name.split('.').last;
      final ref = FirebaseStorage.instance.ref().child(
            'property_listings/$userId/${DateTime.now().millisecondsSinceEpoch}_$i.$ext',
          );
      final task = await ref.putData(
        bytes,
        SettableMetadata(contentType: _mimeFor(ext)),
      );
      final url = await task.ref.getDownloadURL();
      urls.add(url);
      onProgress?.call(i + 1, files.length);
    }
    return urls;
  }

  static String _mimeFor(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      default:
        return 'application/octet-stream';
    }
  }
}