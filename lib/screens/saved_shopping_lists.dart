import 'package:flutter/material.dart';
import 'trip_history_manager.dart';

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

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ExpansionTile(
                    title: Text(
                      trip.storeName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      "${trip.date.month}/${trip.date.day}/${trip.date.year} · "
                      "${trip.itemCount} item${trip.itemCount == 1 ? '' : 's'} · "
                      "\$${trip.totalSpent.toStringAsFixed(2)}",
                    ),
                    children: [
                      ...trip.items.map(
                        (item) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.check_circle_outline, size: 20),
                          title: Text(item.name),
                          trailing: Text(
                            "\$${item.price.toStringAsFixed(2)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                );
              },
            ),
    );
  }
}