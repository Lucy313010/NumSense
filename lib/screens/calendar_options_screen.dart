import 'package:flutter/material.dart';
import 'shopping_camera_screen.dart'; // We'll just route it here temporarily for testing

class CalendarOptionsScreen extends StatelessWidget {
  const CalendarOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calendar Options")),
      body: const Center(
        child: Text("Calendar options coming soon!"),
      ),
    );
  }
}