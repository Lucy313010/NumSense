import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'settings_provider.dart';
import 'screens/app_drawer.dart';
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'NumSense',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            // switches globally when the provider state changes
            fontFamily: settings.isDyslexiaFontEnabled ? 'OpenDyslexic' : null,
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}