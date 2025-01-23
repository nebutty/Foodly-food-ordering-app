import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Future<void> _deleteOrder(String userId, String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('orderhistory')
          .doc(orderId)
          .delete();
      print('Order deleted successfully.');
    } catch (e) {
      print('Error deleting order: $e');
    }
  }

  Future<void> _deleteAllOrders(String userId) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final ordersRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('orderhistory');

      final snapshot = await ordersRef.get();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('All orders deleted successfully.');
    } catch (e) {
      print('Error deleting all orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(
        child: Text('You must be logged in to view order history.'),
      );
    }

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('orderhistory')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Order History'),
                backgroundColor: Colors.orange,
              ),
              body: const Center(child: Text('No orders found.')),
            );
          } else {
            final orders = snapshot.data!.docs;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Order History'),
                backgroundColor: Colors.orange,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final confirmation = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete All Orders'),
                          content: const Text(
                              'Are you sure you want to delete all your order history?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirmation == true) {
                        await _deleteAllOrders(userId);
                      }
                    },
                  ),
                ],
              ),
              body: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final orderId = order.id;
                  final items = order['items'] as List<dynamic>;
                  final total = order['total'] as double;
                  final timestamp =
                      (order['timestamp'] as Timestamp?)?.toDate();

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        'Order Total: ${total.toStringAsFixed(2)} Birr',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...items.map((item) {
                            final name = item['name'];
                            final price = item['price'];
                            return Text(
                                '$name: ${price.toStringAsFixed(2)} Birr');
                          }),
                          if (timestamp != null)
                            Text('Ordered on: ${timestamp.toLocal()}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirmation = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Order'),
                              content: const Text(
                                  'Are you sure you want to delete this order?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirmation == true) {
                            await _deleteOrder(userId, orderId);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
