import 'package:flutter/material.dart';
import '../../models/property_listing_data.dart';
import 'host_wizard_step4_screen.dart';
import 'wizard_helpers.dart';

class SuitableForOption {
  final String label;
  final IconData icon;
  const SuitableForOption(this.label, this.icon);
}

const List<SuitableForOption> kSuitableForOptions = [
  SuitableForOption('Families', Icons.family_restroom_rounded),
  SuitableForOption('Couples', Icons.favorite_rounded),
  SuitableForOption('Friends', Icons.groups_rounded),
  SuitableForOption('Solo Travelers', Icons.person_rounded),
  SuitableForOption('Business', Icons.work_rounded),
  SuitableForOption('Digital Nomads', Icons.laptop_mac_rounded),
];

class HostWizardStep3Screen extends StatefulWidget {
  final String userName;
  final PropertyListingData data;
  const HostWizardStep3Screen(
      {super.key, required this.userName, required this.data});

  @override
  State<HostWizardStep3Screen> createState() => _HostWizardStep3ScreenState();
}

class _HostWizardStep3ScreenState extends State<HostWizardStep3Screen> {
  final _descController = TextEditingController();
  final _sizeController = TextEditingController();

  int _guests = 2;
  int _bedrooms = 1;
  int _beds = 1;
  int _bathrooms = 1;

  @override
  void initState() {
    super.initState();
    _descController.text = widget.data.shortDescription;
    _sizeController.text = widget.data.propertySize;
    _guests = int.tryParse(widget.data.guests) ?? 2;
    _bedrooms = int.tryParse(widget.data.bedrooms) ?? 1;
    _beds = int.tryParse(widget.data.beds) ?? 1;
    _bathrooms = int.tryParse(widget.data.bathrooms) ?? 1;
  }

  @override
  void dispose() {
    _descController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  void _handleNext() {
    final desc = _descController.text.trim();
    final size = _sizeController.text.trim();

    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a short description')),
      );
      return;
    }
    if (size.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add property size')),
      );
      return;
    }

    widget.data.shortDescription = desc;
    widget.data.propertySize = size;
    widget.data.guests = '$_guests';
    widget.data.bedrooms = '$_bedrooms';
    widget.data.beds = '$_beds';
    widget.data.bathrooms = '$_bathrooms';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HostWizardStep4Screen(userName: widget.userName, data: widget.data),
      ),
    );
  }

  Widget _counterCard({
    required IconData icon,
    required String label,
    required int value,
    required VoidCallback onDec,
    required VoidCallback onInc,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFF3BDC3), size: 26),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onDec,
                icon: const Icon(Icons.remove_circle_outline,
                    color: Color(0xFFF3BDC3)),
              ),
              Text(
                '$value',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onInc,
                icon: const Icon(Icons.add_circle_outline,
                    color: Color(0xFFF3BDC3)),
              ),
            ],
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
                        Icon(Icons.description_outlined,
                            color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Text('About your place',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text('Short description',
                        style:
                            TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descController,
                      maxLines: 4,
                      maxLength: 300,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Tell guests what makes this place special...',
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

                    const SizedBox(height: 24),
                    const Text('Guests & Rooms',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _counterCard(
                            icon: Icons.group_outlined,
                            label: 'Guests',
                            value: _guests,
                            onDec: () =>
                                setState(() => _guests = (_guests - 1).clamp(1, 50)),
                            onInc: () =>
                                setState(() => _guests = (_guests + 1).clamp(1, 50)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _counterCard(
                            icon: Icons.bedroom_parent_outlined,
                            label: 'Bedrooms',
                            value: _bedrooms,
                            onDec: () => setState(
                                () => _bedrooms = (_bedrooms - 1).clamp(0, 30)),
                            onInc: () => setState(
                                () => _bedrooms = (_bedrooms + 1).clamp(0, 30)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _counterCard(
                            icon: Icons.single_bed_outlined,
                            label: 'Beds',
                            value: _beds,
                            onDec: () =>
                                setState(() => _beds = (_beds - 1).clamp(1, 50)),
                            onInc: () =>
                                setState(() => _beds = (_beds + 1).clamp(1, 50)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _counterCard(
                            icon: Icons.bathtub_outlined,
                            label: 'Bathrooms',
                            value: _bathrooms,
                            onDec: () => setState(
                                () => _bathrooms = (_bathrooms - 1).clamp(1, 20)),
                            onInc: () => setState(
                                () => _bathrooms = (_bathrooms + 1).clamp(1, 20)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Text('Property size',
                        style:
                            TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _sizeController,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'e.g. 1200 sq.ft',
                        hintStyle: const TextStyle(color: Colors.black38),
                        prefixIcon: const Icon(Icons.square_foot_rounded,
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

                    const SizedBox(height: 24),
                    const Text('Who is this perfect for?',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: kSuitableForOptions.map((option) {
                        final isSelected =
                            widget.data.suitableFor == option.label;
                        return GestureDetector(
                          onTap: () => setState(
                              () => widget.data.suitableFor = option.label),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFFF0F3)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFF3BDC3)
                                    : Colors.black12,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  option.icon,
                                  size: 18,
                                  color: isSelected
                                      ? const Color(0xFFF3BDC3)
                                      : Colors.black87,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  option.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
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