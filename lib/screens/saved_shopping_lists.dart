import 'package:flutter/material.dart';
import 'trip_history_manager.dart';

class SavedShoppingListsScreen extends StatefulWidget {
  const SavedShoppingListsScreen({Key? key}) : super(key: key);

  @override
  State<SavedShoppingListsScreen> createState() => _SavedShoppingListsScreenState();
}

import 'custom_app_bar.dart';

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
      appBar: const CustomAppBar(title: "Saved Shopping Lists"),
      body: trips.isEmpty
          ? const Center(child: Text('No saved lists found. Finish a shopping trip to see it here.'))
          : ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(trip.storeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      "${trip.date.month}/${trip.date.day}/${trip.date.year} · ${trip.itemCount} items",
                    ),
                    trailing: Text(
                      "\$${trip.totalSpent.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: trip.totalSpent > trip.budget ? Colors.red : Colors.green[700],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}