import 'package:flutter/material.dart';
import 'package:fooddelivery/pages/food_description_screen.dart';
import 'package:fooddelivery/pages/locationserachpage.dart';
import 'package:fooddelivery/pages/searchpage.dart';
import 'package:http/http.dart' as http;
import 'package:fooddelivery/reusable/custom_bottom_navigation.dart';
import 'package:fooddelivery/reusable/fooditems.dart';
import 'package:fooddelivery/reusable/promotional_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

import 'package:geolocator/geolocator.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems = [];

  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedCategoryIndex = 0;

  String name = '';
  String email = '';
  String phone = '';
  String searchQuery = '';
  LatLng? currentLocation;
  String currentAddress = 'Loading...';
  final List<Map<String, dynamic>> recentSearches = [];
  static const defaultLocation = LatLng(9.03, 38.74);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _getCurrentLocation();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        if (mounted) {
          setState(() {
            name = userDoc['name'];
            email = userDoc['email'];
            phone = userDoc['phone'];
          });
        }
      }
    }
  }

  // Get current location and address
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          currentLocation = defaultLocation;
        });
      }
      _getAddressFromLatLng(
          defaultLocation.latitude, defaultLocation.longitude);
      return;
    }

    // Request permission if needed
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        if (mounted) {
          setState(() {
            currentLocation = defaultLocation; // Fallback location
          });
        }
        _getAddressFromLatLng(
            defaultLocation.latitude, defaultLocation.longitude);
        return;
      }
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (mounted) {
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
    }

    // Fetch and display the detailed address
    _getAddressFromLatLng(position.latitude, position.longitude);
  }

  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      // Use Nominatim (OpenStreetMap) API for detailed address
      final url =
          "https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            // Use the detailed address from Nominatim
            currentAddress = data["display_name"] ?? "Unknown location";
          });
        }
      } else {
        if (mounted) {
          setState(() {
            currentAddress = "Unable to fetch address";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          currentAddress = "Error retrieving address";
        });
      }
    }
  }

  // Change location logic
  void _changeLocation() async {
    try {
      // Navigate to the LocationSearchPage and get the result
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LocationSearchPage()),
      );

      // Check if result is not null and valid
      if (result is Map &&
          result['location'] != null &&
          result['address'] != null) {
        final location = result['location'] as LatLng;
        final address = result['address'] as String;

        setState(() {
          currentLocation = location;
          currentAddress = address; // Update address when location changes
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location not selected ")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("An error occurred while selecting location")),
      );
    }
  }

  final ScrollController _categoryScrollController = ScrollController();
  List<Map<String, dynamic>> FoodItems =
      foodItems.values.expand((list) => list).toList() ?? [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Row(
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                currentAddress,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.edit_location_alt,
                color: Colors.white,
              ),
              onPressed: _changeLocation,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchPage(
                          foodItems: FoodItems,
                          recentSearches: recentSearches,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 10),
                        const Text(
                          'Search for food or drinks',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Promotional Banner
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: buildPromotionalItems(widget.cartItems, context),
                  ),
                ),
                const SizedBox(height: 10),
                // Food Category
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Food Category',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        _categoryScrollController.animateTo(
                          _categoryScrollController.position.maxScrollExtent,
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('See more →'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    controller: _categoryScrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: foodItems.keys.length,
                    itemBuilder: (context, index) {
                      String category = foodItems.keys.elementAt(index);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategoryIndex = index;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: selectedCategoryIndex == index
                                      ? Colors.orange
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: selectedCategoryIndex == index
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food List Header
                    Text(
                      foodItems.keys.elementAt(selectedCategoryIndex),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: foodItems.values
                          .elementAt(selectedCategoryIndex)
                          .length,
                      itemBuilder: (context, index) {
                        var item = foodItems.values
                            .elementAt(selectedCategoryIndex)[index];
                        return _buildFoodCard(
                          item['name'],
                          item['time'],
                          item['calories'],
                          item['price'],
                          item['image'],
                          item['description'],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
        name: name,
        email: email,
        phone: phone,
      ),
    );
  }

  Widget _buildFoodCard(String name, String time, String calories, double price,
      String imagePath, String description) {
    return GestureDetector(
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
              description: description,
              cartItems: widget.cartItems,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: 130,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 1.0),
                    Text('$time · $calories'),
                    const SizedBox(height: 2.0),
                    Text('${price.toStringAsFixed(2)} Birr',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
