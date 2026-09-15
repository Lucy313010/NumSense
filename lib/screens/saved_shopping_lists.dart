import 'package:flutter/material.dart';
import 'active_shopping_list_screen.dart';

class SavedShoppingList {
  final String id;
  final String storeName;
  final DateTime date;
  final double totalSpent;
  final double budget;
  final int itemCount;
  final String dealIndicator; // added from old past shopping screen

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

class MasterShoppingListsScreen extends StatefulWidget {
  const MasterShoppingListsScreen({super.key});

  @override
  State<MasterShoppingListsScreen> createState() => _MasterShoppingListsScreenState();
}

class _MasterShoppingListsScreenState extends State<MasterShoppingListsScreen> {
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
  bool _isGridView = true;

  Color _getBadgeColor(String indicator) {
    if (indicator == 'Great Deals') return Colors.green;
    if (indicator == 'Standard Prices') return Colors.orangeAccent;
    return Colors.redAccent;
  }

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
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list_alt : Icons.grid_view),
            tooltip: _isGridView ? "Switch to List View" : "Switch to Grid View",
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: Column(
        children: [
          // search box
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
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Store Memory Files",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                ),
                Text(
                  "${filteredLists.length} stores recorded",
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredLists.isEmpty
                ? _buildEmptyState()
                : _isGridView
                    ? _buildDriveGrid(filteredLists)
                    : _buildDriveList(filteredLists),
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

  Widget _buildDriveGrid(List<SavedShoppingList> lists) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.88,
      ),
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final item = lists[index];
        final bool isOverBudget = item.totalSpent > item.budget;
        final badgeColor = _getBadgeColor(item.dealIndicator);

        return Card(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _openSavedListDetails(item),
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
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          _buildMoreOptions(item),
                        ],
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
    );
  }

  Widget _buildDriveList(List<SavedShoppingList> lists) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final item = lists[index];
        final bool isOverBudget = item.totalSpent > item.budget;
        final badgeColor = _getBadgeColor(item.dealIndicator);

        return Card(
          color: Colors.white,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.storefront, color: Colors.blueAccent),
            ),
            title: Text(item.storeName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${item.date.month}/${item.date.day}/${item.date.year} · ${item.itemCount} items"),
                Row(
                  children: [
                    Icon(Icons.sell_outlined, size: 12, color: badgeColor),
                    const SizedBox(width: 4),
                    Text(
                      item.dealIndicator,
                      style: TextStyle(fontSize: 11, color: badgeColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "\$${item.totalSpent.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isOverBudget ? Colors.red : Colors.green[700],
                  ),
                ),
                _buildMoreOptions(item),
              ],
            ),
            onTap: () => _openSavedListDetails(item),
          ),
        );
      },
    );
  }

  Widget _buildMoreOptions(SavedShoppingList item) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
      padding: EdgeInsets.zero,
      onSelected: (value) {
        if (value == 'delete') {
          setState(() {
            _mockSavedLists.removeWhere((element) => element.id == item.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Deleted ${item.storeName} list from cloud memory.")),
          );
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(
          value: 'open',
          child: Row(
            children: [Icon(Icons.open_in_new, size: 18), SizedBox(width: 8), Text("Open list")],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text("Delete", style: TextStyle(color: Colors.red))
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_queue, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text("No shopping files found", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          Text("Try expanding your search parameters.", style: TextStyle(color: Colors.grey[400], fontSize: 13)),
        ],
      ),
    );
  }

  void _openSavedListDetails(SavedShoppingList item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(item.storeName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Archived on ${item.date.month}/${item.date.day}/${item.date.year}"),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Target Budget Plan:"),
                  Text("\$${item.budget.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Final Amount Checked Out:"),
                  Text(
                    "\$${item.totalSpent.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: item.totalSpent > item.budget ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Close File Review", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        );
      },
    );
  }
}