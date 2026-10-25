import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'social_forum_service.dart'; 
import 'app_drawer.dart';
import 'liked_posts_screen.dart';
import 'notifications_screen.dart';

class ForumScreen extends StatefulWidget {
 const ForumScreen({Key? key}) : super(key: key);

 @override
 State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
 final TextEditingController _titleController = TextEditingController();
 final TextEditingController _contentController = TextEditingController();
 bool _isPosting = false;

 Future<void> _submitPost() async {
   if (_titleController.text.isEmpty || _contentController.text.isEmpty) return;

   setState(() => _isPosting = true);

   await SocialForumService.publishToAllPlatforms(
     title: _titleController.text,
     content: _contentController.text,
     authorId: FirebaseAuth.instance.currentUser?.uid ?? 'anonymous_user',
   );

   setState(() => _isPosting = false);
   _titleController.clear();
   _contentController.clear();
  
   if (mounted) {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Successfully posted to Forum!')),
     );
   }
 }

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
     appBar: AppBar(
       title: const Text('Community Forum'),
       actions: [
         IconButton(
           icon: const Icon(Icons.favorite),
           tooltip: 'Liked Posts',
           onPressed: () => Navigator.push(
             context, MaterialPageRoute(builder: (context) => const LikedPostsScreen()),
           ),
         ),
         IconButton(
           icon: const Icon(Icons.notifications),
           tooltip: 'Notifications',
           onPressed: () => Navigator.push(
             context, MaterialPageRoute(builder: (context) => const NotificationsScreen()),
           ),
         ),
       ],
     ),
     drawer: const AppDrawer(),
     body: Column(
       children: [
         Container(
           padding: const EdgeInsets.all(16.0),
           color: Colors.blueGrey.withOpacity(0.1),
           child: Column(
             children: [
               TextField(
                 controller: _titleController,
                 decoration: const InputDecoration(
                   labelText: 'Post Title',
                   border: OutlineInputBorder(),
                 ),
               ),
               const SizedBox(height: 8),
               TextField(
                 controller: _contentController,
                 decoration: const InputDecoration(
                   labelText: 'Share a recipe, deal, or grocery tip...',
                   border: OutlineInputBorder(),
                 ),
                 maxLines: 3,
               ),
               const SizedBox(height: 12),
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton.icon(
                   icon: const Icon(Icons.send),
                   label: _isPosting
                       ? const Text('Publishing...')
                       : const Text('Post to Forum'),
                   onPressed: _isPosting ? null : _submitPost,
                 ),
               ),
             ],
           ),
         ),
         const Divider(height: 1, thickness: 2),
         Expanded(
           child: StreamBuilder<QuerySnapshot>(
             stream: FirebaseFirestore.instance
                 .collection('forum_posts')
                 .orderBy('createdAt', descending: true)
                 .snapshots(),
             builder: (context, snapshot) {
               if (snapshot.connectionState == ConnectionState.waiting) {
                 return const Center(child: CircularProgressIndicator());
               }
              
               final posts = snapshot.data?.docs ?? [];
              
               if (posts.isEmpty) {
                 return const Center(child: Text('No posts yet. Be the first!'));
               }

               return ListView.builder(
                 itemCount: posts.length,
                 itemBuilder: (context, index) {
                   final doc = posts[index];
                   final data = doc.data() as Map<String, dynamic>;
                   final postId = doc.id;
                   
                   final authorId = data['authorId'] ?? '';
                   final isPostOwner = currentUserId != null && currentUserId == authorId;
                   final replies = List<Map<String, dynamic>>.from(data['replies'] ?? []);
                   final likedBy = List<String>.from(data['likedBy'] ?? []);
                   final isLiked = currentUserId != null && likedBy.contains(currentUserId);

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
                                     onPressed: currentUserId == null ? null : () => SocialForumService.toggleLike(postId, currentUserId, isLiked),
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
                               final isReplyOwner = currentUserId != null && currentUserId == reply['authorId'];
                               final replyLikedBy = List<String>.from(reply['likedBy'] ?? []);
                               final isReplyLiked = currentUserId != null && replyLikedBy.contains(currentUserId);

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
                                           onPressed: currentUserId == null ? null : () => SocialForumService.toggleReplyLike(postId, reply, currentUserId, isReplyLiked),
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
         ),
       ],
     ),
   );
 }
}