import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'grocery_export_screen.dart';
import 'app_drawer.dart';
class SavedShoppingListsScreen extends StatelessWidget {
  const SavedShoppingListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Shopping Lists'),
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('shopping_lists').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong loading lists.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final lists = snapshot.data?.docs ?? [];

          if (lists.isEmpty) {
            return const Center(child: Text('No saved lists found. Create one!'));
          }

          return ListView.builder(
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final doc = lists[index];
              final data = doc.data() as Map<String, dynamic>;
             
              final title = data['title'] ?? 'Untitled List';
              final items = List<String>.from(data['items'] ?? []);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.ios_share, color: Colors.blueAccent),
                        onPressed: () => GroceryExportService.downloadAndShareList(title, items),
                      ),
                    ],
                  ),
                  subtitle: Text('${items.length} items'),
                  children: items.map((item) => ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(item),
                  )).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}