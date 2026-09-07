import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'home_screen.dart';

class EmojiRatingScreen extends StatefulWidget {
  final double initialBudget;
  const EmojiRatingScreen({super.key, required this.initialBudget});

  @override
  State<EmojiRatingScreen> createState() => _EmojiRatingScreenState();
}

class _EmojiRatingScreenState extends State<EmojiRatingScreen> {
  bool _isSubmitting = false;

  Future<void> _submitRating(int ratingScore) async {
    setState(() => _isSubmitting = true);

    try {
      // Ask for location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Location permission needed to map this store.");
        }
      }

      // Get exact GPS coordinates
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Save to Firestore (anonymous & community Shared)
      await FirebaseFirestore.instance.collection('cognitive_ratings').add({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'rating': ratingScore,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanks for helping the community! 🩵')),
        );
        
        // Route back to home screen (Fixed: removed initialBudget)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving rating: $e')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Checkout Complete")),
      body: Center(
        child: _isSubmitting
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Saving to community map...")
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "How was the math environment here?",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Your anonymous rating helps others know what to expect at this store.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    _buildEmojiButton(
                      emoji: "🟢",
                      title: "Clear tags, easy to navigate",
                      onPressed: () => _submitRating(1),
                    ),
                    const SizedBox(height: 16),

                    _buildEmojiButton(
                      emoji: "🟡",
                      title: "A bit busy, manageable",
                      onPressed: () => _submitRating(2),
                    ),
                    const SizedBox(height: 16),

                    _buildEmojiButton(
                      emoji: "🔴",
                      title: "Confusing math, high stress",
                      onPressed: () => _submitRating(3),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEmojiButton({required String emoji, required String title, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black87,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}