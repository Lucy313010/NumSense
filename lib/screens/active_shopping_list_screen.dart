import 'package:flutter/material.dart';
import 'add_item_options_screen.dart';
import 'budget_manager.dart';
import 'cart_manager.dart';
import 'emoji_rating_screen.dart';

class ActiveShoppingListScreen extends StatelessWidget {
  final double? initialBudget;
  final String? storeName;

  const ActiveShoppingListScreen({
    super.key,
    this.initialBudget,
    this.storeName,
  });

  Color _getSliderColor(double value) {
    if (value < 60) return Colors.blueAccent;
    if (value < 140) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Start Shopping")),
      body: ValueListenableBuilder<double>(
        valueListenable: BudgetManager.instance.budget,
        builder: (context, budget, _) {
          return ValueListenableBuilder<List<CartItem>>(
            valueListenable: CartManager.instance.items,
            builder: (context, cartItems, __) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        '\$${budget.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: _getSliderColor(budget),
                        ),
                      ),
                    ),
                    const Center(
                      child: Text("Remaining Budget", style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ),
                    const SizedBox(height: 10),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 20,
                        trackShape: const RoundedRectSliderTrackShape(),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 26),
                        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                        valueIndicatorTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Slider(
                        value: budget.clamp(10.0, 200.0),
                        min: 10.0,
                        max: 200.0,
                        divisions: 19,
                        label: '\$${budget.toStringAsFixed(0)}',
                        activeColor: _getSliderColor(budget),
                        inactiveColor: Colors.grey[200],
                        onChanged: (double value) {
                          BudgetManager.instance.setBudget(value);
                        },
                      ),
                    ),
                    const Divider(height: 32),
                    Text(
                      "Cart (${cartItems.length} item${cartItems.length == 1 ? '' : 's'})",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: cartItems.isEmpty
                          ? const Center(
                              child: Text(
                                "No items yet — tap Add Item to scan your first price tag.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                final item = cartItems[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    title: Text(item.name),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '\$${item.price.toStringAsFixed(2)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                                          onPressed: () => CartManager.instance.removeItem(index),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text("Add Item"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddItemOptionsScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text("Finish & Checkout"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green, width: 2),
                      ),
                      onPressed: () {
                        CartManager.instance.clear();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmojiRatingScreen(initialBudget: 50.0),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}