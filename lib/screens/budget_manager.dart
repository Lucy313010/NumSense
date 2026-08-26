import 'package:flutter/foundation.dart';

class BudgetManager {
  BudgetManager._internal();
  static final BudgetManager instance = BudgetManager._internal();

  final ValueNotifier<double> budget = ValueNotifier<double>(50.0);

  double get currentBudget => budget.value;

  void setBudget(double value) {
    budget.value = value;
  }
}