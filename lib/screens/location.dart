import 'package:flutter/material.dart';
import 'nearby_shop.dart'; // Just use the relative path

class LocationScreen extends StatelessWidget { // Renamed from LoginScreen
  const LocationScreen({super.key}); // Updated constructor

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
            ],
          ),
        ),
      ),
    );
  }
}