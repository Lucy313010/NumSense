import 'package:flutter/material.dart';
import 'compare_manager.dart';
import 'compare_results_screen.dart';
import 'scan_purpose.dart';
import 'shopping_camera_screen.dart';

class CompareItemsScreen extends StatelessWidget {
  const CompareItemsScreen({super.key});

  String _subtitle(CompareEntry e) {
    final perOz = e.pricePerOz;
    if (e.sizeLabel == null || perOz == null) {
      return "No size — comparing shelf price only";
    }
    return "${e.sizeLabel} · \$${perOz.toStringAsFixed(3)}/oz";
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CompareEntry>>(
      valueListenable: CompareManager.instance.entries,
      builder: (context, entries, _) {
        final bool canCompare = entries.length >= 2;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Compare Prices"),
            actions: [
              if (entries.isNotEmpty)
                TextButton(
                  onPressed: CompareManager.instance.clear,
                  child: const Text("Clear"),
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Scan the price tag of each item you want to compare (at least 2).",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: entries.isEmpty
                      ? const Center(
                          child: Text(
                            "No items scanned yet.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(entry.name),
                                subtitle: Text(_subtitle(entry)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '\$${entry.price.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                                      onPressed: () => CompareManager.instance.removeAt(index),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_camera),
                  label: Text(entries.isEmpty ? "Scan First Item" : "Scan Another Item"),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ShoppingCameraScreen(
                          captureType: "Price Tag",
                          purpose: ScanPurpose.comparePrice,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: canCompare
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CompareResultsScreen()),
                          );
                        }
                      : null,
                  child: Text(canCompare ? "Compare ${entries.length} Items" : "Scan at least 2 items"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}