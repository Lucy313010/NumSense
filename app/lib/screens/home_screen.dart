import 'package:flutter/material.dart';
import 'my_stuff_screen.dart';
import 'calculator_screen.dart';
import 'shopping_camera_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("NumSense")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ShoppingCameraScreen()));
              },
              child: const Text("Snap a Photo"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyStuffScreen()));
              },
              child: const Text("My Stuff"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CalculatorScreen()));
              },
              child: const Text("Calculator"),
            ),
          ],
        ),
      ),
    );
  }
}