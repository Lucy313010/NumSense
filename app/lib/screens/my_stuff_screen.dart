import 'package:flutter/material.dart';
import 'shopping_tabs_screen.dart';
import 'calendar_view_screen.dart';

class MyStuffScreen extends StatelessWidget {
  const MyStuffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Stuff")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ShoppingTabsScreen()));
              },
              child: const Text("Shopping"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarViewScreen()));
              },
              child: const Text("Calendar"),
            ),
          ],
        ),
      ),
    );
  }
}