import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:poultry_app/screens/start/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Initializing Firebase...');

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyAclkKEMjBb2dQLYpg4OtYyM1a18OGUqUY",
            authDomain: "esp32-e0a40.firebaseapp.com",
            databaseURL: "https://esp32-e0a40-default-rtdb.asia-southeast1.firebasedatabase.app",
            projectId: "esp32-e0a40",
            storageBucket: "esp32-e0a40.firebasestorage.app",
            messagingSenderId: "599759290685",
            appId: "1:599759290685:web:f54df0838f46f2e9bbc554",
            measurementId: "G-V65BQGMNQ9"
        ),
      );
    } else {
      await Firebase.initializeApp();
    }

    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
