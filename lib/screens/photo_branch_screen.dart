import 'package:flutter/material.dart';
// 1. Add the imports at the top so this file knows your new screens exist
import 'shopping_camera_screen.dart';
import 'calendar_options_screen.dart';

class PhotoBranchScreen extends StatelessWidget {
  const PhotoBranchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("What are we scanning?")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, // Makes buttons equal width
            children: [
              // BUTTON 1: Shopping
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  // 2. This routes the user to your new advanced multi-photo shopping camera
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ShoppingCameraScreen()),
                  );
                },
                child: const Text("Shopping Item"),
              ),
              const SizedBox(height: 24),
              
              // BUTTON 2: Calendar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  // 3. This routes the user to your calendar questions screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CalendarOptionsScreen()),
                  );
                },
                child: const Text("Calendar or Invitation"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}