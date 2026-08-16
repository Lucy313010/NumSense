import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        print("Firebase initialization timed out, continuing anyway.");
        throw Exception("Firebase timeout");
      },
    );
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
  
  runApp(const MyApp());
}