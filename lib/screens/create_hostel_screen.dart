import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateHostelScreen extends StatefulWidget {
  const CreateHostelScreen({super.key});

  @override
  State<CreateHostelScreen> createState() => _CreateHostelScreenState();
}

class _CreateHostelScreenState extends State<CreateHostelScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _rulesController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  Future<void> _saveHostel() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      await FirebaseFirestore.instance.collection('hostels').add({
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'rules': _rulesController.text.trim(),
        'ownerId': user.uid,
        'createdAt': Timestamp.now(),
      });

      // SUCCESS → Go to My Hostels
      Navigator.pushReplacementNamed(context, '/my-hostels');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Hostel')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Hostel / PG Name',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Hostel name is required'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Address is required'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _rulesController,
                label: 'Rules (Optional)',
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveHostel,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Hostel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    );
  }
}
