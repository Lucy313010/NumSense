import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'cart_manager.dart';
import 'budget_manager.dart';
import 'compare_manager.dart'; 
import 'scan_purpose.dart';
import 'custom_app_bar.dart';

class ConfirmTextScreen extends StatefulWidget {
  final File imageFile;
  final String rawText;
  final String initialItemName;
  final double? initialPrice;
  final bool priceInferred;
  final ScanPurpose purpose;

  const ConfirmTextScreen({
    super.key,
    required this.imageFile,
    required this.rawText,
    required this.initialItemName,
    this.initialPrice,
    required this.priceInferred,
    required this.purpose,
  });

  @override
  State<ConfirmTextScreen> createState() => _ConfirmTextScreenState();
}

class _ConfirmTextScreenState extends State<ConfirmTextScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialItemName);
    _priceController = TextEditingController(
      text: widget.initialPrice != null ? widget.initialPrice!.toStringAsFixed(2) : "",
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _confirmAction() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());

    if (name.isEmpty || price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid name and price.")),
      );
      return;
    }


    if (widget.purpose == ScanPurpose.comparePrice) {
      CompareManager.instance.add(
        CompareEntry(
          name: name,
          price: price,
          imageFile: widget.imageFile, 
        ),
      );

      Navigator.of(context).popUntil(
        (route) => route.settings.name == '/compare' || route.isFirst,
      );
      return;
    }


    final remainingBudget = BudgetManager.instance.budget.value;
    if (price > remainingBudget) {
      HapticFeedback.heavyImpact();
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text("Not enough money"),
            ],
          ),
          content: Text(
            "You only have \$${remainingBudget.toStringAsFixed(2)} left, but this item costs \$${price.toStringAsFixed(2)}.\n\nWould you like to stop shopping and go to checkout?",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.of(context).popUntil(
                  (route) => route.settings.name == '/activeList' || route.isFirst,
                );
              },
              child: const Text("Go to Checkout"),
            ),
          ],
        ),
      );
      return;
    }

    CartManager.instance.addItem(CartItem(name: name, price: price));
    Navigator.of(context).popUntil(
      (route) => route.settings.name == '/activeList' || route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
  
    final bool isComparing = widget.purpose == ScanPurpose.comparePrice;

    return Scaffold(
      appBar: const CustomAppBar(title: "Confirm Scanned Item"),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                widget.imageFile,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "We read this from your photo — edit anything that looks wrong.",
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Item Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_bag_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Price",
                prefixText: "\$ ",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            if (widget.priceInferred) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "We guessed the decimal point from the price tag — please double check this.",
                        style: TextStyle(color: Colors.orange, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: Icon(isComparing ? Icons.compare : Icons.add_shopping_cart),
              label: Text(
                isComparing ? "Save to Compare List" : "Add to Cart", 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _confirmAction,
            ),
          ],
        ),
      ),
    );
  }
}