import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'custom_textfield.dart';
import 'gradient_button.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final emailController = TextEditingController();
  bool isLoading = false;

  // ================= UTIL =================

  void _showMessage(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? const Color(0xFF3CCFCF) : Colors.black87,
      ),
    );
  }

  // ================= LOGIC =================

  Future<void> sendResetLink() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Please enter your email');
      return;
    }

    if (!email.contains('@')) {
      _showMessage('Enter a valid email address');
      return;
    }

    setState(() => isLoading = true);

    try {
      /// 🔍 CHECK IF EMAIL EXISTS IN FIRESTORE
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        _showMessage('No account found with this email');
        setState(() => isLoading = false);
        return;
      }

      /// ✅ SEND RESET EMAIL
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      Navigator.pop(context);
      _showMessage('Password reset link sent to your email', success: true);
    } on FirebaseAuthException catch (_) {
      _showMessage('Unable to send reset link. Try again later');
    } catch (_) {
      _showMessage('Something went wrong. Please try again');
    }

    setState(() => isLoading = false);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reset Password',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter your registered email address',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              CustomTextField(
                controller: emailController,
                label: 'Email',
                hintText: 'your.email@example.com',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  TextButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 140,
                    child: GradientButton(
                      text: 'Send Link',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : sendResetLink,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
