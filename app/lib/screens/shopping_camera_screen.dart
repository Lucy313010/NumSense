import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ShoppingCameraScreen extends StatefulWidget {
  const ShoppingCameraScreen({super.key});

  @override
  State<ShoppingCameraScreen> createState() => _ShoppingCameraScreenState();
}

class _ShoppingCameraScreenState extends State<ShoppingCameraScreen> {
  final ImagePicker _picker = ImagePicker();
  
  int _targetItemCount = 0;
  bool _isCountConfirmed = false;
  final List<File> _capturedImages = [];
  bool _isAnalyzing = false;
  String? _extractedTextResult;

  Future<void> _captureImage() async {
    if (_capturedImages.length >= _targetItemCount) return;

    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _capturedImages.add(File(photo.path));
      });

      if (_capturedImages.length == _targetItemCount) {
        _simulateAiTextExtraction();
      }
    }
  }

  void _simulateAiTextExtraction() {
    setState(() {
      _isAnalyzing = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isAnalyzing = false;
        _extractedTextResult = "AI EXTRACTION OUTPUT:\n\n"
            "Item 1: Brand X Cereal - \$4.99 (14 oz) -> \$0.35/oz\n"
            "Item 2: Brand Y Cereal - \$6.49 (20 oz) -> \$0.32/oz\n\n"
            "RECOMMENDATION: Brand Y offers the best value per ounce.";
      });
    });
  }

  void _resetScreen() {
    setState(() {
      _targetItemCount = 0;
      _isCountConfirmed = false;
      _capturedImages.clear();
      _extractedTextResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping Analysis"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _resetScreen),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // target count selector input (NEEDS RENAMING)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "How many items are you comparing?",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _isCountConfirmed || _targetItemCount <= 0
                              ? null
                              : () => setState(() => _targetItemCount--),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "$_targetItemCount",
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // FIXED TYPO HERE
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: _isCountConfirmed
                              ? null
                              : () => setState(() => _targetItemCount++),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _targetItemCount > 0 && !_isCountConfirmed
                          ? () => setState(() => _isCountConfirmed = true)
                          : null,
                      child: Text(_isCountConfirmed ? "Count Confirmed" : "Confirm Target Count"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // viewfinder preview
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black87, 
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!_isCountConfirmed)
                    const Text(
                      "Set and confirm item count above\nto unlock camera viewfinder.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    )
                  else if (_capturedImages.length < _targetItemCount)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera, size: 48, color: Colors.white),
                        const SizedBox(height: 8),
                        Text(
                          "Capture Item ${_capturedImages.length + 1} of $_targetItemCount",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                  else
                    const Text(
                      "All pictures captured! Processing...",
                      style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                    ),
                  
                  Positioned(
                    bottom: 16,
                    child: FloatingActionButton(
                      onPressed: _isCountConfirmed && _capturedImages.length < _targetItemCount
                          ? _captureImage
                          : null,
                      backgroundColor: _isCountConfirmed && _capturedImages.length < _targetItemCount
                          ? Colors.blue
                          : Colors.grey,
                      child: const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // capture pic history
            if (_capturedImages.isNotEmpty) ...[
              const Text("Captured Photos:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _capturedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0), // FIXED TYPO HERE
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _capturedImages[index],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              color: Colors.black54,
                              child: Text(
                                "#${index + 1}",
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // AI Results (placeholder for now lol)
            if (_isAnalyzing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            
            if (_extractedTextResult != null)
              Card(
                color: Colors.amber[50],
                shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.amber), borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _extractedTextResult!,
                    style: const TextStyle(fontFamily: 'Courier', fontSize: 13, color: Colors.black87),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}