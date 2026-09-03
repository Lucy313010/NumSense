import 'package:flutter/foundation.dart';
import 'budget_manager.dart';

class CartItem {
  final String name;
  final double price;

  CartItem({required this.name, required this.price});
}

class CartManager {
  CartManager._internal();
  static final CartManager instance = CartManager._internal();

  final ValueNotifier<List<CartItem>> items = ValueNotifier<List<CartItem>>([]);

  double get totalSpent =>
      items.value.fold(0.0, (sum, item) => sum + item.price);

  void addItem(CartItem item) {
    items.value = [...items.value, item];
    BudgetManager.instance.setBudget(BudgetManager.instance.currentBudget - item.price);
  }

  void removeItem(int index) {
    final removed = items.value[index];
    final updated = [...items.value]..removeAt(index);
    items.value = updated;
    BudgetManager.instance.setBudget(BudgetManager.instance.currentBudget + removed.price);
  }

  void clear() {
    items.value = [];
  }
}