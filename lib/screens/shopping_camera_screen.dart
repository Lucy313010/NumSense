import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'confirm_text_screen.dart';
import 'scan_purpose.dart';
import 'receipt_parser.dart';

class ShoppingCameraScreen extends StatefulWidget {
  final String captureType;
  final ScanPurpose purpose;

  const ShoppingCameraScreen({super.key, required this.captureType, required this.purpose});

  @override
  State<ShoppingCameraScreen> createState() => _ShoppingCameraScreenState();
}

class _ShoppingCameraScreenState extends State<ShoppingCameraScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  File? _capturedImage;
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _captureSingleImage() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final file = File(photo.path);
      setState(() {
        _capturedImage = file;
      });
      await _analyzeImage(file);
    }
  }

Future<void> _analyzeImage(File imageFile) async {
    if (_capturedImage == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    String rawText = "";
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      rawText = recognizedText.text;
    } catch (e) {
      rawText = "";
    }

    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
    });

    final parsed = ReceiptParser.parse(rawText);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmTextScreen(
          imageFile: imageFile,
          rawText: rawText,
          initialItemName: parsed.itemName,
          initialPrice: parsed.price,
          purpose: widget.purpose,
        ),
      ),
    );
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
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text("AI is reading the text...")
                ],
              )
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