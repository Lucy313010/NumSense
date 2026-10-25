import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'receipt_parser.dart';
import 'cart_manager.dart';
import 'budget_manager.dart'; 
import 'app_drawer.dart';
import 'image_crop_helper.dart';
import 'custom_app_bar.dart';

enum _WeightStep { priceTag, scaleWeight, confirm }

class WeightItemScreen extends StatefulWidget {
 const WeightItemScreen({super.key});

 @override
 State<WeightItemScreen> createState() => _WeightItemScreenState();
}

class _WeightItemScreenState extends State<WeightItemScreen> {
 final ImagePicker _picker = ImagePicker();
 final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

 _WeightStep _step = _WeightStep.priceTag;
 bool _isAnalyzing = false;
 bool _priceWasInferred = false;

 File? _priceTagImage;
 File? _scaleImage;

 late final TextEditingController _nameController;
 late final TextEditingController _pricePerUnitController;
 late final TextEditingController _weightController;

 @override
 void initState() {
   super.initState();
   _nameController = TextEditingController(text: "Scanned Item");
   _pricePerUnitController = TextEditingController();
   _weightController = TextEditingController();
 }

 @override
 void dispose() {
   _textRecognizer.close();
   _nameController.dispose();
   _pricePerUnitController.dispose();
   _weightController.dispose();
   super.dispose();
 }

 double get _totalPrice {
   final pricePerUnit = double.tryParse(_pricePerUnitController.text.trim()) ?? 0;
   final weight = double.tryParse(_weightController.text.trim()) ?? 0;
   return pricePerUnit * weight;
 }

 Future<void> _captureAndAnalyze({required bool isPriceTag}) async {
   final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
   if (photo == null) return;

   final croppedFile = await ImageCropHelper.cropForOcr(photo.path);
   if (croppedFile == null) return;

   setState(() {
     _isAnalyzing = true;
     if (isPriceTag) {
       _priceTagImage = croppedFile;
     } else {
       _scaleImage = croppedFile;
     }
   });

   String rawText = "";
   final List<TextLineInfo> lineInfos = [];
   try {
     final inputImage = InputImage.fromFile(croppedFile);
     final recognizedText = await _textRecognizer.processImage(inputImage);
     rawText = recognizedText.text;
     for (final block in recognizedText.blocks) {
       for (final line in block.lines) {
         lineInfos.add(TextLineInfo(line.text, line.boundingBox.height.toDouble()));
       }
     }
   } catch (e) {
     rawText = "";
   }

   if (!mounted) return;

   if (isPriceTag) {
     final parsed = ReceiptParser.parse(rawText, lines: lineInfos);
     _nameController.text = parsed.itemName;
     _pricePerUnitController.text = parsed.price != null ? parsed.price!.toStringAsFixed(2) : "";
     setState(() {
       _priceWasInferred = parsed.priceInferred;
       _isAnalyzing = false;
       _step = _WeightStep.scaleWeight;
     });
   } else {
     final weight = ReceiptParser.parseWeight(rawText);
     _weightController.text = weight != null ? weight.toStringAsFixed(2) : "";
     setState(() {
       _isAnalyzing = false;
       _step = _WeightStep.confirm;
     });
   }
 }

