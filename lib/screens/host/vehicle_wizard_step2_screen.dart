import 'package:flutter/material.dart';
import '../../models/vehicle_listing.dart';
import '../rentals/rental_vehicles.dart';
import 'vehicle_wizard_step3_screen.dart';
import 'wizard_helpers.dart';

class VehicleWizardStep2Screen extends StatefulWidget {
  final VehicleListingData data;
  const VehicleWizardStep2Screen({super.key, required this.data});

  @override
  State<VehicleWizardStep2Screen> createState() =>
      _VehicleWizardStep2ScreenState();
}

class _VehicleWizardStep2ScreenState extends State<VehicleWizardStep2Screen> {
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _regController = TextEditingController();
  final _colorController = TextEditingController();
  final _seatsController = TextEditingController();
  final _luggageController = TextEditingController();
  final _mileageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _makeController.text = widget.data.make;
    _modelController.text = widget.data.model;
    _yearController.text = widget.data.year;
    _regController.text = widget.data.registrationNumber;
    _colorController.text = widget.data.color;
    _seatsController.text = widget.data.seats;
    _luggageController.text = widget.data.luggage;
    _mileageController.text = widget.data.mileage;
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _regController.dispose();
    _colorController.dispose();
    _seatsController.dispose();
    _luggageController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_makeController.text.trim().isEmpty ||
        _modelController.text.trim().isEmpty) {
      _snack('Please enter make and model');
      return;
    }
    if (_yearController.text.trim().isEmpty) {
      _snack('Please enter the year');
      return;
    }
    if (_regController.text.trim().isEmpty) {
      _snack('Please enter registration number');
      return;
    }

    widget.data.make = _makeController.text.trim();
    widget.data.model = _modelController.text.trim();
    widget.data.year = _yearController.text.trim();
    widget.data.registrationNumber = _regController.text.trim();
    widget.data.color = _colorController.text.trim();
    widget.data.seats = _seatsController.text.trim().isEmpty
        ? '4'
        : _seatsController.text.trim();
    widget.data.luggage = _luggageController.text.trim().isEmpty
        ? '2'
        : _luggageController.text.trim();
    widget.data.mileage = _mileageController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleWizardStep3Screen(data: widget.data),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38),
            prefixIcon: Icon(icon, color: const Color(0xFFF3BDC3)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFF3BDC3), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _dropdownRow({
    required String label,
    required List<String> items,
    required String value,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFFF3BDC3)),
              items:
                  items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => onChanged(v!),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
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
                        Icon(Icons.directions_car_rounded,
                            color: Color(0xFFF3BDC3), size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Vehicle specs',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tell travelers about your vehicle',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 20),

                    const Text('Vehicle type *',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: kVehicleTypes.length,
                      itemBuilder: (context, index) {
                        final t = kVehicleTypes[index];
                        final isSelected = widget.data.vehicleType == t.label;
                        return GestureDetector(
                          onTap: () => setState(
                              () => widget.data.vehicleType = t.label),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFFF0F3)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFF3BDC3)
                                    : Colors.black12,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  t.icon,
                                  size: 30,
                                  color: isSelected
                                      ? const Color(0xFFF3BDC3)
                                      : Colors.black87,
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: Text(
                                    t.label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Colors.black12),
                    const SizedBox(height: 20),

                    _field(
                      controller: _makeController,
                      label: 'Make *',
                      hint: 'e.g. Toyota',
                      icon: Icons.factory_outlined,
                    ),
                    _field(
                      controller: _modelController,
                      label: 'Model *',
                      hint: 'e.g. Innova Crysta',
                      icon: Icons.directions_car_outlined,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            controller: _yearController,
                            label: 'Year *',
                            hint: 'e.g. 2021',
                            icon: Icons.calendar_today_rounded,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            controller: _colorController,
                            label: 'Color',
                            hint: 'e.g. White',
                            icon: Icons.palette_outlined,
                          ),
                        ),
                      ],
                    ),
                    _field(
                      controller: _regController,
                      label: 'Registration number *',
                      hint: 'e.g. HP 01 AB 1234',
                      icon: Icons.confirmation_number_outlined,
                    ),

                    _dropdownRow(
                      label: 'Fuel type',
                      items: kFuelTypes,
                      value: widget.data.fuelType,
                      onChanged: (v) => setState(() => widget.data.fuelType = v),
                    ),
                    _dropdownRow(
                      label: 'Transmission',
                      items: kTransmissionTypes,
                      value: widget.data.transmission,
                      onChanged: (v) =>
                          setState(() => widget.data.transmission = v),
                    ),
                    _dropdownRow(
                      label: 'AC / Non-AC',
                      items: kAcTypes,
                      value: widget.data.acType,
                      onChanged: (v) => setState(() => widget.data.acType = v),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            controller: _seatsController,
                            label: 'Seats',
                            hint: 'e.g. 7',
                            icon: Icons.event_seat_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            controller: _luggageController,
                            label: 'Luggage',
                            hint: 'e.g. 3',
                            icon: Icons.luggage_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    _field(
                      controller: _mileageController,
                      label: 'Mileage / range',
                      hint: 'e.g. 14 km/l or 250 km',
                      icon: Icons.speed_rounded,
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