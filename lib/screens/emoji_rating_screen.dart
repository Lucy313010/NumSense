import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'home_screen.dart';

class EmojiRatingScreen extends StatefulWidget {
  final String storeName;

  const EmojiRatingScreen({super.key, required this.storeName});

  @override
  State<EmojiRatingScreen> createState() => _EmojiRatingScreenState();
}

class _EmojiRatingScreenState extends State<EmojiRatingScreen> {
  bool _isSubmitting = false;

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/home'),
        builder: (context) => const HomeScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> _submitRating(int ratingScore) async {
    setState(() => _isSubmitting = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception("Location permission is needed to place this store on the map.");
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await FirebaseFirestore.instance.collection('cognitive_ratings').add({
        'storeName': widget.storeName,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'rating': ratingScore,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanks for helping the community! 🩵')),
        );
        _goHome();
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
                  Text("Saving to community map..."),
                ],
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "How was the math environment at ${widget.storeName}?",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Your anonymous rating helps others know what to expect at this store.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "The pin is placed where you are right now, so rate while you're still at the store.",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
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
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: _goHome,
                      child: const Text("Skip for now", style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEmojiButton({
    required String emoji,
    required String title,
    required VoidCallback onPressed,
  }) {
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