import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddRoomDialog extends StatefulWidget {
  final String hostelId;
  final String floorId;

  const AddRoomDialog({
    super.key,
    required this.hostelId,
    required this.floorId,
  });

  @override
  State<AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<AddRoomDialog> {
  final TextEditingController _roomNoController = TextEditingController();
  final TextEditingController _bedsController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();

  String _sharingType = 'Single';
  bool _isLoading = false;

  // ✅ SINGLE SOURCE OF TRUTH
  int _getBedsFromSharing() {
    switch (_sharingType) {
      case 'Single':
        return 1;
      case 'Double':
        return 2;
      case 'Triple':
        return 3;
      case '4-Sharing':
        return 4;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔁 keep Total Beds field visually synced (UI unchanged)
    _bedsController.text = _getBedsFromSharing().toString();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 620),
            child: Container(
              width: 440,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                children: [
                  _header(),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                      child: _body(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────── HEADER ─────────────────
  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB145FF), Color(0xFFEC4899)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.bed, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Add New Room',
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
  Widget _body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Room Number *'),
        _input(_roomNoController, 'e.g., 101'),
        const SizedBox(height: 16),

        _label('Sharing Type *'),
        _sharingGrid(),
        const SizedBox(height: 18),

        _label('Total Beds *'),
        _input(_bedsController, 'e.g., 3', keyboard: TextInputType.number),
        const SizedBox(height: 16),

        _label('Monthly Rent per Bed *'),
        _input(_rentController, '₹ 5000', keyboard: TextInputType.number),
        const SizedBox(height: 26),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _addRoom,
                icon: const Icon(Icons.add),
                label: const Text('Add Room'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEC4899),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ───────────────── SHARING GRID ─────────────────
  Widget _sharingGrid() {
    final options = {'Single': 1, 'Double': 2, 'Triple': 3, '4-Sharing': 4};

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: options.entries.map((e) {
        final selected = _sharingType == e.key;

        return InkWell(
          onTap: () {
            setState(() {
              _sharingType = e.key;
              _bedsController.text = e.value.toString(); // sync UI
            });
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? const Color(0xFFEC4899)
                    : Colors.grey.shade300,
                width: selected ? 2 : 1,
              ),
              color: selected ? const Color(0xFFFDF2F8) : Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: selected
                      ? const Color(0xFFEC4899)
                      : Colors.grey.shade200,
                  child: Text(
                    e.value.toString(),
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('${e.key} Sharing'),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ───────────────── FIRESTORE (FIXED) ─────────────────
  Future<void> _addRoom() async {
    if (_roomNoController.text.trim().isEmpty) return;

    final totalBeds = _getBedsFromSharing();

    setState(() => _isLoading = true);

    await FirebaseFirestore.instance
        .collection('hostels')
        .doc(widget.hostelId)
        .collection('floors')
        .doc(widget.floorId)
        .collection('rooms')
        .add({
          'roomNo': _roomNoController.text.trim(),
          'sharingType': _sharingType,
          'totalBeds': totalBeds, // ✅ ALWAYS CORRECT
          'occupiedBeds': 0,
          'rentPerBed': int.parse(_rentController.text),
          'createdAt': FieldValue.serverTimestamp(),
        });

    if (mounted) Navigator.pop(context);
  }

  // ───────────────── HELPERS ─────────────────
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    ),
  );

  Widget _input(
    TextEditingController c,
    String hint, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
