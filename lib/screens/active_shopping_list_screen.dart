import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_item_options_screen.dart';
import 'budget_manager.dart';
import 'cart_manager.dart';
import 'emoji_rating_screen.dart';
import 'trip_history_manager.dart';
import 'app_drawer.dart';

class ActiveShoppingListScreen extends StatelessWidget {
 const ActiveShoppingListScreen({super.key});

 Color _getSliderColor(double value) {
   if (value < 60) return Colors.blueAccent;
   if (value < 140) return Colors.orangeAccent;
   return Colors.redAccent;
 }

 Future<void> _finishCheckout(BuildContext context) async {
   final cartItems = CartManager.instance.items.value;
   if (cartItems.isEmpty) {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text("Your cart is empty — add an item first.")),
     );
     return;
   }

   final storeController = TextEditingController();
   final storeName = await showDialog<String>(
     context: context,
     builder: (dialogContext) => AlertDialog(
       title: const Text("Where did you shop?"),
       content: TextField(
         controller: storeController,
         autofocus: true,
         textCapitalization: TextCapitalization.words,
         decoration: const InputDecoration(hintText: "Store name", border: OutlineInputBorder()),
       ),
       actions: [
         TextButton(
           onPressed: () => Navigator.pop(dialogContext),
           child: const Text("Cancel"),
         ),
         ElevatedButton(
           onPressed: () => Navigator.pop(dialogContext, storeController.text.trim()),
           child: const Text("Save Trip"),
         ),
       ],
     ),
   );

   if (storeName == null || !context.mounted) return;

   final spent = CartManager.instance.totalSpent;
   final startingBudget = BudgetManager.instance.currentBudget + spent;
   final finalStoreName = storeName.isEmpty ? "Unnamed Store" : storeName;

   try {
     await FirebaseFirestore.instance.collection('shopping_lists').add({
       'title': finalStoreName,
       'items': cartItems.map((item) => "${item.name} - \$${item.price.toStringAsFixed(2)}").toList(),
       'totalSpent': spent,
       'budget': startingBudget,
       'createdAt': FieldValue.serverTimestamp(),
     });
   } catch (e) {
     if (context.mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Failed to save to cloud: $e')),
       );
     }
   }

   TripHistoryManager.instance.addTrip(
     SavedShoppingList(
       id: DateTime.now().millisecondsSinceEpoch.toString(),
       storeName: finalStoreName,
       date: DateTime.now(),
       totalSpent: spent,
       budget: startingBudget,
       itemCount: cartItems.length,
       dealIndicator: TripHistoryManager.dealLabel(spent, startingBudget),
     ),
   );

   CartManager.instance.checkout();

   if (context.mounted) {
     Navigator.push(
       context,
       MaterialPageRoute(builder: (context) => const EmojiRatingScreen()),
     );
   }
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(title: const Text("Start Shopping")),
     drawer: const AppDrawer(),
     body: ValueListenableBuilder<double>(
       valueListenable: BudgetManager.instance.budget,
       builder: (context, budget, _) {
         return ValueListenableBuilder<List<CartItem>>(
           valueListenable: CartManager.instance.items,
           builder: (context, cartItems, __) {
             return Padding(
               padding: const EdgeInsets.all(24.0),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: [
                   const SizedBox(height: 10),
                   Center(
                     child: Text(
                       '\$${budget.toStringAsFixed(2)}',
                       style: TextStyle(
                         fontSize: 40,
                         fontWeight: FontWeight.w900,
                         color: _getSliderColor(budget),
                       ),
                     ),
                   ),
                   const Center(
                     child: Text("Remaining Budget", style: TextStyle(fontSize: 14, color: Colors.grey)),
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
                       value: budget.clamp(10.0, 200.0),
                       min: 10.0,
                       max: 200.0,
                       divisions: 19,
                       label: '\$${budget.toStringAsFixed(0)}',
                       activeColor: _getSliderColor(budget),
                       inactiveColor: Colors.grey[200],
                       onChanged: (double value) {
                         BudgetManager.instance.setBudget(value);
                       },
                     ),
                   ),
                   const Divider(height: 32),
                   Text(
                     "Cart (${cartItems.length} item${cartItems.length == 1 ? '' : 's'})",
                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 8),
                   Expanded(
                     child: cartItems.isEmpty
                         ? const Center(
                             child: Text(
                               "No items yet — tap Add Item to scan your first price tag.",
                               textAlign: TextAlign.center,
                               style: TextStyle(color: Colors.grey),
                             ),
                           )
                         : ListView.builder(
                             itemCount: cartItems.length,
                             itemBuilder: (context, index) {
                               final item = cartItems[index];
                               return Card(
                                 margin: const EdgeInsets.only(bottom: 8),
                                 child: ListTile(
                                   title: Text(item.name),
                                   trailing: Row(
                                     mainAxisSize: MainAxisSize.min,
                                     children: [
                                       Text(
                                         '\$${item.price.toStringAsFixed(2)}',
                                         style: const TextStyle(fontWeight: FontWeight.bold),
                                       ),
                                       IconButton(
                                         icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                                         onPressed: () => CartManager.instance.removeItem(index),
                                       ),
                                     ],
                                   ),
                                 ),
                               );
                             },
                           ),
                   ),
                   const SizedBox(height: 12),
                   ElevatedButton.icon(
                     icon: const Icon(Icons.add_shopping_cart),
                     label: const Text("Add Item"),
                     style: ElevatedButton.styleFrom(
                       padding: const EdgeInsets.symmetric(vertical: 16),
                       backgroundColor: Colors.blueAccent,
                       foregroundColor: Colors.white,
                     ),
                     onPressed: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(builder: (context) => const AddItemOptionsScreen()),
                       );
                     },
                   ),
                   const SizedBox(height: 12),
                   OutlinedButton.icon(
                     icon: const Icon(Icons.check_circle_outline),
                     label: const Text("Finish & Checkout"),
                     style: OutlinedButton.styleFrom(
                       padding: const EdgeInsets.symmetric(vertical: 16),
                       foregroundColor: Colors.green,
                       side: const BorderSide(color: Colors.green, width: 2),
                     ),
                     onPressed: () => _finishCheckout(context),
                   ),
                 ],
               ),
             );
           },
         );
       },
     ),
   );
 }
}