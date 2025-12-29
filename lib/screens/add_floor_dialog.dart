import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFloorDialog extends StatefulWidget {
  final String hostelId;

  const AddFloorDialog({super.key, required this.hostelId});

  @override
  State<AddFloorDialog> createState() => _AddFloorDialogState();
}

class _AddFloorDialogState extends State<AddFloorDialog> {
  final TextEditingController _floorNumberController = TextEditingController();
  final TextEditingController _floorNameController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Center(
          child: Container(
            width: 420,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.94),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 30,
                  offset: Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [_header(context), _body(context)],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────── HEADER ─────────────────
  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00BFA5), Color(0xFF80DEEA)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.layers, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Add New Floor',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ───────────────── BODY ─────────────────
  Widget _body(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Floor Number *'),
          const SizedBox(height: 6),
          _inputField(
            controller: _floorNumberController,
            hint: 'e.g., 1',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 18),
          _label('Floor Name *'),
          const SizedBox(height: 6),
          _inputField(
            controller: _floorNameController,
            hint: 'e.g., Ground Floor',
          ),
          const SizedBox(height: 14),
          const Text(
            'You’ll be able to add rooms and configure sharing options for this floor in the next step',
            style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 22),
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
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addFloor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009688),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Add Floor',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────── FIRESTORE LOGIC ─────────────────
  Future<void> _addFloor() async {
    if (_floorNameController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    final hostelRef = FirebaseFirestore.instance
        .collection('hostels')
        .doc(widget.hostelId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final hostelSnap = await transaction.get(hostelRef);

      final currentFloors = hostelSnap['floors'] ?? 0;
      final newFloorIndex = currentFloors;

      final floorRef = hostelRef.collection('floors').doc();

      transaction.set(floorRef, {
        'floorIndex': newFloorIndex,
        'floorName': _floorNameController.text.trim(),
        'totalRooms': 0,
        'occupiedRooms': 0,
        'totalBeds': 0,
        'occupiedBeds': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.update(hostelRef, {'floors': currentFloors + 1});
    });

    if (mounted) Navigator.pop(context);
  }

  // ───────────────── HELPERS ─────────────────
  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    );
  }

  Widget _inputField({
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF009688)),
        ),
      ),
    );
  }
}
