import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'confirm_text_screen.dart';

class ShoppingCameraScreen extends StatefulWidget {
  final String captureType; 

  const ShoppingCameraScreen({super.key, required this.captureType});

  @override
  State<ShoppingCameraScreen> createState() => _ShoppingCameraScreenState();
}

class _ShoppingCameraScreenState extends State<ShoppingCameraScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _capturedImage;
  bool _isAnalyzing = false;

  Future<void> _captureSingleImage() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _capturedImage = File(photo.path);
      });
      _analyzeImage();
    }
  }

  void _analyzeImage() {
    setState(() {
      _isAnalyzing = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ConfirmTextScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan ${widget.captureType}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Please capture the ${widget.captureType.toLowerCase()}",
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
                child: _capturedImage == null
                    ? const Icon(Icons.camera_alt, size: 64, color: Colors.white38)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_capturedImage!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 30),
            
            if (_isAnalyzing)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_camera),
                label: Text(_capturedImage == null ? "Take Photo" : "Retake Photo"),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: _captureSingleImage,
              ),
          ],
        ),
      ),
    );
  }
}