import 'package:flutter/material.dart';
import 'package:fooddelivery/pages/cartpage.dart';
import 'package:fooddelivery/reusable/cartitems.dart';
import 'package:fooddelivery/reusable/custom_bottom_navigation.dart';
import 'package:fooddelivery/reusable/favorite_items.dart';

class FoodDescriptionPage extends StatefulWidget {
  final String name;
  final String description; // Added description
  final String time;
  final String calories;
  final double price;
  final String imagePath;
  final List<Map<String, dynamic>> cartItems;

  const FoodDescriptionPage({
    super.key,
    required this.name,
    required this.description,
    this.time = 'Unknown time',
    this.calories = 'Unknown calories',
    this.price = 0.0,
    required this.imagePath,
    required this.cartItems,
  });

  @override
  State<FoodDescriptionPage> createState() => _FoodDescriptionPageState();
}

class _FoodDescriptionPageState extends State<FoodDescriptionPage> {
  int quantity = 1; // Track quantity
  final Map<String, bool> addOns = {
    'Extra Cheese': false,
    'Bacon': false,
  };

  final Map<String, double> addOnPrices = {
    'Extra Cheese': 0.99,
    'Bacon': 1.49,
  };

  bool isFavorited = false;

  void toggleFavorite() {
    setState(() {
      isFavorited = !isFavorited;
      if (isFavorited) {
        FavoriteItems.addToFavorites({
          'name': widget.name,
          'time': widget.time,
          'calories': widget.calories,
          'price': widget.price,
          'imagePath': widget.imagePath,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.name} added to favorites!'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        FavoriteItems.removeFromFavorites(widget.name);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.name} removed from favorites!'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void updateQuantity(bool increment) {
    setState(() {
      if (increment) {
        quantity++;
      } else if (quantity > 1) {
        quantity--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited ? Colors.red : null,
            ),
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              widget.imagePath,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.price.toStringAsFixed(2)} Birr',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('${widget.time} · ${widget.calories}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Description:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.description), // Dynamic description
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quantity:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => updateQuantity(false),
                          ),
                          Text(
                            '$quantity',
                            style: const TextStyle(fontSize: 18),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => updateQuantity(true),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 120),
                  ElevatedButton(
                    onPressed: () {
                      final selectedAddOns = addOns.entries
                          .where((entry) => entry.value)
                          .map((entry) => {
                                'name': entry.key,
                                'price': addOnPrices[entry.key]!,
                              })
                          .toList();

                      CartItems.addToCart({
                        'name': widget.name,
                        'description': widget.description, // Added description
                        'time': widget.time,
                        'calories': widget.calories,
                        'price': widget.price,
                        'imagePath': widget.imagePath,
                        'addOns': selectedAddOns,
                        'quantity': quantity, // Pass quantity
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Item added to cart!')),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CartPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Add to Cart'),
                  )
                ],
              ),
            ),
          ],
        ),
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
