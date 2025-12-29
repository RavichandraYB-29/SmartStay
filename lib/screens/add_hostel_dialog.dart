import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddHostelDialog extends StatefulWidget {
  const AddHostelDialog({super.key});

  @override
  State<AddHostelDialog> createState() => _AddHostelDialogState();
}

class _AddHostelDialogState extends State<AddHostelDialog> {
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _floorsController = TextEditingController();

  bool _isLoading = false;

  // 🔒 LOGIC — UNCHANGED
  Future<void> _createHostel() async {
    if (_nameController.text.trim().isEmpty ||
        _streetController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _stateController.text.trim().isEmpty ||
        _pincodeController.text.trim().isEmpty ||
        _floorsController.text.trim().isEmpty)
      return;

    final floors = int.tryParse(_floorsController.text.trim());
    if (floors == null || floors <= 0) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final hostelRef = await FirebaseFirestore.instance.collection('hostels').add({
        'name': _nameController.text.trim(),
        'ownerId': user.uid,
        'isActive': true,
        'street': _streetController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'address':
            '${_streetController.text.trim()}, ${_cityController.text.trim()}, ${_stateController.text.trim()} - ${_pincodeController.text.trim()}',
        'floors': floors,
        'totalRooms': 0,
        'occupiedRooms': 0,
        'totalBeds': 0,
        'occupiedBeds': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final batch = FirebaseFirestore.instance.batch();
      for (int i = 0; i < floors; i++) {
        batch.set(hostelRef.collection('floors').doc(), {
          'floorIndex': i,
          'totalRooms': 0,
          'occupiedRooms': 0,
          'totalBeds': 0,
          'occupiedBeds': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🎨 UI — UPDATED TO MATCH FIGMA
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF9FAFF), Colors.white],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),

            _section('Basic Information'),
            _field(
              _nameController,
              'Hostel / PG Name',
              'SmartStay PG - Koramangala',
            ),
            _field(_streetController, 'Street Address', '123 MG Road'),

            Row(
              children: [
                Expanded(child: _field(_cityController, 'City', 'Bangalore')),
                const SizedBox(width: 12),
                Expanded(child: _field(_stateController, 'State', 'Karnataka')),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(_pincodeController, 'Pincode', '560001'),
                ),
              ],
            ),

            const SizedBox(height: 22),
            _section('Building Structure'),
            _field(
              _floorsController,
              'Number of Floors',
              '5',
              suffix: const Icon(Icons.keyboard_arrow_down),
            ),

            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _createHostel,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Hostel'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF6C3BFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===== UI HELPERS =====

  Widget _header() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C3BFF), Color(0xFF9B5CFF)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.apartment, color: Colors.white),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Add New Hostel / PG',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6C3BFF),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String hint, {
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: suffix,
          filled: true,
          fillColor: const Color(0xFFF6F7FB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
