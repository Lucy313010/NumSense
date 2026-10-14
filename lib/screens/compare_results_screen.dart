import 'package:flutter/material.dart';
import 'active_shopping_list_screen.dart';
import 'cart_manager.dart';
import 'compare_manager.dart';
import 'app_drawer.dart';
class CompareResultsScreen extends StatelessWidget {
  const CompareResultsScreen({super.key});

  String _money(double v) => '\$${v.toStringAsFixed(2)}';
  String _perOz(double v) => '\$${v.toStringAsFixed(3)}/oz';

  @override
  Widget build(BuildContext context) {
    final entries = CompareManager.instance.entries.value;

    if (entries.length < 2) {
      return Scaffold(
        appBar: AppBar(title: const Text("Results")),
        body: const Center(child: Text("Scan at least 2 items to compare.")),
      );
    }

    final bool useUnitPrice = entries.every((e) => e.pricePerOz != null);
    double valueOf(CompareEntry e) => useUnitPrice ? e.pricePerOz! : e.price;

    final ranked = [...entries]..sort((a, b) => valueOf(a).compareTo(valueOf(b)));
    final best = ranked.first;
    final worst = ranked.last;
    final double savedPercent = valueOf(worst) == 0
        ? 0
        : (valueOf(worst) - valueOf(best)) / valueOf(worst) * 100;

    return Scaffold(
      appBar: AppBar(title: const Text("Best Deal")),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                children: [
                  Card(
                    color: Colors.green[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.green, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.green, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            best.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _money(best.price),
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.green),
                          ),
                          if (useUnitPrice && best.pricePerOz != null)
                            Text(_perOz(best.pricePerOz!), style: const TextStyle(color: Colors.black54)),
                          const SizedBox(height: 8),
                          Text(
                            savedPercent < 0.5
                                ? "All of these cost about the same."
                                : "${savedPercent.toStringAsFixed(0)}% cheaper than ${worst.name}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!useUnitPrice)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        "Some items had no size, so this compares shelf prices only.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    "All items, cheapest first",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...ranked.asMap().entries.map((e) {
                    final rank = e.key + 1;
                    final item = e.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: rank == 1 ? Colors.green : Colors.grey[300],
                          foregroundColor: rank == 1 ? Colors.white : Colors.black87,
                          child: Text('$rank'),
                        ),
                        title: Text(item.name),
                        subtitle: Text(
                          item.pricePerOz != null ? "${item.sizeLabel} · ${_perOz(item.pricePerOz!)}" : "No size entered",
                        ),
                        trailing: Text(_money(item.price), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text("Add Best to Cart & Shop"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                CartManager.instance.addItem(CartItem(name: best.name, price: best.price));
                CompareManager.instance.clear();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(name: '/activeList'),
                    builder: (context) => const ActiveShoppingListScreen(),
                  ),
                  (route) => route.isFirst,
                );
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () {
                CompareManager.instance.clear();
                Navigator.pop(context);
              },
              child: const Text("Start a New Comparison"),
            ),
          ],
        ),
      ),
    );
  }
}