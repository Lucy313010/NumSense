import 'dart:io';
import 'package:flutter/material.dart';
import 'cart_manager.dart';
import 'compare_manager.dart';
import 'receipt_parser.dart';
import 'scan_purpose.dart';
import 'app_drawer.dart';
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
  late final TextEditingController _sizeController;
  late String _sizeUnit;

  bool get _isCompare => widget.purpose == ScanPurpose.comparePrice;

  String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialItemName);
    _priceController = TextEditingController(
      text: widget.initialPrice != null ? widget.initialPrice!.toStringAsFixed(2) : "",
    );
    final size = ReceiptParser.parseSize(widget.rawText);
    _sizeController = TextEditingController(text: size != null ? _fmt(size.amount) : "");
    _sizeUnit = size?.unit ?? 'oz';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  void _popBackTo(String routeName) {
    Navigator.of(context).popUntil(
      (route) => route.settings.name == routeName || route.isFirst,
    );
  }

  void _confirm() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    if (price == null || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid item name and price")),
      );
      return;
    }

    if (!_isCompare) {
      CartManager.instance.addItem(CartItem(name: name, price: price));
      _popBackTo('/activeList');
      return;
    }

    final sizeAmount = double.tryParse(_sizeController.text.trim());
    final double? sizeOz = (sizeAmount != null && sizeAmount > 0)
        ? ReceiptParser.toOunces(sizeAmount, _sizeUnit)
        : null;

    CompareManager.instance.add(
      CompareEntry(
        name: name,
        price: price,
        sizeOz: sizeOz,
        sizeLabel: sizeOz != null ? '${_fmt(sizeAmount!)} $_sizeUnit' : null,
      ),
    );
    _popBackTo('/compare');
  }

  @override
  Widget build(BuildContext context) {
    final cleanRawText = ReceiptParser.formatRawTextForUI(widget.rawText);

    return Scaffold(
      appBar: AppBar(title: Text(_isCompare ? "Confirm Item" : "Confirm Details")),
      drawer: const AppDrawer(),
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
              decoration: const InputDecoration(labelText: "Item Name", border: OutlineInputBorder()),
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
            if (_isCompare) ...[
              const SizedBox(height: 16),
              const Text(
                "Size (optional) — lets us compare price per ounce",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _sizeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: "Amount", border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _sizeUnit,
                      decoration: const InputDecoration(labelText: "Unit", border: OutlineInputBorder()),
                      items: ReceiptParser.sizeUnits
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _sizeUnit = value);
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            ExpansionTile(
              title: const Text("Raw scanned text"),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      cleanRawText.isEmpty ? "No text detected" : cleanRawText,
                      style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: _confirm,
              child: Text(_isCompare ? "Add to Comparison" : "Add to Cart"),
            ),
          ],
        ),
      ),
    );
  }
}