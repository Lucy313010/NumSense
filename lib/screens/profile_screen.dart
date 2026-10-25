import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'custom_app_bar.dart';
import 'app_drawer.dart';
import 'cart_manager.dart';
import 'budget_manager.dart';
import 'active_shopping_list_screen.dart';

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
    String userIdentity = user.isAnonymous ? "Guest" : (user.email ?? user.displayName ?? "User");

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
          if (snapshot.hasError) return Center(child: Text("Error loading data: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

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
                          border: Border.all(color: user.isAnonymous ? Colors.orange : Colors.green),
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
                      const Text("Your Shopping Stats", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                      const Text("Past Shopping Lists", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                          final timestamp = data['completedAt'] as Timestamp?;
                          final date = timestamp != null ? timestamp.toDate() : DateTime.now();
                          final rawItems = data['items'] as List<dynamic>? ?? [];

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

                          double spentSoFar = 0.0;
                          List<Widget> itemWidgets = [];
                          for (var itemData in rawItems) {
                            final itemName = itemData['name'] ?? 'Item';
                            final itemPrice = (itemData['price'] ?? 0).toDouble();
                            final budgetBefore = budget - spentSoFar;
                            final displayBudgetBefore = budgetBefore < 0 ? 0.0 : budgetBefore;

                            final itemFraction = displayBudgetBefore > 0 ? itemPrice / displayBudgetBefore : 1.0;
                            final itemClamped = itemFraction > 1.0 ? 1.0 : itemFraction;

                            itemWidgets.add(
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(itemName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                        Text('\$${itemPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: LinearProgressIndicator(
                                            value: itemClamped,
                                            backgroundColor: Colors.grey[200],
                                            color: Colors.blueAccent,
                                            minHeight: 6,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          // Restored exact decimals for math clarity!
                                          '\$${itemPrice.toStringAsFixed(2)} / \$${displayBudgetBefore.toStringAsFixed(2)} budget',
                                          style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            );
                            spentSoFar += itemPrice;
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            clipBehavior: Clip.antiAlias,
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.all(16.0),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 4),
                                              Text("${date.month}/${date.day}/${date.year}", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                                            ]
                                          )
                                        ),
                                        Text(statusText, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: statusColor)),
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
                                        Text("$itemCount items", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                                        Text(
                                          "Spent \$${cost.toStringAsFixed(2)} of \$${budget.toStringAsFixed(0)}",
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                children: [
                                  if (itemWidgets.isNotEmpty) const Divider(height: 1),
                                  ...itemWidgets,
                                  if (itemWidgets.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            backgroundColor: Colors.blueAccent,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          icon: const Icon(Icons.shopping_cart_checkout),
                                          label: const Text("Quick Buy (Add to Current List)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                          onPressed: () async {
                                            double totalItemsCost = 0;
                                            for (var itemData in rawItems) {
                                              totalItemsCost += (itemData['price'] ?? 0).toDouble();
                                            }

                                            double? newBudget = await showDialog<double>(
                                              context: context,
                                              builder: (dialogContext) {
                                                double tempBudget = totalItemsCost > 20 ? totalItemsCost + 30 : 50.0;
                                                if (tempBudget < totalItemsCost) tempBudget = totalItemsCost + 10.0;
                                                
                                                tempBudget = tempBudget.roundToDouble(); // Start on a whole number

                                                return StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return AlertDialog(
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                      title: const Text("Set Budget for Quick Buy", textAlign: TextAlign.center),
                                                      content: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            "These items cost \$${totalItemsCost.toStringAsFixed(2)}.\nSet your starting budget:",
                                                            textAlign: TextAlign.center,
                                                            style: const TextStyle(fontSize: 16),
                                                          ),
                                                          const SizedBox(height: 24),
                                                          Text(
                                                            "\$${tempBudget.toStringAsFixed(0)}",
                                                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blueAccent)
                                                          ),
                                                          Slider(
                                                            value: tempBudget,
                                                            min: totalItemsCost.roundToDouble(), // Round the minimum
                                                            max: ((totalItemsCost + 150 > 200) ? totalItemsCost + 150 : 200).roundToDouble(), // Round the maximum
                                                            onChanged: (val) => setState(() => tempBudget = val.roundToDouble()), // Force slide to whole numbers
                                                          ),
                                                          const Text("Slide to change your budget", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                                        ],
                                                      ),
                                                      actions: [
                                                        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel")),
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                                                          onPressed: () => Navigator.pop(dialogContext, tempBudget),
                                                          child: const Text("Add to Cart"),
                                                        ),
                                                      ],
                                                    );
                                                  }
                                                );
                                              }
                                            );

                                            if (newBudget != null && context.mounted) {
                                              BudgetManager.instance.setBudget(newBudget);
                                              
                                              for (var itemData in rawItems) {
                                                final name = itemData['name'] ?? 'Item';
                                                final price = (itemData['price'] ?? 0).toDouble();
                                                CartManager.instance.addItem(CartItem(name: name, price: price));
                                              }
                                              
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  settings: const RouteSettings(name: '/activeList'),
                                                  builder: (context) => const ActiveShoppingListScreen()
                                                ),
                                                (route) => route.isFirst,
                                              );
                                            }
                                          },
                                        ),
                                      ),
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
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color.withOpacity(0.9))),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }
}