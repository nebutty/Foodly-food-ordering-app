import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartItems {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch cart items from Firestore
  // Fetch cart items from Firestore
  static Future<List<Map<String, dynamic>>> getCartItems() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        final querySnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .get();

        // Map the documents to a list of maps and add the document ID as 'id'
        return querySnapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id; // Add the document ID to the item data
          return data;
        }).toList();
      } catch (e) {
        print('Error fetching cart items: $e');
        return [];
      }
    } else {
      return [];
    }
  }

  // Add an item to the cart in Firestore
  static Future<void> addToCart(Map<String, dynamic> item) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Create a new document for the item in the cart subcollection
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .add(item);
      } catch (e) {
        print('Error adding item to cart: $e');
      }
    }
  }

  // Remove an item from the cart in Firestore
  static Future<void> removeFromCart(String itemId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Delete the item from Firestore using the document ID
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .doc(itemId)
            .delete();
      } catch (e) {
        print('Error removing item from cart: $e');
      }
    }
  }

  static Future<void> removeAllItems() async {
    try {
      // Fetch all the cart items from Firestore
      final cartItemsSnapshot =
          await FirebaseFirestore.instance.collection('cart').get();
      for (var doc in cartItemsSnapshot.docs) {
        // Delete each item from Firestore
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception("Error removing all items: $e");
    }
  }

  // Calculate subtotal (not using Firestore for this)
  static double calculateSubtotal(List<Map<String, dynamic>> cartItems) {
    return cartItems.fold(
      0.0,
      (sum, item) =>
          sum +
          (item['price'] * (item['quantity'] ?? 1)) +
          (item['addOns']
                  ?.fold(0.0, (addOnSum, addOn) => addOnSum + addOn['price']) ??
              0.0),
    );
  }

  // Clear the cart (you might want to clear it in Firestore as well)
  static Future<void> clearCart() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        final cartItemsSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .get();

        for (var doc in cartItemsSnapshot.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        print('Error clearing cart: $e');
      }
    }
  }
}
