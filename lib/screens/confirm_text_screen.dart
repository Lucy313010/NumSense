import 'dart:io';
import 'package:flutter/material.dart';
import 'cart_manager.dart';
import 'scan_purpose.dart';

class ConfirmTextScreen extends StatefulWidget {
  final File imageFile;
  final String rawText;
  final String initialItemName;
  final double? initialPrice;
  final ScanPurpose purpose;

  const ConfirmTextScreen({
    super.key,
    required this.imageFile,
    required this.rawText,
    required this.initialItemName,
    required this.initialPrice,
    required this.purpose,
  });

  @override
  State<ConfirmTextScreen> createState() => _ConfirmTextScreenState();
}

class _ConfirmTextScreenState extends State<ConfirmTextScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;

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

  void _confirm() {
    final price = double.tryParse(_priceController.text.trim());
    if (price == null || _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid item name and price")),
      );
      return;
    }

    if (widget.purpose == ScanPurpose.addToCart) {
      CartManager.instance.addItem(
        CartItem(name: _nameController.text.trim(), price: price),
      );
      Navigator.of(context).popUntil(ModalRoute.withName('/activeList'));
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Scanned Result"),
          content: Text("${_nameController.text.trim()}\n\$${price.toStringAsFixed(2)}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).popUntil(ModalRoute.withName('/home')),
              child: const Text("Done"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Details")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(widget.imageFile, height: 180, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            const Text(
              "We read this from your photo — edit anything that looks wrong.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Item Name",
                border: OutlineInputBorder(),
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
              ),
            ),
            const SizedBox(height: 24),
            ExpansionTile(
              title: const Text("Raw scanned text"),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    widget.rawText.isEmpty ? "No text detected" : widget.rawText,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: _confirm,
              child: Text(
                widget.purpose == ScanPurpose.addToCart ? "Add to Cart" : "Show Result",
              ),
            ),
          ],
        ),
      ),
    );
  }
}