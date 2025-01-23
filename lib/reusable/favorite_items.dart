import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteItems {
  static final List<Map<String, dynamic>> _favorites = [];

  // Make FirebaseAuth and FirebaseFirestore static
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add item to Firestore and local favorites list
  static Future<void> addToFavorites(Map<String, dynamic> item) async {
    User? user = _auth.currentUser; // Use the static _auth
    if (user != null) {
      try {
        // Use the static _firestore instance
        await _firestore
            .collection('users') // Parent collection
            .doc(user.uid) // Document for the user
            .collection('favorites') // Subcollection for favorites
            .add({
          'name': item['name'],
          'price': item['price'],
        });

        // Optionally, add the item to the local _favorites list
        _favorites.add(item);
      } catch (e) {
        print('Error adding item to favorites: $e');
      }
    }
  }

  // Remove item from Firestore and local favorites list
  static Future<void> removeFromFavorites(String name) async {
    User? user = _auth.currentUser; // Use the static _auth
    if (user != null) {
      try {
        final item = _favorites.firstWhere((item) => item['name'] == name);
        final favoriteQuery = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .where('name', isEqualTo: item['name'])
            .get();

        // Remove item from Firestore
        for (var doc in favoriteQuery.docs) {
          doc.reference.delete();
        }

        // Remove item from the local list
        _favorites.removeWhere((item) => item['name'] == name);
      } catch (e) {
        print('Error removing item from favorites: $e');
      }
    }
  }

  // Retrieve favorite items from Firestore and populate the local list
  static Future<void> getFavorites() async {
    User? user = _auth.currentUser; // Use the static _auth
    if (user != null) {
      try {
        final querySnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .get();

        _favorites.clear(); // Clear the existing local list

        // Add the fetched items to the local list
        for (var doc in querySnapshot.docs) {
          _favorites.add(doc.data());
        }
      } catch (e) {
        print('Error fetching favorite items: $e');
      }
    }
  }

  // Getter to access the favorite items locally
  static List<Map<String, dynamic>> getFavoritesLocal() {
    return _favorites;
  }
}
