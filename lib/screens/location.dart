import 'package:flutter/material.dart';
import 'nearby_shop.dart'; // Make sure the path matches your project

class LocationScreen extends StatelessWidget { // Renamed from LoginScreen
  const LocationScreen({super.key}); // Updated constructor
=======
import 'nearby_shop.dart'; // Make sure the path matches your project

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});
>>>>>>> 673a5c2... made changes on top of Lucy's fixed mlkit code, consolidated my features with hers

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NumSense"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 24)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NearbyShop()));
                },
                child: const Text("What is your location?", style: TextStyle(fontSize: 18)),
              ),
<<<<<<< HEAD
=======
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}