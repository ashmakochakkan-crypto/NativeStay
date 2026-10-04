import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/booking_service.dart';

class BookingSheet extends StatefulWidget {
  final String listingId;
  final String listingType; // 'homestay' | 'guide' | 'vehicle'
  final String listingName;
  final String listingPhoto;
  final String hostId;
  final String hostName;
  final String pricePerNightOrDay;
  final String pricingSuffix;

  const BookingSheet({
    super.key,
    required this.listingId,
    required this.listingType,
    required this.listingName,
    required this.listingPhoto,
    required this.hostId,
    required this.hostName,
    required this.pricePerNightOrDay,
    this.pricingSuffix = ' / night',
  });

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet> {
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _adults = 1;
  int _children = 0;
  int _rooms = 1;
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  double get _unitPrice =>
      double.tryParse(widget.pricePerNightOrDay.replaceAll(',', '')) ?? 0;

  bool get _isSingleDay => widget.listingType != 'homestay';

  int get _nights {
    if (_checkIn == null || _checkOut == null) return 0;
    return _checkOut!.difference(_checkIn!).inDays.clamp(0, 365);
  }

  int get _billedUnits => _nights == 0 ? 1 : _nights;

  double get _total => _unitPrice * _billedUnits;

  String get _unitLabel {
    if (_checkIn == null || _checkOut == null) return '';
    if (_isSingleDay) {
      return 'x $_billedUnits day${_billedUnits > 1 ? 's' : ''}';
    }
    return _nights > 0
        ? 'x $_nights night${_nights > 1 ? 's' : ''}'
        : '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) {
    final m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _pickDate(bool isIn) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isIn
          ? (_checkIn ?? now)
          : (_checkOut ?? (_checkIn ?? now).add(const Duration(days: 1))),
      firstDate: isIn ? now : (_checkIn ?? now),
      lastDate: now.add(const Duration(days: 730)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: Color(0xFFF3BDC3)),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isIn) {
        _checkIn = picked;
        if (_checkOut != null && _checkOut!.isBefore(picked)) {
          _checkOut = picked.add(const Duration(days: 1));
        }
      } else {
        _checkOut = picked;
      }
    });
  }

  void _showError(String msg) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent),
            SizedBox(width: 10),
            Text('Booking failed'),
          ],
        ),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('OK', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    debugPrint('BOOKING: _submit tapped');

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError('You must be logged in to book.');
      return;
    }
    if (widget.hostId == user.uid) {
      _showError("You can't book your own listing.");
      return;
    }
    if (_checkIn == null || _checkOut == null) {
      _showError(_isSingleDay
          ? 'Please pick both dates.'
          : 'Please pick check-in and check-out dates.');
      return;
    }
    if (_isSingleDay) {
      if (_checkOut!.isBefore(_checkIn!)) {
        _showError('End date must be on or after start date.');
        return;
      }
    } else {
      if (_nights <= 0) {
        _showError('Check-out must be after check-in.');
        return;
      }
    }

    setState(() => _isSubmitting = true);
    try {
      debugPrint(
          'BOOKING: creating... listing=${widget.listingId} host=${widget.hostId}');
      final id = await BookingService.create(
        listingId: widget.listingId,
        listingType: widget.listingType,
        listingName: widget.listingName,
        listingPhoto: widget.listingPhoto,
        hostId: widget.hostId,
        hostName: widget.hostName,
        checkIn: _checkIn!,
        checkOut: _checkOut!,
        adults: _adults,
        children: _children,
        rooms: _rooms,
        totalPrice: _total.toStringAsFixed(0),
        paymentMethod: 'Pay on arrival',
        notes: _notesController.text.trim(),
      );
      debugPrint('BOOKING: created doc=$id');

      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('Request sent'),
            ],
          ),
          content: Text(
            'Your booking request for "${widget.listingName}" has been sent to ${widget.hostName}.\n\nYou\'ll pay on arrival once the host confirms.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('OK',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e, st) {
      debugPrint('BOOKING ERROR: $e\n$st');
      if (mounted) _showError('Could not send request:\n\n$e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _counter(
      String label, int val, VoidCallback onDec, VoidCallback onInc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        Row(
          children: [
            IconButton(
              onPressed: onDec,
              icon: const Icon(Icons.remove_circle_outline,
                  color: Color(0xFFF3BDC3)),
            ),
            Text('$val',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: onInc,
              icon: const Icon(Icons.add_circle_outline,
                  color: Color(0xFFF3BDC3)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dateTile(String label, DateTime? val, VoidCallback onTap,
      {bool showClear = false, VoidCallback? onClear}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 18, color: Color(0xFFF3BDC3)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(
                    val == null ? 'Select date' : _fmt(val),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          val == null ? FontWeight.normal : FontWeight.bold,
                      color: val == null ? Colors.black38 : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            if (showClear && val != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close,
                    size: 18, color: Colors.black54),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Request to book',
                style:
                    TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(widget.listingName,
                style:
                    const TextStyle(fontSize: 13, color: Colors.black54)),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _dateTile(
                    _isSingleDay ? 'From date' : 'Check-in',
                    _checkIn,
                    () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _dateTile(
                    _isSingleDay ? 'To date' : 'Check-out',
                    _checkOut,
                    () => _pickDate(false),
                    showClear: true,
                    onClear: () => setState(() => _checkOut = null),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (widget.listingType == 'homestay') ...[
              _counter('Adults', _adults,
                  () { if (_adults > 1) setState(() => _adults--); },
                  () => setState(() => _adults++)),
              _counter('Children', _children,
                  () { if (_children > 0) setState(() => _children--); },
                  () => setState(() => _children++)),
              _counter('Rooms', _rooms,
                  () { if (_rooms > 1) setState(() => _rooms--); },
                  () => setState(() => _rooms++)),
              const SizedBox(height: 8),
            ],

            TextField(
              controller: _notesController,
              maxLines: 3,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Message to host (optional)',
                hintStyle: const TextStyle(color: Colors.black38),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: Color(0xFFF3BDC3), width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7FA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFCE4EC)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                          '₹${_unitPrice.toStringAsFixed(0)}${widget.pricingSuffix}',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black87)),
                      const Spacer(),
                      Text(
                        _unitLabel,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: Colors.black12),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('₹${_total.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE91E63))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      Icon(Icons.payments_outlined,
                          size: 14, color: Colors.black54),
                      SizedBox(width: 6),
                      Text('Payment: Cash on stay',
                          style: TextStyle(
                              fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3BDC3),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2))
                    : const Text('Send booking request',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}