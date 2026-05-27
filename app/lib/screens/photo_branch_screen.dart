import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoBranchScreen extends StatefulWidget {
  const PhotoBranchScreen({super.key});

  @override
  State<PhotoBranchScreen> createState() => _PhotoBranchScreenState();
}

class _PhotoBranchScreenState extends State<PhotoBranchScreen> {
  File? _selectedImage; 
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePicture() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedImage = File(photo.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Snap a Photo")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedImage != null)
              Image.file(_selectedImage!, height: 300, width: 300, fit: BoxFit.cover)
            else
              Container(
                height: 300,
                width: 300,
                color: Colors.grey[300],
                child: const Icon(Icons.camera_alt, size: 50, color: Colors.grey),
              ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              onPressed: _takePicture,
              child: const Text("Open Camera"),
            ),
          ],
        ),
      ),
    );
  }
}