import 'package:flutter/material.dart';
import 'cart_manager.dart';
import 'scan_purpose.dart';
import 'shopping_camera_screen.dart';
import 'weight_item_screen.dart';
import 'app_drawer.dart';
class AddItemOptionsScreen extends StatelessWidget {
  const AddItemOptionsScreen({super.key});

  void _showQuickAddSheet(BuildContext screenContext) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    String? errorText;

    showModalBottomSheet(
      context: screenContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Quick Add Item",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Item Name (e.g. Milk, Apples)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.shopping_bag_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: "Price (\$)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 12),
                    Text(errorText!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final name = nameController.text.trim();
                      final price = double.tryParse(priceController.text.trim());
                      if (name.isEmpty || price == null || price <= 0) {
                        setSheetState(() => errorText = "Enter an item name and a price above \$0.");
                        return;
                      }
                      CartManager.instance.addItem(CartItem(name: name, price: price));
                      Navigator.pop(sheetContext);
                      Navigator.pop(screenContext);
                    },
                    child: const Text(
                      "Add directly to cart",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Item Details")),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const Text(
              "How would you like to log this item?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.flash_on, color: Colors.amber, size: 28),
              label: const Text("Quick Add (Type It In)"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => _showQuickAddSheet(context),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShoppingCameraScreen(
                      captureType: "Price Tag",
                      purpose: ScanPurpose.addToCart,
                    ),
                  ),
                );
              },
              child: const Text("Add Item by Fixed Price Scan"),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              "Add Item by Weight:",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.scale),
              label: const Text("Scan Price Tag & Weigh Item"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WeightItemScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}