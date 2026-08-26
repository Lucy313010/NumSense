import 'package:flutter/material.dart';
import 'active_shopping_list_screen.dart';

class SavedShoppingList {
  final String id;
  final String storeName;
  final DateTime date;
  final double totalSpent;
  final double budget;
  final int itemCount;
  final String dealIndicator;

  SavedShoppingList({
    required this.id,
    required this.storeName,
    required this.date,
    required this.totalSpent,
    required this.budget,
    required this.itemCount,
    required this.dealIndicator,
  });
}

class PastShoppingScreen extends StatefulWidget {
  const PastShoppingScreen({super.key});

  @override
  State<PastShoppingScreen> createState() => _PastShoppingScreenState();
}

class _PastShoppingScreenState extends State<PastShoppingScreen> {
  // this is temporary hardcoded data 
  // i will connect this to Firebase so it loads real saved lists later
  final List<SavedShoppingList> _mockSavedLists = [
    SavedShoppingList(
      id: '1',
      storeName: "Trader Joe's",
      date: DateTime(2026, 8, 20),
      totalSpent: 42.50,
      budget: 50.00,
      itemCount: 8,
      dealIndicator: 'Great Deals',
    ),
    SavedShoppingList(
      id: '2',
      storeName: 'Walmart',
      date: DateTime(2026, 8, 15),
      totalSpent: 68.10,
      budget: 60.00,
      itemCount: 12,
      dealIndicator: 'Standard Prices',
    ),
    SavedShoppingList(
      id: '3',
      storeName: 'Whole Foods',
      date: DateTime(2026, 8, 02),
      totalSpent: 92.00,
      budget: 80.00,
      itemCount: 6,
      dealIndicator: 'High Prices',
    ),
  ];

  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredLists = _mockSavedLists.where((list) {
      return list.storeName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Store History & Lists", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: "Search store lists...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Store Memory Squares", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                Text("${filteredLists.length} stores recorded", style: TextStyle(fontSize: 13, color: Colors.grey[500])),
              ],
            ),
          ),
          const SizedBox(height: 12),


          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.88,
              ),
              itemCount: filteredLists.length,
              itemBuilder: (context, index) {
                final item = filteredLists[index];
                final bool isOverBudget = item.totalSpent > item.budget;

                Color badgeColor;
                if (item.dealIndicator == 'Great Deals') {
                  badgeColor = Colors.green;
                } else if (item.dealIndicator == 'Standard Prices') {
                  badgeColor = Colors.orangeAccent;
                } else {
                  badgeColor = Colors.redAccent;
                }

                return Card(
                  color: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActiveShoppingListScreen(
                            initialBudget: item.budget,
                            storeName: item.storeName,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.storefront, color: Colors.blueAccent, size: 24),
                              ),
             
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            item.storeName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text("${item.itemCount} items bought", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                          const SizedBox(height: 2),
                          Text(
                            "\$${item.totalSpent.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isOverBudget ? Colors.red : Colors.green[700],
                            ),
                          ),
                          const Divider(height: 16),
                          Row(
                            children: [
                              Icon(Icons.sell_outlined, size: 12, color: badgeColor),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.dealIndicator,
                                  style: TextStyle(fontSize: 11, color: badgeColor, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("New Trip"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ActiveShoppingListScreen(initialBudget: 50),
            ),
          );
        },
      ),
    );
  }
}