import 'package:flutter/material.dart';
import 'home_screen.dart'; 
import 'budget_manager.dart';
import 'app_drawer.dart';
import 'custom_app_bar.dart';

class BudgetSetupScreen extends StatefulWidget {
  const BudgetSetupScreen({super.key});

  @override
  State<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends State<BudgetSetupScreen> {
  double _currentBudgetValue = 50.0;
  double _maxBudgetValue = 200.0;
  final double _minBudgetValue = 10.0;
  final double _stepSize = 10.0;

  Color _getSliderColor() {
    double ratio = _currentBudgetValue / _maxBudgetValue;
    if (ratio < 0.35) return Colors.blueAccent;
    if (ratio < 0.70) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  void _onSliderChanged(double value) {
    setState(() {
      _currentBudgetValue = value;

   
      if (_currentBudgetValue >= _maxBudgetValue - 20) {
        _maxBudgetValue += 100.0;
      }
    });
  }

  void _handleContinue() {
    BudgetManager.instance.setBudget(_currentBudgetValue);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/home'),
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int calculatedDivisions = ((_maxBudgetValue - _minBudgetValue) / _stepSize).round();

    return Scaffold(
      appBar: const CustomAppBar(title: "Set Your Budget"),
      drawer: const AppDrawer(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'What is your budget?',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Use the slider below to set your budget. Keep sliding right to expand the limit!',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              Text(
                '\$${_currentBudgetValue.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 48, 
                  fontWeight: FontWeight.w900, 
                  color: _getSliderColor(),
                ),
              ),
              const SizedBox(height: 20),

              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 24, 
                  trackShape: const RoundedRectSliderTrackShape(),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 18, 
                  ),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
                  valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                  valueIndicatorTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Slider(
                  value: _currentBudgetValue,
                  min: _minBudgetValue,
                  max: _maxBudgetValue,
                  divisions: calculatedDivisions,
                  label: '\$${_currentBudgetValue.toStringAsFixed(0)}',
                  activeColor: _getSliderColor(),
                  inactiveColor: Colors.grey[200],
                  onChanged: _onSliderChanged,
                ), 
              ),
              
              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${_minBudgetValue.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Max: \$${_maxBudgetValue.toStringAsFixed(0)}+',
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _handleContinue,
                  child: const Text(
                    'Continue', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}