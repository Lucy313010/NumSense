import 'package:flutter/material.dart';
import 'active_shopping_list_screen.dart';

class SavedShoppingList {
  final String id;
  final String storeName;
  final DateTime date;
  final double totalSpent;
  final double budget;
  final int itemCount;

  SavedShoppingList({
    required this.id,
    required this.storeName,
    required this.date,
    required this.totalSpent,
    required this.budget,
    required this.itemCount,
  });
}

class MasterShoppingListsScreen extends StatefulWidget {
  const MasterShoppingListsScreen({super.key});

  @override
  State<MasterShoppingListsScreen> createState() => _MasterShoppingListsScreenState();
}

class _MasterShoppingListsScreenState extends State<MasterShoppingListsScreen> {
  // Replace this with FireStone (random data)
  final List<SavedShoppingList> _mockSavedLists = [
    SavedShoppingList(id: '1', storeName: 'Shop', date: DateTime(2026, 5, 28), totalSpent: 1.0, budget: 50.00, itemCount: 1),
   ];

  String _searchQuery = "";
  bool _isGridView = true; 

  @override
  Widget build(BuildContext context) {
    // search function
    final filteredLists = _mockSavedLists.where((list) {
      return list.storeName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Shopping Lists", style: TextStyle(fontWeight: FontWeight.bold)),
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
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: "Search saved shopping lists...",
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

          // What other features of Google Drive do I imitate?
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Files", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                ),
                Text(
                  "${filteredLists.length} lists stored",
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // make the lists go to grid
          Expanded(
            child: filteredLists.isEmpty
                ? _buildEmptyState()
                : _isGridView
                    ? _buildDriveGrid(filteredLists)
                    : _buildDriveList(filteredLists),
          ),
        ],
      ),
      
      // new list button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("New Shopping Trip"),
        onPressed: () {
          // go to active shopping list
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ActiveShoppingListScreen(initialBudget: 50)),
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
        childAspectRatio: 0.95,
      ),
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final item = lists[index];
        final bool isOverBudget = item.totalSpent > item.budget;

        return Card(
          color: Colors.white,
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey[200]!, width: 1),
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
                      // File/Folder asset design element
                      Icon(
                        Icons.insert_drive_file, 
                        color: isOverBudget ? Colors.redAccent : Colors.green, 
                        size: 32,
                      ),
                      _buildMoreOptions(item),
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
                  Text(
                    "${item.itemCount} items · \$${item.totalSpent.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const Divider(height: 16),
                  Text(
                    "${item.date.month}/${item.date.day}/${item.date.year}",
                    style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w500),
                  ),
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

        return Card(
          color: Colors.white,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[100]!),
          ),
          child: ListTile(
            leading: Icon(
              Icons.insert_drive_file, 
              color: isOverBudget ? Colors.redAccent : Colors.green,
            ),
            title: Text(item.storeName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${item.date.month}/${item.date.day}/${item.date.year} · ${item.itemCount} items"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "\$${item.totalSpent.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: isOverBudget ? Colors.red : Colors.black87,
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
            children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text("Delete", style: TextStyle(color: Colors.red))],
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
              Text("Archived on ${item.date.toString().split(' ')[0]}"),
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
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