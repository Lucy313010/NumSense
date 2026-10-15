import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class SocialForumService {
  
  static const String facebookPageToken = 'EAAYEN0VPieMBSgxQcflAH7RlnMEx4P3wDnvJ9maIJLgECRHHSb1NWzF2OjXphcn3zG2rjUox1GUlMw3g4OhmHAuR0d8dKahEJNzISCzrGbZAMArtOOhw4B2SJeZA7oI1Ao4nlFcJX6qM08kYHJzZABwcIKSV68bddWipKRgqAloBxBGAyN34fI7ZA7cuiYFcrEebjtrt3vZBz2HG9XPDWIxVEw8HxRTSCraVlACSt4mfFw7BBNTjgBZCUb9q1xJGNQXuKQFZBI2FhyDXTuemJGu';
  static const String facebookPageId = '1274315972440873';

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
    print('--- INITIATING FACEBOOK POST ---');
    try {
      final url = Uri.parse('https://graph.facebook.com/v19.0/$facebookPageId/feed');
      print('1. Target URL: $url');
      
      final response = await http.post(
        url,
        body: {
          'message': '$title\n\n$content',
          'access_token': facebookPageToken,
        },
      );
      
      print('2. HTTP Status Code: ${response.statusCode}');
      print('3. Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('--- FACEBOOK POST SUCCESSFUL ---');
      } else {
        print('--- FACEBOOK POST FAILED ---');
      }
    } catch (e, stacktrace) {
      print('CRITICAL EXCEPTION: $e');
      print('STACKTRACE: $stacktrace');
    }
  }
}