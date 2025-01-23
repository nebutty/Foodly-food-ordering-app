import 'package:flutter/material.dart';
import 'package:fooddelivery/pages/food_description_screen.dart';

class PromotionalItem extends StatelessWidget {
  final String title;
  final String imagePath;
  final String description;
  final List<Map<String, dynamic>> cartItems;

  const PromotionalItem({
    super.key,
    required this.title,
    required this.imagePath,
    required this.description,
    required this.cartItems,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDescriptionPage(
              name: title,
              time: '10-15 min', // Example delivery time
              calories: '300-400 cal', // Example calorie info
              price: 8.99, // Example price
              imagePath: imagePath,
              cartItems: cartItems,
              description: description,
            ),
          ),
        );
      },
      child: Container(
        width: 160, // Decreased the width for compact design
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.symmetric(
            horizontal: 8.0), // Add spacing between items
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2), // Add a subtle shadow for depth
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: 64, // Reduced height to fit smaller items
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1, // Limit to one line for cleaner design
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
              maxLines: 2, // Limit to two lines for compactness
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// List of promotional items
final List<Map<String, String>> promotionalItems = [
  {
    'title': 'Burger Discount',
    'imagePath': 'assets/burgers/chiken.png',
    'description': ' Burger with 25% off!',
  },
  {
    'title': 'Pizza Discount',
    'imagePath': 'assets/pizza/pizza.jpg',
    'description': 'Cheesy Pizza with 30% off!',
  },
  {
    'title': 'Sushi Offer',
    'imagePath': 'assets/shshi/sushi.jpg',
    'description': ' buy one get one free!',
  },
  {
    'title': 'mandi Discount',
    'imagePath': 'assets/mandi/mandi3.png',
    'description': 'Cheesy Pizza with 30% off!',
  },
  {
    'title': 'ramen Discount',
    'imagePath': 'assets/ramen/ramen.jpg',
    'description': 'Cheesy Pizza with 30% off!',
  },
];

// Helper function to generate widgets
List<Widget> buildPromotionalItems(
    List<Map<String, dynamic>> cartItems, BuildContext context) {
  return promotionalItems.map((item) {
    return PromotionalItem(
      title: item['title']!,
      imagePath: item['imagePath']!,
      description: item['description']!,
      cartItems: cartItems,
    );
  }).toList();
}
