import 'package:flutter/material.dart';
import 'package:fooddelivery/pages/checkoutpage.dart';
import 'package:fooddelivery/reusable/cartitems.dart';
import 'package:fooddelivery/reusable/custom_bottom_navigation.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
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
            final subtotal = CartItems.calculateSubtotal(cartItems);
            final tax = subtotal * 0.15; // 15% tax
            const deliveryFee = 5.0;
            final total = subtotal + tax + deliveryFee;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final addOns = item['addOns'] ?? [];
                      final itemId = item['id'];

                      if (itemId == null) {
                        return const Center(child: Text('Invalid Item ID'));
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: ListTile(
                          leading: Image.asset(
                            item['imagePath'] ?? 'assets/default_image.png',
                            width: 50,
                            height: 50,
                          ),
                          title: Text(item['name'] ?? 'Unknown Name'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Price: ${item['price'] ?? 0.0} Birr x ${item['quantity'] ?? 1}',
                              ),
                              if (addOns.isNotEmpty)
                                Text(
                                  'Add-ons: ${addOns.map((addOn) => addOn['name'] ?? 'Unknown').join(", ")}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                if (itemId != null) {
                                  await CartItems.removeFromCart(itemId);
                                  if (mounted) {
                                    setState(() {});
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Cannot remove item without valid ID'),
                                    ),
                                  );
                                }
                              }),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Subtotal: ${subtotal.toStringAsFixed(2)} Birr'),
                      Text('Tax (15%): ${tax.toStringAsFixed(2)} Birr'),
                      Text(
                          'Delivery Fee: ${deliveryFee.toStringAsFixed(2)} Birr'),
                      const Divider(),
                      Text(
                        'Total: ${total.toStringAsFixed(2)} Birr',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CheckoutPage(),
                            ),
                          );
                          setState(() {}); // Refresh the UI
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Proceed to Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentIndex: 1,
        name: '',
        email: '',
        phone: '',
      ),
    );
  }
}
