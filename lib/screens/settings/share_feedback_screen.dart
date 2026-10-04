import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ShareFeedbackScreen extends StatefulWidget {
  const ShareFeedbackScreen({super.key});

  @override
  State<ShareFeedbackScreen> createState() => _ShareFeedbackScreenState();
}

class _ShareFeedbackScreenState extends State<ShareFeedbackScreen> {
  String? _selectedCategory;
  String? _selectedTopic;
  final TextEditingController _detailsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  final Map<String, List<String>> _feedbackOptions = {
    'Hosting (Homestays)': [
      'Creating a new property listing',
      'Uploading photos & amenities',
      'Setting nightly price & cleaning fees',
      'Managing availability calendar & blocked dates',
      'Guest booking confirmations & cancellations',
      'In-app messaging with guests',
      'Host payout & bank settings',
      'House rules & check-in guidelines',
    ],
    'Vehicle Rentals': [
      'Listing a car or motorbike',
      'Setting pickup & drop-off locations',
      'Vehicle specs, fuel policy & transmission',
      'Rental pricing & security deposits',
      'Driver license & ID verification',
      'Vehicle availability & calendar',
      'Vehicle condition & damage reporting',
    ],
    'Tour Guides (Local Experts)': [
      'Creating local tour experiences',
      'Setting itinerary highlights & activities',
      'Group size limits & tour duration',
      'Schedule availability & booking slots',
      'Tour guide badge & ID verification',
      'Tour pricing & guide earnings',
    ],
    'Traveling, Search & Booking': [
      'Destination search & auto-complete',
      'Date pickers (Check-in & Check-out)',
      'Guests & rooms counter (Adults/Children/Rooms)',
      'Home dashboard category filters (Homestays, Experiences, Cuisines)',
      'Trips screen & booking history',
      'Wishlists & saved favorites (Heart icon)',
      'Help & Support AI Chatbot',
    ],
    'Account, Profile & App Performance': [
      'Profile details (Bio, Song, Born year, etc.)',
      'Interest tags selection',
      'Personal info editing (Legal name, Phone, Email)',
      'Login & security (Password / Deactivation)',
      'App speed, bugs or crashing issues',
      'General feedback & feature requests',
    ],
  };

  void _showRadioSelectionModal(String title, List<String> options,
      String? currentVal, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(color: Colors.black12),
              Expanded(
                child: ListView.separated(
                  itemCount: options.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: Colors.black12),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = option == currentVal;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      title: Text(
                        option,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                      trailing: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? const Color(0xFFF3BDC3)
                            : Colors.black38,
                      ),
                      onTap: () {
                        onSelect(option);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitFeedback() async {
    final details = _detailsController.text.trim();

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a feedback category')),
      );
      return;
    }

    if (_selectedTopic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a topic or feature')),
      );
      return;
    }

    if (details.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter feedback details')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('feedbacks').add({
        'userId': user?.uid ?? 'guest_user',
        'userEmail': user?.email ?? 'Not logged in',
        'category': _selectedCategory,
        'topic': _selectedTopic,
        'details': details,
        'submittedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Feedback submitted successfully. Thank you!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
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
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Share your feedback',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 14),
              const Text(
                'Thanks for sending us your ideas, issues, or appreciations. We can\'t respond individually, but we\'ll pass it on to the teams who are working to make our platform better for everyone.\n\nIf you have a specific question or need help resolving a problem, visit our Help Center to connect with our support team.',
                style: TextStyle(
                    fontSize: 14, color: Colors.black87, height: 1.45),
              ),
              const SizedBox(height: 24),

              const Text('What\'s your feedback about?',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showRadioSelectionModal(
                  'Select category',
                  _feedbackOptions.keys.toList(),
                  _selectedCategory,
                  (val) {
                    setState(() {
                      _selectedCategory = val;
                      _selectedTopic = null;
                    });
                  },
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black26),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory ?? 'Please select',
                        style: TextStyle(
                          fontSize: 15,
                          color: _selectedCategory != null
                              ? Colors.black
                              : Colors.black38,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.black),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text('What topic or feature?',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  if (_selectedCategory == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select a category first')),
                    );
                    return;
                  }
                  _showRadioSelectionModal(
                    'Select topic',
                    _feedbackOptions[_selectedCategory] ?? [],
                    _selectedTopic,
                    (val) => setState(() => _selectedTopic = val),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black26),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _selectedTopic ?? 'Choose one',
                          style: TextStyle(
                            fontSize: 15,
                            color: _selectedTopic != null
                                ? Colors.black
                                : Colors.black38,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.black),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text('Add details',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 8),
              TextField(
                controller: _detailsController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText:
                      'Share your feedback, ideas, or what went wrong...',
                  hintStyle:
                      const TextStyle(color: Colors.black38, fontSize: 14),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black26)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFF3BDC3))),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: 140,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3BDC3),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.black, strokeWidth: 2),
                        )
                      : const Text('Submit',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
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