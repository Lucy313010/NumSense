import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: currentUserId == null
        ? const Center(child: Text("Sign in to see notifications."))
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('recipientId', isEqualTo: currentUserId)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final notifications = snapshot.data?.docs ?? [];
              if (notifications.isEmpty) {
                return const Center(child: Text("No new notifications."));
              }
              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final doc = notifications[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final isRead = data['isRead'] ?? false;

                  return Container(
                    color: isRead ? Colors.transparent : Colors.blue.withOpacity(0.1),
                    child: ListTile(
                      leading: Icon(
                        Icons.notifications, 
                        color: isRead ? Colors.grey : Colors.blueAccent
                      ),
                      title: Text(data['message'] ?? ''),
                      onTap: () {
                     
                        FirebaseFirestore.instance.collection('notifications').doc(doc.id).update({'isRead': true});
                      },
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}