import 'package:flutter/material.dart';
import 'dart:io';
import 'compare_manager.dart';
import 'compare_results_screen.dart';
import 'scan_purpose.dart';
import 'shopping_camera_screen.dart';
import 'app_drawer.dart';
import 'custom_app_bar.dart';

class CompareItemsScreen extends StatelessWidget {
  const CompareItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CompareEntry>>(
      valueListenable: CompareManager.instance.entries,
      builder: (context, entries, _) {
        final bool canCompare = entries.length >= 2;

        return Scaffold(
          drawer: const AppDrawer(),
          appBar: const CustomAppBar(title: "Compare Prices"),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                if (entries.isNotEmpty)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: CompareManager.instance.clear,
                      child: const Text("Clear All"),
                    ),
                  ),
                  
          
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.compare_arrows, size: 80, color: Colors.blueAccent),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.photo_camera, size: 28),
                          label: Text(
                            entries.isEmpty ? "Scan First Item" : "Scan Another Item",
                            style: const TextStyle(fontSize: 20)
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
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
                        const SizedBox(height: 16),
                        const Text(
                          "Scan as many price tags as you want.",
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                ),

                if (entries.isNotEmpty) ...[
                  const Text("Scanned Items:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140, 
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 12),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: entry.imageFile != null
                                      ? Image.file(entry.imageFile!, fit: BoxFit.cover)
                                      : Container(color: Colors.grey[300], child: const Icon(Icons.image)),
                                ),
                              ),
                              
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [Colors.black87, Colors.transparent],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                right: 8,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('\$${entry.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    Text(entry.name, style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => CompareManager.instance.removeAt(index),
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.close, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: canCompare ? Colors.black : Colors.grey[300],
                    foregroundColor: canCompare ? Colors.white : Colors.grey[600],
                  ),
                  onPressed: canCompare
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CompareResultsScreen()),
                          );
                        }
                      : null,
                  child: Text(
                    canCompare ? "Compare Prices (${entries.length} Items)" : "Scan at least 2 items to compare",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}