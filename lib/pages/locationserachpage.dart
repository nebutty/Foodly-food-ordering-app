import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationSearchPage extends StatefulWidget {
  const LocationSearchPage({super.key});

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  LatLng? selectedLocation;
  String selectedAddress = "No location selected";
  LatLng? currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
      selectedLocation = currentLocation;
      selectedAddress = "Current Location";
      _searchController.text = selectedAddress;
    });

    _getAddressFromLatLng(position.latitude, position.longitude);
  }

  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      final url =
          "https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          selectedAddress = data["display_name"] ?? "Unknown location";
          _searchController.text = selectedAddress;
        });
      }
    } catch (e) {
      setState(() {
        selectedAddress = "Unable to get address";
        _searchController.text = selectedAddress;
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    final url =
        "https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (mounted) {
          setState(() {
            searchResults = data;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error fetching location")),
        );
      }
    }
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      selectedLocation = location;
      currentLocation = location;
      _getAddressFromLatLng(location.latitude, location.longitude);
    });
  }

  void _onSearchResultTap(LatLng location, String address) {
    setState(() {
      selectedLocation = location;
      currentLocation = location;
      selectedAddress = address;
      _searchController.text = selectedAddress; // Update the search text
    });
  }

  void _saveLocation() {
    if (selectedLocation != null) {
      Navigator.pop(
        context,
        {'location': selectedLocation, 'address': selectedAddress},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a location")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Delivery Address"), // AppBar title updated
        elevation: 0,
      ),
      body: SingleChildScrollView(
        // Wrapping the entire body in a SingleChildScrollView
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orangeAccent, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // Map container
              Container(
                height: 400.0,
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: FlutterMap(
                    options: MapOptions(
                      center: selectedLocation ??
                          currentLocation ??
                          LatLng(9.03, 38.74),
                      zoom: 13.0,
                      onTap: (tapPosition, point) {
                        _onMapTapped(point);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                      ),
                      if (selectedLocation != null || currentLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: selectedLocation ?? currentLocation!,
                              builder: (ctx) => const Icon(
                                Icons.location_pin,
                                size: 40.0,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // Search bar container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchLocation,
                  decoration: InputDecoration(
                    hintText: "Search for a location...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),

              // Search results list
              SizedBox(
                height: 200, // Limit the height to avoid overflow
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final result = searchResults[index];
                    final lat = double.parse(result["lat"]);
                    final lon = double.parse(result["lon"]);
                    final location = LatLng(lat, lon);
                    return ListTile(
                      title: Text(result["display_name"] ?? "Unnamed location"),
                      onTap: () {
                        _onSearchResultTap(location, result["display_name"]);
                      },
                    );
                  },
                ),
              ),

              // Save Location Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _saveLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 40.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text("Save Location"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
