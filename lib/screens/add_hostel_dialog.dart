import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddHostelDialog extends StatefulWidget {
  const AddHostelDialog({super.key});

  @override
  State<AddHostelDialog> createState() => _AddHostelDialogState();
}

class _AddHostelDialogState extends State<AddHostelDialog> {
  // ================= CONTROLLERS (UNCHANGED) =================
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _floorsController = TextEditingController();

  bool _isLoading = false;

  // ================= FIXED DATABASE LOGIC =================
  Future<void> _createHostel() async {
    // Basic validation (same behavior, no UI change)
    if (_nameController.text.trim().isEmpty ||
        _streetController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _stateController.text.trim().isEmpty ||
        _pincodeController.text.trim().isEmpty ||
        _floorsController.text.trim().isEmpty) {
      return;
    }

    final floors = int.tryParse(_floorsController.text.trim());
    if (floors == null || floors <= 0) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('hostels').add({
        'name': _nameController.text.trim(),

        // REQUIRED BY FIRESTORE RULES
        'ownerId': user.uid,
        'isActive': true,

        // ADDRESS (USED BY HOSTEL LIST)
        'street': _streetController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'address':
            '${_streetController.text.trim()}, '
            '${_cityController.text.trim()}, '
            '${_stateController.text.trim()} - '
            '${_pincodeController.text.trim()}',

        // STRUCTURE
        'floors': floors,

        // META
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ✅ CLOSE DIALOG ONLY ON SUCCESS
      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseException catch (e) {
      // IMPORTANT: log real Firestore error (no UI change)
      debugPrint('🔥 FIRESTORE ERROR CODE: ${e.code}');
      debugPrint('🔥 FIRESTORE ERROR MESSAGE: ${e.message}');
    } catch (e) {
      debugPrint('🔥 UNKNOWN ERROR: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ================= UI (100% UNCHANGED) =================
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 520,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 30,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                      color: const Color(0xFF6C3BFF),
                      title: 'Basic Information',
                    ),
                    const SizedBox(height: 16),

                    _InputField(
                      label: 'Hostel / PG Name *',
                      hint: 'e.g., SmartStay PG – Koramangala',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 14),

                    _InputField(
                      label: 'Street Address *',
                      hint: 'e.g., 123 MG Road',
                      controller: _streetController,
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _InputField(
                            label: 'City *',
                            hint: 'e.g., Bangalore',
                            controller: _cityController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InputField(
                            label: 'State *',
                            hint: 'e.g., Karnataka',
                            controller: _stateController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InputField(
                            label: 'Pincode *',
                            hint: 'e.g., 560001',
                            controller: _pincodeController,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    _SectionTitle(
                      color: const Color(0xFF00B3A4),
                      title: 'Building Structure',
                    ),
                    const SizedBox(height: 16),

                    _InputField(
                      label: 'Number of Floors *',
                      hint: 'e.g., 5',
                      controller: _floorsController,
                      suffix: const Icon(Icons.keyboard_arrow_down),
                    ),

                    const SizedBox(height: 6),
                    const Text(
                      'You’ll be able to configure rooms for each floor in the next step',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6C3BFF), Color(0xFF8E6CFF)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x336C3BFF),
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _createHostel,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text(
                                'Create Hostel',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
/// HEADER (UNCHANGED)
////////////////////////////////////////////////////////////////////////////////

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        gradient: LinearGradient(
          colors: [Color(0xFFF5F2FF), Color(0xFFFFFFFF)],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C3BFF), Color(0xFF8E6CFF)],
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
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
/// SECTION TITLE (UNCHANGED)
////////////////////////////////////////////////////////////////////////////////

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
/// INPUT FIELD (UNCHANGED)
////////////////////////////////////////////////////////////////////////////////

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final Widget? suffix;
  final TextEditingController controller;

  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF6F7FB),
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
