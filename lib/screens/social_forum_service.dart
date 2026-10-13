import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class SocialForumService {
  
  static const String facebookPageToken = 'EAAYEN0VPieMBSi98v5JaPOJnh3m4NiclE3ZB3JEpZB1WeNJI45Y4sZA5xO2VOEf8rKSbAWZALTGM8sGyRaZAvjq2ZBuaXZCZAahZCQZA6N3TX2ml6JvuCCen5G4nxHw9OWMLZBh5oxW8BOucmvJh0PuyAErHZCZC6tEl00NrpMpLtwPVohwhwEnwumluUOpnqxGPRkQZDZD';
  static const String facebookPageId = '61595011569085';

  static Future<void> publishToAllPlatforms({
    required String title,
    required String content,
    required String authorId,
  }) async {
    
    // post to in app forum (firebase)
    await FirebaseFirestore.instance.collection('forum_posts').add({
      'title': title,
      'content': content,
      'authorId': authorId,
      'createdAt': FieldValue.serverTimestamp(),
      'platform': 'NumSense',
    });

    // cross post to facebook
    await _postToFacebook(title, content);
  }

  static Future<void> _postToFacebook(String title, String content) async {
    try {
      final url = Uri.parse('https://graph.facebook.com/v19.0/$facebookPageId/feed');
      final response = await http.post(
        url,
        body: {
          'message': '$title\n\n$content',
          'access_token': facebookPageToken,
        },
      );
      if (response.statusCode != 200) print('Facebook Error: ${response.body}');
    } catch (e) {
      print('Facebook Exception: $e');
    }
  }
}