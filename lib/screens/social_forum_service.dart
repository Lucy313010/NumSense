import 'package:cloud_firestore/cloud_firestore.dart';

class SocialForumService {
  static Future<void> publishToAllPlatforms({
    required String title,
    required String content,
    required String authorId,
  }) async {
    await FirebaseFirestore.instance.collection('forum_posts').add({
      'title': title,
      'content': content,
      'authorId': authorId,
      'createdAt': FieldValue.serverTimestamp(),
      'platform': 'NumSense',
      'replies': [], 
      'likedBy': [], 
    });
  }

  static Future<void> deletePost(String postId) async {
    await FirebaseFirestore.instance.collection('forum_posts').doc(postId).delete();
  }

  static Future<void> addReply(String postId, String postAuthorId, String replyText, String authorId) async {
    final reply = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': replyText,
      'authorId': authorId,
      'createdAt': Timestamp.now(),
      'likedBy': [],
    };
    
    await FirebaseFirestore.instance.collection('forum_posts').doc(postId).update({
      'replies': FieldValue.arrayUnion([reply])
    });

  
    await FirebaseFirestore.instance.collection('notifications').add({
      'recipientId': postAuthorId,
      'senderId': authorId,
      'postId': postId,
      'message': 'Someone replied to your forum post!',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteReply(String postId, Map<String, dynamic> reply) async {
    await FirebaseFirestore.instance.collection('forum_posts').doc(postId).update({
      'replies': FieldValue.arrayRemove([reply])
    });
  }

  static Future<void> toggleLike(String postId, String userId, bool isCurrentlyLiked) async {
    if (isCurrentlyLiked) {
      await FirebaseFirestore.instance.collection('forum_posts').doc(postId).update({
        'likedBy': FieldValue.arrayRemove([userId])
      });
    } else {
      await FirebaseFirestore.instance.collection('forum_posts').doc(postId).update({
        'likedBy': FieldValue.arrayUnion([userId])
      });
    }
  }

  static Future<void> toggleReplyLike(String postId, Map<String, dynamic> reply, String userId, bool isCurrentlyLiked) async {
    final postRef = FirebaseFirestore.instance.collection('forum_posts').doc(postId);
    
   
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(postRef);
      if (!snapshot.exists) return;
      
      final data = snapshot.data()!;
      List<dynamic> replies = List.from(data['replies'] ?? []);
      
      final replyIndex = replies.indexWhere((r) => r['id'] == reply['id']);
      if (replyIndex == -1) return;
      
      final updatedReply = Map<String, dynamic>.from(replies[replyIndex]);
      List<String> likedBy = List<String>.from(updatedReply['likedBy'] ?? []);
      
      if (isCurrentlyLiked) {
        likedBy.remove(userId);
      } else {
        likedBy.add(userId);
      }
      
      updatedReply['likedBy'] = likedBy;
      replies[replyIndex] = updatedReply;
      
      transaction.update(postRef, {'replies': replies});
    });
  }
}