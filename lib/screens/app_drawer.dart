import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings_provider.dart';
import 'forum_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

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
              title: const Text("Accessibility Font"),
              secondary: const Icon(Icons.text_fields),
              value: settings.isDyslexiaFontEnabled,
              onChanged: (bool value) {
                Provider.of<SettingsProvider>(context, listen: false).toggleDyslexiaFont(value);
              },
            ),
            if (settings.isDyslexiaFontEnabled)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Select Font",
                    border: OutlineInputBorder(),
                  ),
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