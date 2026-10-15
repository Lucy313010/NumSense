import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings_provider.dart';
import 'forum_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'NumSense Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text("Dyslexia Friendly Font"),
              secondary: const Icon(Icons.text_fields),
              value: Provider.of<SettingsProvider>(context).isDyslexiaFontEnabled,
              onChanged: (bool value) {
                Provider.of<SettingsProvider>(context, listen: false).toggleDyslexiaFont(value);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.forum_outlined, color: Colors.blueAccent),
              title: const Text("Community Forum"),
              onTap: () {
                Navigator.pop(context); 
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ForumScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}