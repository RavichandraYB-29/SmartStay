import 'dart:ui';
import 'package:flutter/material.dart';

class AddRoomDialog extends StatefulWidget {
  /// ✅ REQUIRED TO FIX hostelId ERROR
  final String hostelId;

  const AddRoomDialog({super.key, required this.hostelId});

  @override
  State<AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<AddRoomDialog> {
  int selectedSharing = 1;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 440,
              maxHeight: 600, // ✅ prevents overflow
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.96),
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
                children: [
                  _header(context),

                  /// ✅ SCROLLABLE BODY
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(22),
                      child: _body(context),
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
  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
            child: const Icon(Icons.meeting_room, color: Colors.white),
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

  // ───────────────── BODY CONTENT ─────────────────
  Widget _body(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Room Number *'),
        const SizedBox(height: 6),
        _inputField(hint: 'e.g., 101'),

        const SizedBox(height: 18),

        _label('Sharing Type *'),
        const SizedBox(height: 10),

        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _sharingTile(1, 'Single Sharing'),
            _sharingTile(2, 'Double Sharing'),
            _sharingTile(3, 'Triple Sharing'),
            _sharingTile(4, 'Four Sharing'),
          ],
        ),

        const SizedBox(height: 8),
        const Text(
          'This determines how many beds will be in the room',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),

        const SizedBox(height: 18),

        _label('Monthly Rent per Bed *'),
        const SizedBox(height: 6),
        _inputField(
          hint: '5000',
          prefix: '₹',
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 6),
        const Text(
          'This is the rent amount per bed per month',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),

        const SizedBox(height: 24),

        /// ✅ BUTTONS — NO OVERFLOW
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
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
                onPressed: () {
                  // 🔥 Firestore will use widget.hostelId later
                  // FirebaseFirestore.instance
                  //   .collection('hostels')
                  //   .doc(widget.hostelId)
                  //   .collection('rooms')
                  //   .add({...});

                  Navigator.pop(context);
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Add Room',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEC4899),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ───────────────── SHARING TILE ─────────────────
  Widget _sharingTile(int value, String label) {
    final bool isSelected = selectedSharing == value;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => selectedSharing = value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF3E8FF)
              : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFB145FF) : Colors.grey.shade300,
            width: 1.4,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFB145FF), Color(0xFFEC4899)],
                      )
                    : null,
                color: isSelected ? null : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$value',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ───────────────── HELPERS ─────────────────
  Widget _label(String text) => Text(
    text,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
  );

  Widget _inputField({
    required String hint,
    String? prefix,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixText: prefix,
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
          borderSide: const BorderSide(color: Color(0xFFB145FF)),
        ),
      ),
    );
  }
}
