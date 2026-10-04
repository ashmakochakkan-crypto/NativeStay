import 'package:flutter/material.dart';
import '../../models/property_listing_data.dart';
import 'host_wizard_step7_screen.dart';
import 'wizard_helpers.dart';

class HostWizardStep6Screen extends StatefulWidget {
  final String userName;
  final PropertyListingData data;
  const HostWizardStep6Screen(
      {super.key, required this.userName, required this.data});

  @override
  State<HostWizardStep6Screen> createState() => _HostWizardStep6ScreenState();
}

class _HostWizardStep6ScreenState extends State<HostWizardStep6Screen> {
  final _privateAreasController = TextEditingController();
  final List<AvailabilityPeriod> _periods = [];

  @override
  void initState() {
    super.initState();
    _privateAreasController.text = widget.data.privateAreas;
    for (final p in widget.data.availabilityPeriods) {
      final parsed = AvailabilityPeriod.fromMap(p);
      if (parsed != null) _periods.add(parsed);
    }
  }

  Future<void> _addPeriod() async {
    final now = DateTime.now();
    final initial = _periods.isNotEmpty
        ? DateTimeRange(
            start: _periods.last.end,
            end: _periods.last.end.add(const Duration(days: 7)))
        : DateTimeRange(start: now, end: now.add(const Duration(days: 7)));

    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: initial,
      helpText: 'Pick availability window',
      saveText: 'Add',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFF3BDC3)),
        ),
        child: child!,
      ),
    );

    if (range != null) {
      setState(() {
        _periods.add(AvailabilityPeriod(start: range.start, end: range.end));
      });
    }
  }

  void _removePeriod(int index) {
    setState(() => _periods.removeAt(index));
  }

  void _handleNext() {
    widget.data.privateAreas = _privateAreasController.text.trim();
    widget.data.availabilityPeriods =
        _periods.map((p) => p.toMap()).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HostWizardStep7Screen(
            userName: widget.userName, data: widget.data),
      ),
    );
  }

  Widget _yesNoToggle({
    required String label,
    required String value,
    required Function(String) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 12),
          Row(
            children: ['Yes', 'No'].map((option) {
              final isSelected = value == option;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(option),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF3BDC3) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFF3BDC3)
                            : Colors.black12,
                      ),
                    ),
                    child: Center(
                      child: Text(option,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.black
                                  : Colors.black54)),
                    ),
                  ),
                ),
              );
            }).toList(),
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
                        Icon(Icons.people_outline,
                            color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Stay, Sharing & Availability',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('When can guests book your place?',
                        style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        const Icon(Icons.event_available_rounded,
                            color: Color(0xFFF3BDC3), size: 24),
                        const SizedBox(width: 8),
                        const Text('Availability windows *',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _addPeriod,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Add one or more date ranges when your place is open for bookings. You can update this any time.',
                      style: TextStyle(
                          fontSize: 12, color: Colors.black54, height: 1.4),
                    ),
                    const SizedBox(height: 12),

                    if (_periods.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7FA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFCE4EC)),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.event_busy_rounded,
                                size: 36, color: Colors.black26),
                            SizedBox(height: 8),
                            Text('No availability set yet',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54)),
                            SizedBox(height: 4),
                            Text('Tap "Add" above to set when guests can book',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black45)),
                          ],
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
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: const Color(0xFFF3BDC3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 18, color: Color(0xFFF3BDC3)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(p.label,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ),
                              GestureDetector(
                                onTap: () => _removePeriod(i),
                                child: const Icon(Icons.close,
                                    size: 18, color: Colors.black54),
                              ),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: 32),
                    const Divider(height: 1, color: Colors.black12),
                    const SizedBox(height: 20),

                    _yesNoToggle(
                      label: 'Is the host/family living in the property?',
                      value: widget.data.liveWithHost,
                      onChanged: (v) =>
                          setState(() => widget.data.liveWithHost = v),
                    ),
                    _yesNoToggle(
                      label: 'Will guests share the property with the host/family?',
                      value: widget.data.shareProperty,
                      onChanged: (v) =>
                          setState(() => widget.data.shareProperty = v),
                    ),
                    _yesNoToggle(
                      label: 'Are other roommates/guests staying there?',
                      value: widget.data.haveRoommates,
                      onChanged: (v) =>
                          setState(() => widget.data.haveRoommates = v),
                    ),

                    const Text('Which areas are private for the guest?',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _privateAreasController,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'e.g. Bedroom, bathroom, balcony',
                        hintStyle: const TextStyle(color: Colors.black38),
                        prefixIcon: const Icon(Icons.lock_outline,
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
                  ],
                ),
              ),
            ),
            WizardBottomBar(
              onPrevious: () => Navigator.pop(context),
              onNext: _handleNext,
            ),
          ],
        ),
      ),
    );
  }
}