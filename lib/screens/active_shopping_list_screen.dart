import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_item_options_screen.dart';
import 'budget_manager.dart';
import 'cart_manager.dart';
import 'emoji_rating_screen.dart';
import 'trip_history_manager.dart';
import 'app_drawer.dart';
import 'custom_app_bar.dart';

class ActiveShoppingListScreen extends StatelessWidget {
 const ActiveShoppingListScreen({super.key});

 Color _getSliderColor(double value) {
   if (value < 60) return Colors.blueAccent;
   if (value < 140) return Colors.orangeAccent;
   return Colors.redAccent;
 }

 Future<void> _saveCompletedListToProfile(BuildContext context, String storeName, double totalCost, int itemCount, double budget) async {
   final user = FirebaseAuth.instance.currentUser;
   if (user == null) return;

   try {
     await FirebaseFirestore.instance.collection('shopping_lists').add({
       'userId': user.uid,
       'listName': storeName,
       'totalCost': totalCost,
       'itemCount': itemCount,
       'budget': budget,
       'items': CartManager.instance.items.value.map((e) => {'name': e.name, 'price': e.price}).toList(),
       'isCompleted': true,
       'completedAt': FieldValue.serverTimestamp(),
     });
   } catch (e) {
     if (context.mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("Database Error: $e"), backgroundColor: Colors.red),
       );
     }
   }
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

   final purchasedItems = List<CartItem>.from(cartItems);
   final spent = CartManager.instance.totalSpent;
   final startingBudget = BudgetManager.instance.currentBudget + spent;
   final finalStoreName = storeName.isEmpty ? "Unnamed Store" : storeName;

   TripHistoryManager.instance.addTrip(
     SavedShoppingList(
       id: DateTime.now().millisecondsSinceEpoch.toString(),
       storeName: finalStoreName,
       date: DateTime.now(),
       totalSpent: spent,
       budget: startingBudget,
       items: purchasedItems,
       dealIndicator: TripHistoryManager.dealLabel(spent, startingBudget),
     ),
   );

   await _saveCompletedListToProfile(context, finalStoreName, spent, purchasedItems.length, startingBudget);

   CartManager.instance.checkout();

   if (context.mounted) {
     Navigator.push(
       context,
       MaterialPageRoute(
         builder: (context) => EmojiRatingScreen(storeName: finalStoreName),
       ),
     );
   }
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: const CustomAppBar(title: "Start Shopping"),
     drawer: const AppDrawer(),
     body: ValueListenableBuilder<double>(
       valueListenable: BudgetManager.instance.budget,
       builder: (context, budget, _) {
         return ValueListenableBuilder<List<CartItem>>(
           valueListenable: CartManager.instance.items,
           builder: (context, cartItems, __) {
             
             double sliderMin = 0.0; 
             double sliderMax = budget > 200.0 ? budget : 200.0;
             double safeBudget = budget.clamp(sliderMin, sliderMax);

             return Padding(
               padding: const EdgeInsets.all(24.0),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: [
                   const SizedBox(height: 10),
                   Center(
                     child: Text(
                       // RESTORED: Shows the exact remaining budget including cents (e.g. $45.01)
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
                       value: safeBudget,
                       min: sliderMin,
                       max: sliderMax,
                       activeColor: _getSliderColor(budget),
                       inactiveColor: Colors.grey[200],
                       onChanged: (double value) {
                         // MATH FIX: Force the *Initial Budget* to be a whole number, 
                         // but keep the exact remaining cents perfectly accurate!
                         double spent = CartManager.instance.totalSpent;
                         double newInitialBudget = (value + spent).roundToDouble();
                         double exactRemainingBudget = newInitialBudget - spent;
                         
                         BudgetManager.instance.setBudget(exactRemainingBudget); 
                       },
                     ),
                   ),
                   const SizedBox(height: 4),
                   const Center(
                     child: Text("Slide to change your budget", style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                               
                               final originalBudget = budget + CartManager.instance.totalSpent;
                               double spentBeforeThis = 0;
                               for (int i = 0; i < index; i++) {
                                 spentBeforeThis += cartItems[i].price;
                               }
                               final budgetBeforeThis = originalBudget - spentBeforeThis;
                               final displayBudgetBefore = budgetBeforeThis < 0 ? 0.0 : budgetBeforeThis;
                               
                               final fraction = displayBudgetBefore > 0 ? item.price / displayBudgetBefore : 1.0;
                               final clampedFraction = fraction > 1.0 ? 1.0 : fraction;

                               return Card(
                                 margin: const EdgeInsets.only(bottom: 8),
                                 child: Padding(
                                   padding: const EdgeInsets.all(12.0),
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Row(
                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                         children: [
                                           Expanded(
                                             child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                           ),
                                           Row(
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
                                         ],
                                       ),
                                       const SizedBox(height: 8),
                                       Row(
                                         children: [
                                           Expanded(
                                              child: LinearProgressIndicator(
                                               value: clampedFraction,
                                               backgroundColor: Colors.grey[200],
                                               color: Colors.blueAccent,
                                               minHeight: 8,
                                               borderRadius: BorderRadius.circular(4),
                                             ),
                                           ),
                                           const SizedBox(width: 12),
                                           Text(
                                             '\$${item.price.toStringAsFixed(2)} / \$${displayBudgetBefore.toStringAsFixed(2)} budget',
                                             style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
                                           ),
                                         ],
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