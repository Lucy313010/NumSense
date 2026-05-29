import 'package:flutter/material.dart';

class ShoppingTabsScreen extends StatelessWidget {
  const ShoppingTabsScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shopping")),
      body: const Center(child: Text("Shopping UI goes here")),
    );
  }
}