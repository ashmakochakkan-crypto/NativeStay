import 'package:flutter/material.dart';

class DeactivateReasonScreen extends StatefulWidget {
  final String userName;
  final Future<void> Function() onConfirmDeactivate;

  const DeactivateReasonScreen({
    super.key,
    required this.userName,
    required this.onConfirmDeactivate,
  });

  @override
  State<DeactivateReasonScreen> createState() => _DeactivateReasonScreenState();
}

class _DeactivateReasonScreenState extends State<DeactivateReasonScreen> {
  int? _selectedOption;

  final List<String> _reasons = [
    'I no longer use the app.',
    'I use a different account.',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Why are you choosing to deactivate?',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.2)),
              const SizedBox(height: 24),
              ...List.generate(_reasons.length, (index) {
                final isSelected = _selectedOption == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedOption = index),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFF3BDC3)
                            : Colors.black12,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(_reasons[index],
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black)),
                  ),
                );
              }),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedOption != null
                        ? const Color(0xFFF3BDC3)
                        : Colors.grey.shade200,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _selectedOption != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeactivateConfirmScreen(
                                userName: widget.userName,
                                onConfirmDeactivate: widget.onConfirmDeactivate,
                              ),
                            ),
                          );
                        }
                      : null,
                  child: Text('Continue',
                      style: TextStyle(
                          color: _selectedOption != null
                              ? Colors.black
                              : Colors.black38,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeactivateConfirmScreen extends StatefulWidget {
  final String userName;
  final Future<void> Function() onConfirmDeactivate;

  const DeactivateConfirmScreen({
    super.key,
    required this.userName,
    required this.onConfirmDeactivate,
  });

  @override
  State<DeactivateConfirmScreen> createState() =>
      _DeactivateConfirmScreenState();
}

class _DeactivateConfirmScreenState extends State<DeactivateConfirmScreen> {
  bool _isDeleting = false;

  Widget _buildWarningRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: Colors.black87),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 14, color: Colors.black87, height: 1.3))),
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
        leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Deactivate account?',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                          color: Color(0xFFF3BDC3), shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          widget.userName.isNotEmpty
                              ? widget.userName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(widget.userName,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    const Text('Guest',
                        style: TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _buildWarningRow(Icons.person_off_outlined,
                  'Your profile and listings will no longer be visible.'),
              _buildWarningRow(Icons.block_outlined,
                  'You won\'t be able to access your account or past reservations.'),
              _buildWarningRow(Icons.star_border,
                  'Any reviews you\'ve left or received will stay on other people\'s profiles.'),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: _isDeleting
                      ? null
                      : () async {
                          setState(() => _isDeleting = true);
                          await widget.onConfirmDeactivate();
                          if (!context.mounted) return;
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                  child: _isDeleting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Yes, deactivate',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('No, go back',
                      style: TextStyle(
                          color: Colors.redAccent,
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