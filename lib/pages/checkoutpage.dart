import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fooddelivery/pages/home_screen.dart';
import 'package:fooddelivery/reusable/cartitems.dart';
import 'package:fooddelivery/reusable/custom_bottom_navigation.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _paymentMethod = 'Cash on Delivery';

  Future<void> _placeOrder(
      BuildContext context,
      List<Map<String, dynamic>> cartItems,
      double total,
      String paymentMethod) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        throw Exception("User not logged in");
      }

      // Add order to the user's `orderhistory` subcollection
      await firestore
          .collection('users')
          .doc(userId)
          .collection('orderhistory')
          .add({
        'items': cartItems,
        'total': total,
        'paymentMethod': paymentMethod,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear the cart after placing the order
      await CartItems.clearCart(); // Implement this method to remove cart items

      // Navigate back to HomePage
      Navigator.popUntil(context, (route) => route.isFirst);

      // Show success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Order Placed!'),
          content: const Text('Your order has been placed successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: CartItems.getCartItems(), // Fetch cart items from Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          } else {
            final cartItems = snapshot.data!;
            double subtotal = cartItems.fold(0.0, (sum, item) {
              double addOnsPrice = item['addOns']
                      ?.fold(0.0, (sum, addOn) => sum + addOn['price']) ??
                  0.0;
              return sum + item['price'] + addOnsPrice;
            });

            double deliveryFee = 30.0;
            double total = subtotal + deliveryFee;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary
                    const Text(
                      'Order Summary',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...cartItems.map((item) {
                      double addOnsPrice = item['addOns']?.fold(
                              0.0, (sum, addOn) => sum + addOn['price']) ??
                          0.0;
                      return ListTile(
                        leading: Image.asset(item['imagePath'],
                            width: 50, height: 50),
                        title: Text(item['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Price: ${item['price']} Birr'),
                            if (item['addOns'] != null &&
                                item['addOns'].isNotEmpty)
                              ...item['addOns'].map<Widget>((addOn) => Text(
                                  '${addOn['name']}: ${addOn['price']} Birr')),
                          ],
                        ),
                        trailing: Text(
                            'Total: ${(item['price'] + addOnsPrice).toStringAsFixed(2)} Birr'),
                      );
                    }),
                    const Divider(),

                    // Price Breakdown
                    const Text(
                      'Price Breakdown',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text('Subtotal: ${subtotal.toStringAsFixed(2)} Birr'),
                    Text(
                        'Delivery Fee: ${deliveryFee.toStringAsFixed(2)} Birr'),
                    const Divider(),
                    Text(
                      'Total: ${total.toStringAsFixed(2)} Birr',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 20),

                    // Payment Options - Radio Buttons
                    const Text(
                      'Payment Options',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(Icons.money),
                      title: const Text('Cash on Delivery'),
                      trailing: Radio<String>(
                        value: 'Cash on Delivery',
                        groupValue: _paymentMethod,
                        onChanged: (String? value) {
                          setState(() {
                            _paymentMethod = value!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.payment),
                      title: const Text('Telebirr'),
                      trailing: Radio<String>(
                        value: 'Telebirr',
                        groupValue: _paymentMethod,
                        onChanged: (String? value) {
                          setState(() {
                            _paymentMethod = value!;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Notes for Delivery
                    const Text(
                      'Delivery Instructions',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter any specific delivery instructions',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 30),

                    // Place Order Button
                    ElevatedButton(
                      onPressed: () {
                        _placeOrder(context, cartItems, total, _paymentMethod);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Place Order'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentIndex: 1,
        name: '',
        phone: '',
        email: '',
      ),
    );
  }
}
