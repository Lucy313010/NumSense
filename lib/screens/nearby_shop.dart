import 'package:flutter/material.dart';
import 'app_drawer.dart';
class NearbyShop extends StatelessWidget {
  const NearbyShop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("NumSense"),
        centerTitle: true,
      ),
      //AI implementation
    );
  }
}