import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'saved_shopping_lists.dart';
import 'active_shopping_list_screen.dart';
import 'compare_items_screen.dart';
import 'compare_manager.dart';
import 'login_screen.dart';
import 'community_map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final bool isGuest = user?.isAnonymous ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("NumSense"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (isGuest)
            Container(
              color: Colors.orangeAccent.withOpacity(0.2),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "You're shopping as a guest! Create an account to save your lists permanently.",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text("Sign Up"),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
                      onPressed: () {
                        CompareManager.instance.clear();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(name: '/compare'),
                            builder: (context) => const CompareItemsScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Snap A Photo -\nCompare Prices",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MasterShoppingListsScreen()),
                        );
                      },
                      child: const Text("Past Shopping Items", style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(name: '/activeList'),
                            builder: (context) => const ActiveShoppingListScreen(),
                          ),
                        );
                      },
                      child: const Text("Start Shopping", style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.map_outlined),
                      label: const Text("Community Safe Map", style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CommunityMapScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}