// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'screens/login_screen.dart';  // Import the LoginScreen here

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized
  Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812), 
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Ajio Mart',
          theme: ThemeData(
            primarySwatch: Colors.green,
          ),
          home: LoginScreen(), // Set LoginScreen as the home screen
        );
      },
    );
  }
}
