import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/tour_guide.dart';
import '../../services/tour_guides_service.dart';
import 'guide_tour_create_screen.dart';

class GuideToursManagementScreen extends StatefulWidget {
  final TourGuide guide;
  const GuideToursManagementScreen({super.key, required this.guide});

  @override
  State<GuideToursManagementScreen> createState() =>
      _GuideToursManagementScreenState();
}

class _GuideToursManagementScreenState
    extends State<GuideToursManagementScreen> {
  bool _isLoading = true;
  List<TourPackage> _tours = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _isLoading = true);
    final tours =
        await TourGuidesService.fetchToursForGuide(widget.guide.docId);
    if (mounted) {
      setState(() {
        _tours = tours;
        _isLoading = false;
      });
    }
  }

  Future<void> _openCreate() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            GuideTourCreateScreen(guideId: widget.guide.docId),
      ),
    );
    if (created == true) _load();
  }

  Future<void> _openEdit(TourPackage t) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => GuideTourCreateScreen(
          guideId: widget.guide.docId,
          existingTour: t,
        ),
      ),
    );
    if (updated == true) _load();
  }

  void _confirmDelete(TourPackage t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete this tour?'),
        content: Text(
            'Warning: "${t.title}" will be permanently deleted. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance
                  .collection('tour_packages')
                  .doc(t.docId)
                  .delete();
              _load();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tour deleted')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _tourTile(TourPackage t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(t.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.delete_outline,
                    color: Colors.redAccent, size: 20),
                onPressed: () => _confirmDelete(t),
              ),
            ],
          ),
          if (t.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(t.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13, color: Colors.black54)),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              if (t.duration.isNotEmpty) ...[
                const Icon(Icons.timelapse_rounded,
                    size: 14, color: Colors.black54),
                const SizedBox(width: 4),
                Text(t.duration,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54)),
                const SizedBox(width: 12),
              ],
              if (t.groupSize.isNotEmpty) ...[
                const Icon(Icons.group_outlined,
                    size: 14, color: Colors.black54),
                const SizedBox(width: 4),
                Text(t.groupSize,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54)),
              ],
              const Spacer(),
              Text(t.priceLabel,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _openEdit(t),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Edit tour',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Your Tours',
            style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFFF3BDC3)))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tour packages',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text(
                        'Offer specific tours travelers can book directly',
                        style: TextStyle(
                            fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3BDC3),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _openCreate,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Create new tour',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (_tours.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.tour_outlined,
                                  size: 52, color: Colors.black26),
                              SizedBox(height: 12),
                              Text('No tours yet',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54)),
                              SizedBox(height: 6),
                              Text(
                                  'Create your first tour package above',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black45)),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._tours.map(_tourTile),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}