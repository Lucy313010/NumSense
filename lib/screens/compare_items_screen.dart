import 'package:flutter/material.dart';

class CompareItemsScreen extends StatelessWidget {
  const CompareItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Compare Shopping Items")),
      body: const Center(
        child: Text("Compare Items Flow Screen"),
      ),
    );
  }
}