import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'forum_screen.dart';
import 'profile_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: Text(
              'NumSense Menu',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, size: 28),
            title: const Text('Home', style: TextStyle(fontSize: 18)),
            onTap: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const HomeScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, size: 28),
            title: const Text('My Profile & History', style: TextStyle(fontSize: 18)),
            onTap: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.forum, size: 28),
            title: const Text('Community Forum', style: TextStyle(fontSize: 18)),
            onTap: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const ForumScreen()),
            ),
          ),

        ],
      ),
    );
  }
}