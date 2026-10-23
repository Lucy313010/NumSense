import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../settings_provider.dart';
import 'saved_shopping_lists.dart';
import 'active_shopping_list_screen.dart';
import 'compare_items_screen.dart';
import 'compare_manager.dart';
import 'login_screen.dart';
import 'community_map_screen.dart';
import 'forum_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final bool isGuest = user?.isAnonymous ?? false;
    final settings = Provider.of<SettingsProvider>(context);

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
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  "Accessibility Font",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Switch(
                                value: settings.isDyslexiaFontEnabled,
                                activeColor: Colors.blueAccent,
                                onChanged: (bool value) {
                                  Provider.of<SettingsProvider>(context, listen: false).toggleDyslexiaFont(value);
                                },
                              ),
                            ],
                          ),
                          if (settings.isDyslexiaFontEnabled) ...[
                            const Divider(),
                            DropdownButton<String>(
                              isExpanded: true,
                              value: settings.selectedFont,
                              items: settings.availableFonts.map((font) {
                                return DropdownMenuItem(value: font, child: Text(font));
                              }).toList(),
                              onChanged: (String? newFont) {
                                if (newFont != null) {
                                  Provider.of<SettingsProvider>(context, listen: false).setSelectedFont(newFont);
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // NEW: Profile & History Button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent.withOpacity(0.1),
                            foregroundColor: Colors.blueAccent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.blueAccent.withOpacity(0.3), width: 2),
                            ),
                          ),
                          icon: const Icon(Icons.person, size: 28),
                          label: const Text(
                            "View Profile & History",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ProfileScreen()),
                            );
                          },
                        ),
                      ),
                    ),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text(
                        "Start Shopping\n(Quick Add)", 
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, height: 1.2),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(name: '/activeList'),
                            builder: (context) => const ActiveShoppingListScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      ),
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
                        style: TextStyle(fontSize: 16, height: 1.2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.map_outlined),
                      label: const Text(
                        "Community Safe Map", 
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
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
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.forum_outlined),
                      label: const Text(
                        "Community Forum", 
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForumScreen()),
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