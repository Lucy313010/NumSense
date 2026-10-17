import 'package:flutter/foundation.dart';
import 'cart_manager.dart';

class SavedShoppingList {
  final String id;
  final String storeName;
  final DateTime date;
  final double totalSpent;
  final double budget;
  final List<CartItem> items;
  final String dealIndicator;

  SavedShoppingList({
    required this.id,
    required this.storeName,
    required this.date,
    required this.totalSpent,
    required this.budget,
    required this.items,
    required this.dealIndicator,
  });

  int get itemCount => items.length;
}

class TripHistoryManager {
  TripHistoryManager._internal();
  static final TripHistoryManager instance = TripHistoryManager._internal();

  final ValueNotifier<List<SavedShoppingList>> trips =
      ValueNotifier<List<SavedShoppingList>>([]);

  void addTrip(SavedShoppingList trip) {
    trips.value = [trip, ...trips.value];
  }

  void removeTrip(String id) {
    trips.value = trips.value.where((t) => t.id != id).toList();
  }

  static String dealLabel(double spent, double budget) {
    if (budget <= 0) return 'Standard Prices';
    final ratio = spent / budget;
    if (ratio <= 0.85) return 'Great Deals';
    if (ratio <= 1.0) return 'Standard Prices';
    return 'High Prices';
  }
}