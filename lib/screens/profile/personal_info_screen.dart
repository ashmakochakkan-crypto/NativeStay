import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PersonalInfoScreen extends StatefulWidget {
  final String currentLegalName;
  final String userEmail;
  final String userPhone;
  final Map<String, String> personalData;
  final Function(String) onNameUpdated;
  final Function(Map<String, String>) onDataUpdated;

  const PersonalInfoScreen({
    super.key,
    required this.currentLegalName,
    required this.userEmail,
    required this.userPhone,
    required this.personalData,
    required this.onNameUpdated,
    required this.onDataUpdated,
  });

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late Map<String, String> _infoData;

  @override
  void initState() {
    super.initState();
    _infoData = Map<String, String>.from(widget.personalData);

    if (!_infoData.containsKey('legalName') ||
        _infoData['legalName']!.isEmpty) {
      _infoData['legalName'] = widget.currentLegalName;
    }
    if (!_infoData.containsKey('email') || _infoData['email']!.isEmpty) {
      _infoData['email'] =
          widget.userEmail.isNotEmpty ? widget.userEmail : 'Not provided';
    }
    if (!_infoData.containsKey('phone') || _infoData['phone']!.isEmpty) {
      _infoData['phone'] = widget.userPhone.isNotEmpty
          ? '+91 ${widget.userPhone}'
          : 'Provide phone number';
    }
    _infoData.putIfAbsent('preferredName', () => 'Not provided');
    _infoData.putIfAbsent('address', () => 'Not provided');
    _infoData.putIfAbsent('emergency', () => 'Not provided');
    _infoData.putIfAbsent('identity', () => 'Not started');
  }

  void _openEditModal(String key, String title, String currentVal) {
    final controller = TextEditingController(
      text: (currentVal == 'Not provided' ||
              currentVal == 'Provide phone number')
          ? ''
          : currentVal,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Edit $title',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter $title',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black12)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFF3BDC3))),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3BDC3),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final text = controller.text.trim();
                    setState(() {
                      _infoData[key] = text.isNotEmpty ? text : 'Not provided';
                    });

                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .set({
                        key: text,
                      }, SetOptions(merge: true));
                    }

                    widget.onDataUpdated(_infoData);

                    if ((key == 'legalName' || key == 'preferredName') &&
                        text.isNotEmpty) {
                      widget.onNameUpdated(text);
                    }
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  child: const Text('Save',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(String title, String key, String actionText) {
    final value = _infoData[key] ?? 'Not provided';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _openEditModal(key, title, value),
            child: Text(
              actionText,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  decoration: TextDecoration.underline),
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
              const Text('Personal info',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 20),
              _buildInfoItem('Legal name', 'legalName', 'Edit'),
              const Divider(height: 1, color: Colors.black12),
              _buildInfoItem('Preferred first name', 'preferredName', 'Add'),
              const Divider(height: 1, color: Colors.black12),
              _buildInfoItem('Phone number', 'phone', 'Add'),
              const Divider(height: 1, color: Colors.black12),
              _buildInfoItem('Email', 'email', 'Edit'),
              const Divider(height: 1, color: Colors.black12),
              _buildInfoItem('Residential address', 'address', 'Add'),
              const Divider(height: 1, color: Colors.black12),
              _buildInfoItem('Emergency contact', 'emergency', 'Add'),
              const Divider(height: 1, color: Colors.black12),
              _buildInfoItem('Identity verification', 'identity', 'Start'),
            ],
          ),
        ),
      ),
    );
  }
}