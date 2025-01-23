import 'package:flutter/material.dart';
import 'package:fooddelivery/pages/food_description_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> foodItems;
  final List<Map<String, dynamic>> recentSearches;

  const SearchPage({
    Key? key,
    required this.foodItems,
    required this.recentSearches,
  }) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = '';
  late FirebaseFirestore _firestore;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;

    final user = FirebaseAuth.instance.currentUser;
    String userId = user?.uid ?? 'defaultUserId'; // Get the actual userId here

    // Load recent searches on initialization
    _loadRecentSearches(userId);
  }

  Future<void> _loadRecentSearches(String userId) async {
    try {
      var collection = _firestore
          .collection('users')
          .doc(userId)
          .collection('recent_searches');
      var snapshot =
          await collection.orderBy('timestamp', descending: true).get();
      var searches = snapshot.docs
          .map((doc) => doc.data())
          .cast<Map<String, dynamic>>()
          .toList();
      setState(() {
        widget.recentSearches.clear();
        widget.recentSearches.addAll(searches);
      });
    } catch (e) {
      debugPrint('Failed to load recent searches: $e');
    }
  }

  Future<void> _saveSearch(String userId, Map<String, dynamic> item) async {
    var collection = _firestore
        .collection('users')
        .doc(userId)
        .collection('recent_searches');
    await collection.add({
      ...item,
      'timestamp': FieldValue.serverTimestamp(),
    });
    setState(() {
      widget.recentSearches.add(item);
    });
  }

  Future<void> _removeSearch(String userId, Map<String, dynamic> item) async {
    var collection = _firestore
        .collection('users')
        .doc(userId)
        .collection('recent_searches');
    var querySnapshot =
        await collection.where('name', isEqualTo: item['name']).limit(1).get();
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
    setState(() {
      widget.recentSearches.remove(item);
    });
  }

  Future<void> _clearSearches(String userId) async {
    var collection = _firestore
        .collection('users')
        .doc(userId)
        .collection('recent_searches');
    var querySnapshot = await collection.get();
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
    setState(() {
      widget.recentSearches.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = searchQuery.isEmpty
        ? []
        : widget.foodItems
            .where((item) =>
                item['name'].toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

    final user = FirebaseAuth.instance.currentUser;
    String userId = user?.uid ?? 'defaultUserId'; // Get the actual userId here

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange, // Orange theme color
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search for food or drinks...',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.orange),
            ),
            onChanged: (value) => setState(() {
              searchQuery = value;
            }),
          ),
        ),
      ),
      body: Container(
        color: Colors.orange[50], // Light orange background
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.recentSearches.isNotEmpty) ...[
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange, // Orange for headings
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                children: widget.recentSearches.map((item) {
                  return Chip(
                    backgroundColor: Colors.orange[100], // Lighter orange
                    label: Text(item['name']),
                    onDeleted: () async {
                      await _removeSearch(userId, item);
                    },
                    deleteIcon: const Icon(Icons.close, color: Colors.orange),
                  );
                }).toList(),
              ),
              TextButton(
                onPressed: () async {
                  await _clearSearches(userId);
                },
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              const Divider(),
            ],
            const Text(
              'Search Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange, // Consistent orange color
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  var item = filteredItems[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          item['image'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        item['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange, // Title text in orange
                        ),
                      ),
                      subtitle: Text('${item['calories']} Calories'),
                      trailing: Text('\$${item['price']}'),
                      onTap: () {
                        _saveSearch(userId, item); // Save search history
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodDescriptionPage(
                              name: item['name'],
                              time: item['time'],
                              calories: item['calories'],
                              price: item['price'],
                              imagePath: item['image'],
                              description: item['description'],
                              cartItems: [],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
