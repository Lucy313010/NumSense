import 'package:flutter/material.dart';
import 'shopping_camera_screen.dart';
import 'scan_purpose.dart';
import 'weight_item_screen.dart';

class AddItemOptionsScreen extends StatelessWidget {
  const AddItemOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Item Details")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const Text(
              "How would you like to log this item?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShoppingCameraScreen(
                      captureType: "Price Tag",
                      purpose: ScanPurpose.addToCart,
                    ),
                  ),
                );
              },
              child: const Text("Add Item by Fixed Price"),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              "Add Item by Weight:",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.scale),
              label: const Text("Scan Price Tag & Weigh Item"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WeightItemScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}