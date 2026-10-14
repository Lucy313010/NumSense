import 'package:flutter/material.dart';
import 'budget_setup_screen.dart';
import 'app_drawer.dart';
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _startWelcomeSequence();
  }

  Future<void> _startWelcomeSequence() async {

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _opacity = 1.0;
    });

    
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _opacity = 0.0;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const BudgetSetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 800), 
          curve: Curves.easeInOut,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 36, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Setting up your shopping assistant...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}