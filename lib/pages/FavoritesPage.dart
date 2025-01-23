import 'package:flutter/material.dart';
import 'package:fooddelivery/pages/food_description_screen.dart';
import 'package:fooddelivery/reusable/custom_bottom_navigation.dart';
import 'package:fooddelivery/reusable/favorite_items.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future:
          FavoriteItems.getFavorites(), // Fetch favorite items from Firestore
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Favorites'),
              backgroundColor: Colors.orange,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
            bottomNavigationBar: const CustomBottomNavigationBar(
              currentIndex: 2,
              name: '',
              phone: '',
              email: '',
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Favorites'),
              backgroundColor: Colors.orange,
            ),
            body: const Center(
              child: Text(
                'Error fetching favorites.',
                style: TextStyle(fontSize: 18),
              ),
            ),
            bottomNavigationBar: const CustomBottomNavigationBar(
              currentIndex: 2,
              name: '',
              phone: '',
              email: '',
            ),
          );
        } else {
          final favorites = FavoriteItems.getFavoritesLocal();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Favorites'),
              backgroundColor: Colors.orange,
            ),
            body: favorites.isEmpty
                ? const Center(
                    child: Text(
                      'No favorites yet!',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final item = favorites[index];

                      // Handle null values by providing default values
                      final name = item['name'] ?? 'Unknown Name';
                      final price = item['price'] ?? 0.0;
                      final imagePath = item['imagePath'] ??
                          'assets/burgers/burger.png'; // Default image if not available
                      final time = item['time'] ?? 'N/A';
                      final calories = item['calories'] ?? 'N/A';
                      final description =
                          item['description'] ?? 'No description available.';

                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: Image.asset(
                            imagePath,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(name),
                          subtitle: Text('${price.toStringAsFixed(2)} Birr'),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () {
                              FavoriteItems.removeFromFavorites(name);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('$name removed from favorites.'),
                                ),
                              );
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FoodDescriptionPage(
                                  name: name,
                                  time: time,
                                  calories: calories,
                                  price: price,
                                  imagePath: imagePath,
                                  cartItems: const [],
                                  description: description,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
            bottomNavigationBar: const CustomBottomNavigationBar(
              currentIndex: 2,
              name: '',
              phone: '',
              email: '',
            ),
          );
        }
      },
    );
  }
}
