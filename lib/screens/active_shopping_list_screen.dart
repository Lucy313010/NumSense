import 'package:flutter/material.dart';
import 'add_item_options_screen.dart';
import 'emoji_rating_screen.dart';

class ShoppingItem {
  final String name;
  final double price;
  final String dealStatus; 

  ShoppingItem({required this.name, required this.price, this.dealStatus = 'good'});
}

class ActiveShoppingListScreen extends StatefulWidget {
  final double initialBudget;
  final String storeName;

  const ActiveShoppingListScreen({
    super.key,
    required this.initialBudget,
    this.storeName = "Trader Joe's",
  });

  @override
  State<ActiveShoppingListScreen> createState() => _ActiveShoppingListScreenState();
}

class _ActiveShoppingListScreenState extends State<ActiveShoppingListScreen> {
  late double _currentBudgetValue;
  final List<ShoppingItem> _items = [];

  @override
  void initState() {
    super.initState();
    _currentBudgetValue = widget.initialBudget;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPastStorePurchases();
    });
  }

  void _checkPastStorePurchases() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.storefront, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Expanded(child: Text("Welcome to ${widget.storeName}!")),
          ],
        ),
        content: Text(
          "You usually buy Milk (\$3) and Bananas (\$1) at this store. Would you like to auto-add them?",
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No thanks"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                _items.add(ShoppingItem(name: "Whole Milk", price: 3.49, dealStatus: 'good'));
                _items.add(ShoppingItem(name: "Bananas", price: 1.20, dealStatus: 'good'));
              });
              Navigator.pop(context);
            },
            child: const Text("Yes, Add Them"),
          ),
        ],
      ),
    );
  }

  double get _totalSpent => _items.fold(0.0, (sum, item) => sum + item.price);

  Color _getSliderColor() {
    double remaining = _currentBudgetValue - _totalSpent;
    if (remaining > _currentBudgetValue * 0.4) return Colors.blueAccent;
    if (remaining > 0) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storeName),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
 
            Card(
              elevation: 0,
              color: Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Remaining Budget", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Text(
                          '\$${(_currentBudgetValue - _totalSpent).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: _getSliderColor(),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("${_items.length} items logged", style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("Total Spent: \$${_totalSpent.toStringAsFixed(2)}", style: const TextStyle(color: Colors.grey)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: Text(
                        "Your cart is empty.\nTap 'Add Item' below!",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[50],
                              child: const Icon(Icons.shopping_bag, color: Colors.blueAccent),
                            ),
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: item.dealStatus == 'good' ? Colors.green : Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(item.dealStatus == 'good' ? "Great deal at ${widget.storeName}" : "Standard price"),
                              ],
                            ),
                            trailing: Text(
                              "\$${item.price.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
            ),

  
            ElevatedButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text("Add Item"),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddItemOptionsScreen(
                      onItemAdded: (name, price) {
                        setState(() {
                          _items.add(ShoppingItem(name: name, price: price));
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("Checkout & Finish"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmojiRatingScreen(initialBudget: _currentBudgetValue),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}