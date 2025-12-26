import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/custom_textfield.dart';
import '../widgets/forgot_password_dialog.dart';
import '../widgets/gradient_button.dart';
import 'admin_dashboard.dart';
import 'resident_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// TAB STATE
  bool isLoginTab = true;
  bool isLoading = false;

  /// ROLE
  String selectedRole = 'resident';

  /// LOGIN CONTROLLERS
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  /// REGISTER CONTROLLERS
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // ================= AUTH LOGIC =================

  Future<void> loginUser() async {
    setState(() => isLoading = true);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text.trim(),
      );

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .get();

      final role = userDoc['role'];

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => role == 'admin'
              ? const AdminDashboard()
              : const ResidentDashboard(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => isLoading = false);
  }

  Future<void> registerUser() async {
    setState(() => isLoading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
            'name': nameController.text.trim(),
            'email': emailController.text.trim(),
            'phone': phoneController.text.trim(),
            'role': selectedRole,
          });

      setState(() => isLoginTab = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => isLoading = false);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF0FF), Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [_header(), const SizedBox(height: 24), _authCard()],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF6C3BFF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.apartment, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 12),
        const Text(
          'SmartStay',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _authCard() {
    return Container(
      width: 420,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _tabs(),
          const SizedBox(height: 20),
          _roleSelector(),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: isLoginTab ? _loginForm() : _registerForm(),
          ),
        ],
      ),
    );
  }

  // ================= TABS =================

  Widget _tabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _tab('Login', true),
        const SizedBox(width: 32),
        _tab('Register', false),
      ],
    );
  }

  Widget _tab(String label, bool loginTab) {
    final active = isLoginTab == loginTab;
    return GestureDetector(
      onTap: () => setState(() => isLoginTab = loginTab),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
              color: active ? const Color(0xFF6C3BFF) : Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          if (active)
            Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF6C3BFF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  // ================= ROLE SELECTOR =================

  Widget _roleSelector() {
    return Row(
      children: [
        _roleButton('resident', 'Resident', Icons.person),
        const SizedBox(width: 12),
        _roleButton('admin', 'Admin', Icons.admin_panel_settings),
      ],
    );
  }

  Widget _roleButton(String role, String label, IconData icon) {
    final selected = selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: role == 'resident' && selected
                ? const Color(0xFF3CCFCF)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: role == 'admin' && selected
                  ? const Color(0xFF6C3BFF)
                  : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? (role == 'resident'
                          ? Colors.white
                          : const Color(0xFF6C3BFF))
                    : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? (role == 'resident'
                            ? Colors.white
                            : const Color(0xFF6C3BFF))
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= FORMS =================

  Widget _loginForm() {
    return Column(
      key: const ValueKey('login'),
      children: [
        CustomTextField(
          controller: loginEmailController,
          label: 'Email',
          hintText: 'your.email@example.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: loginPasswordController,
          label: 'Password',
          hintText: '••••••••',
          isPassword: true,
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const ForgotPasswordDialog(),
            ),
            child: const Text('Forgot password?'),
          ),
        ),
        const SizedBox(height: 10),
        GradientButton(
          text: 'Sign In',
          isLoading: isLoading,
          onPressed: loginUser,
        ),
      ],
    );
  }

  Widget _registerForm() {
    return Column(
      key: const ValueKey('register'),
      children: [
        CustomTextField(
          controller: nameController,
          label: 'Full Name',
          hintText: 'Enter your full name',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: emailController,
          label: 'Email',
          hintText: 'your.email@example.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: phoneController,
          label: 'Phone Number',
          hintText: '+91 00000 00000',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: passwordController,
          label: 'Password',
          hintText: '••••••••',
          isPassword: true,
        ),
        const SizedBox(height: 20),
        GradientButton(
          text: 'Create Account',
          isLoading: isLoading,
          onPressed: registerUser,
        ),
      ],
    );
  }
}
