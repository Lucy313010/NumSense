import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

class ImageCropHelper {
  static Future<File?> cropForOcr(String sourcePath) async {
    await _clearOldTempImages();

    final cropped = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop to just the price',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop to just the price',
        ),
      ],
    );
    if (cropped == null) return null;
    return File(cropped.path);
  }

  static Future<void> _clearOldTempImages() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final entries = tempDir.listSync();
      final cutoff = DateTime.now().subtract(const Duration(minutes: 10));

      for (final entity in entries) {
        if (entity is File) {
          final name = entity.path.toLowerCase();
          final looksLikeImage = name.endsWith('.jpg') ||
              name.endsWith('.jpeg') ||
              name.endsWith('.png');
          if (!looksLikeImage) continue;

          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoff)) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
    }
  }
}