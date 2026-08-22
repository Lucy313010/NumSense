import 'package:flutter/material.dart';
import 'add_item_options_screen.dart';
import 'budget_manager.dart';

class ActiveShoppingListScreen extends StatefulWidget {
  const ActiveShoppingListScreen({super.key});

  @override
  State<ActiveShoppingListScreen> createState() => _ActiveShoppingListScreenState();
}

class _ActiveShoppingListScreenState extends State<ActiveShoppingListScreen> {
  late double _currentBudgetValue;

  @override
  void initState() {
    super.initState();
    _currentBudgetValue = BudgetManager.instance.currentBudget;
  }

  Color _getSliderColor() {
    if (_currentBudgetValue < 60) return Colors.blueAccent;
    if (_currentBudgetValue < 140) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Start Shopping")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Text(
                '\$${_currentBudgetValue.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: _getSliderColor(),
                ),
              ),
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
                value: _currentBudgetValue,
                min: 10.0,
                max: 200.0,
                divisions: 19,
                label: '\$${_currentBudgetValue.toStringAsFixed(0)}',
                activeColor: _getSliderColor(),
                inactiveColor: Colors.grey[200],
                onChanged: (double value) {
                  setState(() {
                    _currentBudgetValue = value;
                  });
                  BudgetManager.instance.setBudget(value);
                },
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text("Add Item"),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddItemOptionsScreen()),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}