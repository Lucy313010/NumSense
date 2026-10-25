import 'package:flutter/material.dart';
import 'trip_history_manager.dart';
import 'cart_manager.dart';
import 'budget_manager.dart';
import 'active_shopping_list_screen.dart';

class SavedShoppingListsScreen extends StatefulWidget {
  const SavedShoppingListsScreen({Key? key}) : super(key: key);

  @override
  State<SavedShoppingListsScreen> createState() => _SavedShoppingListsScreenState();
}

class _SavedShoppingListsScreenState extends State<SavedShoppingListsScreen> {
  @override
  void initState() {
    super.initState();
    TripHistoryManager.instance.trips.addListener(_onTripsChanged);
  }

  @override
  void dispose() {
    TripHistoryManager.instance.trips.removeListener(_onTripsChanged);
    super.dispose();
  }

  void _onTripsChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final trips = TripHistoryManager.instance.trips.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Past Shopping Items')),
      body: trips.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No saved trips yet. Finish a shopping trip to see what you bought here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          : ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                final bool overBudget = trip.totalSpent > trip.budget;

                double spentSoFar = 0.0;
                List<Widget> itemWidgets = [];
                
                for (var item in trip.items) {
                  final budgetBefore = trip.budget - spentSoFar;
                  final displayBudgetBefore = budgetBefore < 0 ? 0.0 : budgetBefore;

                  final itemFraction = displayBudgetBefore > 0 ? item.price / displayBudgetBefore : 1.0;
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
                              Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text('\$${item.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                                // Exact decimals for accuracy
                                '\$${item.price.toStringAsFixed(2)} / \$${displayBudgetBefore.toStringAsFixed(2)} budget',
                                style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  );
                  spentSoFar += item.price;
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  clipBehavior: Clip.antiAlias,
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(
                        trip.storeName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(
                        "${trip.date.month}/${trip.date.day}/${trip.date.year} · "
                        "${trip.itemCount} item${trip.itemCount == 1 ? '' : 's'} · "
                        "Spent \$${trip.totalSpent.toStringAsFixed(2)} of \$${trip.budget.toStringAsFixed(0)}",
                      ),
                      children: [
                        const Divider(height: 1),
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
                                  for (var item in trip.items) {
                                    totalItemsCost += item.price;
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
                                    
                                    for (var item in trip.items) {
                                      CartManager.instance.addItem(CartItem(name: item.name, price: item.price));
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
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Budget"),
                                  Text("\$${trip.budget.toStringAsFixed(2)}"),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Total spent", style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(
                                    "\$${trip.totalSpent.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: overBudget ? Colors.red : Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}