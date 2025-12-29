import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'theme.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/resident_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SmartStayApp());
}

class SmartStayApp extends StatelessWidget {
  const SmartStayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartStay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // ✅ Use home instead of initialRoute
      home: const LoginScreen(),

      // ✅ Keep only routes that do NOT need parameters
      routes: {
        '/login': (_) => const LoginScreen(),
        '/admin': (_) => const AdminDashboard(),
        '/resident': (_) => const ResidentDashboard(),
      },
    );
  }
}
