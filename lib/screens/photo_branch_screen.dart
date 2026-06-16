import 'package:flutter/material.dart';
import 'shopping_camera_screen.dart';

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                 
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ShoppingCameraScreen(captureType: "Shopping Item")),
                  );
                },
                child: const Text("Shopping Item"),
              ),
              const SizedBox(height: 24),
              
        
            ],
          ),
        ),
      ),
    );
  }
}