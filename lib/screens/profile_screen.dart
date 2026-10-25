import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'custom_app_bar.dart';
import 'app_drawer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'My Profile'),
        drawer: const AppDrawer(),
        body: const Center(
          child: Text(
            "Please sign in to view your profile and shopping history.",
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final currentUserId = user.uid;

    String userIdentity = "User";
    if (user.isAnonymous) {
      userIdentity = "Guest";
    } else if (user.email != null && user.email!.isNotEmpty) {
      userIdentity = user.email!;
    } else if (user.displayName != null && user.displayName!.isNotEmpty) {
      userIdentity = user.displayName!;
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'My Profile'),
      drawer: const AppDrawer(),
      backgroundColor: Colors.grey[50],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('shopping_lists')
            .where('userId', isEqualTo: currentUserId)
            .where('isCompleted', isEqualTo: true)
            .orderBy('completedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
       
          if (snapshot.hasError) {
            return Center(child: Text("Error loading data: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pastLists = snapshot.data?.docs ?? [];
         
    
          double totalSpent = 0;
          for (var doc in pastLists) {
            final data = doc.data() as Map<String, dynamic>;
            totalSpent += (data['totalCost'] ?? 0).toDouble();
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: user.isAnonymous ? Colors.orangeAccent.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: user.isAnonymous ? Colors.orange : Colors.green,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              user.isAnonymous ? Icons.person_outline : Icons.person,
                              color: user.isAnonymous ? Colors.orange[800] : Colors.green[800],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Signed in as: $userIdentity",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: user.isAnonymous ? Colors.orange[800] : Colors.green[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                     
                      const Text(
                        "Your Shopping Stats",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                     
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: "Total Spent",
                              value: "\$${totalSpent.toStringAsFixed(2)}",
                              icon: Icons.account_balance_wallet,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: "Trips Finished",
                              value: "${pastLists.length}",
                              icon: Icons.shopping_cart_checkout,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                     
                      const Text(
                        "Past Shopping Lists",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
             
              pastLists.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          "You haven't completed any shopping lists yet.",
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final data = pastLists[index].data() as Map<String, dynamic>;
                          final title = data['listName'] ?? 'Shopping Trip';
                          final cost = (data['totalCost'] ?? 0).toDouble();
                          final budget = (data['budget'] ?? cost).toDouble(); 
                          final itemCount = data['itemCount'] ?? 0;


                          double fractionSpent = budget > 0 ? cost / budget : 0;
                          double clampedFraction = fractionSpent > 1.0 ? 1.0 : fractionSpent;
                          
                 
                          Color statusColor = Colors.green;
                          String statusText = "Under Budget!";
                          if (fractionSpent > 1.0) {
                            statusColor = Colors.redAccent;
                            statusText = "Over Budget";
                          } else if (fractionSpent > 0.85) {
                            statusColor = Colors.orangeAccent;
                            statusText = "Close to Budget";
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      Text(
                                        statusText, 
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                     
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: clampedFraction,
                                      minHeight: 12,
                                      backgroundColor: Colors.grey[200],
                                      color: statusColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("$itemCount items", style: const TextStyle(fontSize: 16, color: Colors.black54)),
                                     
                                      Text(
                                        "Spent \$${cost.toStringAsFixed(2)} of \$${budget.toStringAsFixed(0)}",
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: pastLists.length,
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: color.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}