import 'package:cloud_firestore/cloud_firestore.dart';

class SocialForumService {
  static Future<void> publishToAllPlatforms({
    required String title,
    required String content,
    required String authorId,
  }) async {
    // post to in-app forum (Firebase)
    await FirebaseFirestore.instance.collection('forum_posts').add({
      'title': title,
      'content': content,
      'authorId': authorId,
      'createdAt': FieldValue.serverTimestamp(),
      'platform': 'NumSense',
    });
  }
}