 void _confirmAndAddToCart() {
   final pricePerUnit = double.tryParse(_pricePerUnitController.text.trim());
   final weight = double.tryParse(_weightController.text.trim());
   final name = _nameController.text.trim();

   if (pricePerUnit == null || weight == null || name.isEmpty) {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text("Enter a valid item name, price per lb/oz, and weight")),
     );
     return;
   }

   final totalPrice = pricePerUnit * weight;
   final remainingBudget = BudgetManager.instance.budget.value;

   if (totalPrice > remainingBudget) {
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
           "You only have \$${remainingBudget.toStringAsFixed(2)} left, but this item costs \$${totalPrice.toStringAsFixed(2)}.\n\nWould you like to stop shopping and go to checkout?",
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


   CartManager.instance.addItem(
     CartItem(name: name, price: totalPrice),
   );
   Navigator.of(context).popUntil(
     (route) => route.settings.name == '/activeList' || route.isFirst,
   );
 }

 @override
 Widget build(BuildContext context) {
   return PopScope(
     canPop: _step == _WeightStep.priceTag,
     onPopInvokedWithResult: (didPop, result) {
       if (didPop) return;
       setState(() {
         _step = _step == _WeightStep.confirm ? _WeightStep.scaleWeight : _WeightStep.priceTag;
       });
     },
     child: _buildCurrentStep(),
   );
 }

 Widget _buildCurrentStep() {
   switch (_step) {
     case _WeightStep.priceTag:
       return _buildCaptureStep(
         title: "Scan Price Tag",
         instructions: "Capture the price-per-lb/oz tag",
         image: _priceTagImage,
         onCapture: () => _captureAndAnalyze(isPriceTag: true),
       );
     case _WeightStep.scaleWeight:
       return _buildCaptureStep(
         title: "Scan Scale Weight",
         instructions: "Place the item on the scale and capture the weight display",
         image: _scaleImage,
         onCapture: () => _captureAndAnalyze(isPriceTag: false),
       );
     case _WeightStep.confirm:
       return _buildConfirmStep();
   }
 }

 Widget _buildCaptureStep({
   required String title,
   required String instructions,
   required File? image,
   required VoidCallback onCapture,
 }) {
   return Scaffold(
     appBar: AppBar(title: Text(title)),
     drawer: const AppDrawer(),
     body: Padding(
       padding: const EdgeInsets.all(24.0),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.stretch,
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Text(
             instructions,
             textAlign: TextAlign.center,
             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
           ),
           const SizedBox(height: 30),
           AspectRatio(
             aspectRatio: 4 / 3,
             child: Container(
               decoration: BoxDecoration(
                 color: Colors.black87,
                 borderRadius: BorderRadius.circular(16),
               ),
               child: image == null
                   ? const Icon(Icons.camera_alt, size: 64, color: Colors.white38)
                   : ClipRRect(
                       borderRadius: BorderRadius.circular(16),
                       child: Image.file(image, fit: BoxFit.cover),
                     ),
             ),
           ),
           const SizedBox(height: 30),
           if (_isAnalyzing)
             const Center(child: CircularProgressIndicator())
           else
             ElevatedButton.icon(
               icon: const Icon(Icons.photo_camera),
               label: Text(image == null ? "Take Photo" : "Retake Photo"),
               style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
               onPressed: onCapture,
             ),
         ],
       ),
     ),
   );
 }

 Widget _buildConfirmStep() {
   return Scaffold(
     appBar: const CustomAppBar(title: "Confirm Weighted Item"),
     body: Padding(
       padding: const EdgeInsets.all(24.0),
       child: ListView(
         children: [
           Row(
             children: [
               if (_priceTagImage != null)
                 Expanded(
                   child: ClipRRect(
                     borderRadius: BorderRadius.circular(12),
                     child: Image.file(_priceTagImage!, height: 100, fit: BoxFit.cover),
                   ),
                 ),
               const SizedBox(width: 8),
               if (_scaleImage != null)
                 Expanded(
                   child: ClipRRect(
                     borderRadius: BorderRadius.circular(12),
                     child: Image.file(_scaleImage!, height: 100, fit: BoxFit.cover),
                   ),
                 ),
             ],
           ),
           const SizedBox(height: 20),
           const Text(
             "We read this from your photos — edit anything that looks wrong.",
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
             controller: _pricePerUnitController,
             keyboardType: const TextInputType.numberWithOptions(decimal: true),
             onChanged: (_) => setState(() {}),
             decoration: const InputDecoration(
               labelText: "Price per lb/oz",
               prefixText: "\$ ",
               border: OutlineInputBorder(),
             ),
           ),
           if (_priceWasInferred) ...[
             const SizedBox(height: 8),
             const Text(
               "We guessed the decimal point from the price tag — double check this.",
               style: TextStyle(color: Colors.orange, fontSize: 13),
             ),
           ],
           const SizedBox(height: 16),
           TextField(
             controller: _weightController,
             keyboardType: const TextInputType.numberWithOptions(decimal: true),
             onChanged: (_) => setState(() {}),
             decoration: const InputDecoration(
               labelText: "Weight (lb/oz)",
               border: OutlineInputBorder(),
             ),
           ),
           const SizedBox(height: 24),
           Center(
             child: Text(
               "Total: \$${_totalPrice.toStringAsFixed(2)}",
               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
             ),
           ),
           const SizedBox(height: 32),
           ElevatedButton(
             style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
             onPressed: _confirmAndAddToCart,
             child: const Text("Add to Cart"),
           ),
         ],
       ),
     ),
   );
 }
}