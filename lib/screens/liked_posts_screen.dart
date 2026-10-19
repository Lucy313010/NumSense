import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'social_forum_service.dart';

class LikedPostsScreen extends StatelessWidget {
  const LikedPostsScreen({Key? key}) : super(key: key);

  void _showReplyDialog(BuildContext context, String postId, String postAuthorId) {
    final TextEditingController replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Write a Reply"),
        content: TextField(
          controller: replyController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter your reply..."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (replyController.text.trim().isNotEmpty) {
                final authorId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous_user';
                await SocialForumService.addReply(postId, postAuthorId, replyController.text.trim(), authorId);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Reply"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Liked Posts")),
      body: currentUserId == null 
        ? const Center(child: Text("Sign in to see liked posts."))
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('forum_posts')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final allPosts = snapshot.data?.docs ?? [];
              
              // Filter out posts to only show ones where the user liked the post OR a reply
              final posts = allPosts.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final likedBy = List<String>.from(data['likedBy'] ?? []);
                final replies = List<Map<String, dynamic>>.from(data['replies'] ?? []);
                
                final likesMainPost = likedBy.contains(currentUserId);
                final likesAReply = replies.any((reply) {
                  final replyLikedBy = List<String>.from(reply['likedBy'] ?? []);
                  return replyLikedBy.contains(currentUserId);
                });
                
                return likesMainPost || likesAReply;
              }).toList();

              if (posts.isEmpty) {
                return const Center(child: Text("You haven't liked any posts or replies yet."));
              }

              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final doc = posts[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final postId = doc.id;
                  
                  final authorId = data['authorId'] ?? '';
                  final isPostOwner = currentUserId == authorId;
                  final replies = List<Map<String, dynamic>>.from(data['replies'] ?? []);
                  final likedBy = List<String>.from(data['likedBy'] ?? []);
                  final isLiked = likedBy.contains(currentUserId);

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(child: Icon(Icons.person, size: 20), radius: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(data['content'] ?? '', style: const TextStyle(fontSize: 15)),
                          const SizedBox(height: 8),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.grey),
                                    onPressed: () => SocialForumService.toggleLike(postId, currentUserId, isLiked),
                                  ),
                                  Text('${likedBy.length}'),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: const Icon(Icons.reply, color: Colors.blueAccent),
                                    onPressed: () => _showReplyDialog(context, postId, authorId),
                                  ),
                                  Text('${replies.length}'),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: const Icon(Icons.share, color: Colors.green),
                                    onPressed: () {
                                      Share.share("Check out this tip on NumSense:\n\n${data['title']}\n${data['content']}");
                                    },
                                  ),
                                ],
                              ),
                              if (isPostOwner)
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => SocialForumService.deletePost(postId),
                                ),
                            ],
                          ),
                          
                          if (replies.isNotEmpty) ...[
                            const Divider(),
                            ...replies.map((reply) {
                              final isReplyOwner = currentUserId == reply['authorId'];
                              final replyLikedBy = List<String>.from(reply['likedBy'] ?? []);
                              final isReplyLiked = replyLikedBy.contains(currentUserId);

                              return Padding(
                                padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(reply['text'] ?? '', style: const TextStyle(fontSize: 14)),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(isReplyLiked ? Icons.favorite : Icons.favorite_border, size: 16, color: isReplyLiked ? Colors.red : Colors.grey),
                                          onPressed: () => SocialForumService.toggleReplyLike(postId, reply, currentUserId, isReplyLiked),
                                        ),
                                        Text('${replyLikedBy.length}', style: const TextStyle(fontSize: 12)),
                                        if (isReplyOwner)
                                          IconButton(
                                            icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                                            onPressed: () => SocialForumService.deleteReply(postId, reply),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}