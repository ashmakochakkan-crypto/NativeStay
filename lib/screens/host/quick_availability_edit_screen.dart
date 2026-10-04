import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/property_listing_data.dart';

class QuickAvailabilityEditScreen extends StatefulWidget {
  const QuickAvailabilityEditScreen({super.key});

  @override
  State<QuickAvailabilityEditScreen> createState() =>
      _QuickAvailabilityEditScreenState();
}

class _QuickAvailabilityEditScreenState
    extends State<QuickAvailabilityEditScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  List<AvailabilityPeriod> _periods = [];
  String? _docId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final snap = await FirebaseFirestore.instance
          .collection('property_listings')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (snap.docs.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      QueryDocumentSnapshot<Map<String, dynamic>> picked = snap.docs.first;
      if (snap.docs.length > 1 && mounted) {
        final chosen = await showModalBottomSheet<
            QueryDocumentSnapshot<Map<String, dynamic>>>(
          context: context,
          builder: (_) => SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: snap.docs
                  .map((d) => ListTile(
                        title: Text(
                            (d.data()['stayName'] ?? 'Untitled') as String),
                        subtitle: Text(
                            '${d.data()['city']}, ${d.data()['state']}'),
                        onTap: () => Navigator.pop(context, d),
                      ))
                  .toList(),
            ),
          ),
        );
        if (chosen != null) picked = chosen;
      }

      _docId = picked.id;
      final raw = picked.data()['availabilityPeriods'] as List? ?? [];
      _periods = raw
          .map((e) => AvailabilityPeriod.fromMap(
              Map<String, dynamic>.from(e as Map)))
          .whereType<AvailabilityPeriod>()
          .toList();
    } catch (e) {
      debugPrint('Quick availability load error: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _addPeriod() async {
    final now = DateTime.now();
    final initial = _periods.isNotEmpty
        ? DateTimeRange(
            start: _periods.last.end,
            end: _periods.last.end.add(const Duration(days: 7)))
        : DateTimeRange(
            start: now, end: now.add(const Duration(days: 7)));

    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: initial,
      helpText: 'Pick availability window',
      saveText: 'Add',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.light(primary: Color(0xFFF3BDC3)),
        ),
        child: child!,
      ),
    );

    if (range != null) {
      setState(() {
        _periods
            .add(AvailabilityPeriod(start: range.start, end: range.end));
      });
    }
  }

  void _removePeriod(int index) {
    setState(() => _periods.removeAt(index));
  }

  Future<void> _save() async {
    if (_docId == null) return;
    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('property_listings')
          .doc(_docId)
          .update({
        'availabilityPeriods': _periods.map((p) => p.toMap()).toList(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Availability updated')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Save availability error: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Edit availability',
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
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'When can guests book?',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Add or remove availability windows. Changes save instantly.',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                height: 1.4),
                          ),
                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFFF3BDC3),
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14)),
                              ),
                              onPressed: _addPeriod,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Add window',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),

                          const SizedBox(height: 20),

                          if (_periods.isEmpty)
                            const Padding(
                              padding:
                                  EdgeInsets.symmetric(vertical: 30),
                              child: Center(
                                child: Text(
                                  'No windows yet.\nAdd one above.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black45,
                                      fontSize: 13),
                                ),
                              ),
                            )
                          else
                            ...List.generate(_periods.length, (i) {
                              final p = _periods[i];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0F3),
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  border: Border.all(
                                      color:
                                          const Color(0xFFF3BDC3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                        Icons.calendar_today_rounded,
                                        size: 18,
                                        color: Color(0xFFF3BDC3)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(p.label,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight.w600)),
                                    ),
                                    GestureDetector(
                                      onTap: () => _removePeriod(i),
                                      child: const Icon(Icons.close,
                                          size: 18,
                                          color: Colors.black54),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2),
                              )
                            : const Text('Save availability',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}