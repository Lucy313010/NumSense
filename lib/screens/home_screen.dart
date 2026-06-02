import 'package:flutter/material.dart';
import 'compare_items_screen.dart';
import 'past_shopping_screen.dart';
import 'active_shopping_list_screen.dart';
import 'shopping_camera_screen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ShoppingCameraScreen(captureType: 'item'),));
                },
                child: const Text("Snap A Photo -\nCompare Prices", textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 24)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PastShoppingScreen()));
                },
                child: const Text("Past Shopping Items", style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 24)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ActiveShoppingListScreen()));
                },
                child: const Text("Start Shopping", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}