import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'theme.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/my_hostels_screen.dart';
import 'screens/create_hostel_screen.dart';

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
      debugShowCheckedModeBanner: false,
      title: 'SmartStay',
      theme: AppTheme.lightTheme,

      /// 🔹 Start with Splash Screen
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/admin-dashboard': (context) => const AdminDashboard(),
        '/my-hostels': (context) => const MyHostelsScreen(),
        '/create-hostel': (context) => const CreateHostelScreen(),
      },
    );
  }
}
