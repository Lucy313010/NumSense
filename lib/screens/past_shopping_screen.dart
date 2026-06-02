import 'package:flutter/material.dart';

class PastShoppingScreen extends StatelessWidget {
  const PastShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Past Shopping Items")),
      body: const Center(
        child: Text("Past Shopping Items Flow Screen"),
      ),
    );
  }
}