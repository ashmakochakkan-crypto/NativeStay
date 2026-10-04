import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../services/review_service.dart';
import '../booking/booking_detail_screen.dart';

class RateReviewSheet extends StatefulWidget {
  final Booking booking;
  final bool alreadyReviewed;
  const RateReviewSheet({
    super.key,
    required this.booking,
    required this.alreadyReviewed,
  });

  @override
  State<RateReviewSheet> createState() => _RateReviewSheetState();
}

class _RateReviewSheetState extends State<RateReviewSheet> {
  int _rating = 0;
  final _textCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please tap a star to rate')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await ReviewService.create(
        listingId: widget.booking.listingId,
        listingType: widget.booking.listingType,
        bookingId: widget.booking.docId,
        hostId: widget.booking.hostId,
        rating: _rating,
        text: _textCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanks for your review! ⭐')),
      );
    } catch (e) {
      debugPrint('Review submit error: $e');
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not submit: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
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

            if (widget.alreadyReviewed) ...[
              Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.green, size: 26),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('You already reviewed this stay',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Thanks again! Your review is already on the listing.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => BookingDetailScreen(booking: b)),
                    );
                  },
                  child: const Text('View booking details',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: b.listingPhoto.isNotEmpty
                          ? Image.network(b.listingPhoto,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFFFFF0F3),
                                    child: const Icon(
                                        Icons.home_work_rounded,
                                        color: Color(0xFFF3BDC3)),
                                  ))
                          : Container(
                              color: const Color(0xFFFFF0F3),
                              child: const Icon(Icons.home_work_rounded,
                                  color: Color(0xFFF3BDC3)),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.listingName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(b.dateRangeLabel,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text('How was your stay?',
                  style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Rate your experience and share a few words.',
                  style: TextStyle(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFCE4EC)),
                ),
                child: Column(
                  children: [
                    const Text('Tap to rate',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final star = i + 1;
                        return GestureDetector(
                          onTap: () => setState(() => _rating = star),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              star <= _rating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              size: 40,
                              color: star <= _rating
                                  ? const Color(0xFFE91E63)
                                  : Colors.black26,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _rating == 0
                          ? '—'
                          : _rating == 1
                              ? 'Poor'
                              : _rating == 2
                                  ? 'Fair'
                                  : _rating == 3
                                      ? 'Good'
                                      : _rating == 4
                                          ? 'Very good'
                                          : 'Excellent!',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE91E63)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text('Share your experience (optional)',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _textCtrl,
                maxLines: 5,
                maxLength: 500,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText:
                      'Clean place? Great host? Anything future guests should know...',
                  hintStyle: const TextStyle(color: Colors.black38),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: Color(0xFFF3BDC3), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Submit review',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}