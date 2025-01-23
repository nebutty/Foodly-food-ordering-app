import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fooddelivery/reusable/custom_bottom_navigation.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0;
  List<Map<String, dynamic>> reviews = [];
  String currentUserName = '';

  @override
  void initState() {
    super.initState();
    _fetchReviews();
    _getCurrentUser();
  }

  // Get the current user's name
  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserName =
            user.displayName ?? 'Anonymous'; // Use the user's display name
      });
    }
  }

  // Fetch reviews from Firestore
  void _fetchReviews() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .orderBy('date', descending: true)
          .get();

      setState(() {
        reviews = querySnapshot.docs.map((doc) {
          var data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? 'Anonymous', // Fallback to 'Anonymous'
            'rating': data['rating'] ?? 0, // Fallback to 0
            'comment': data['comment'] ?? '', // Fallback to an empty string
            'date': data['date'] != null
                ? data['date'].toDate()
                : DateTime.now(), // Fallback to the current date
            'uid':
                data['uid'] ?? '', // User ID to check if it's the current user
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching reviews: $e');
    }
  }

  // Add a review to Firestore
  void _addReview() async {
    if (_rating > 0 && _commentController.text.isNotEmpty) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('reviews').add({
            'name': currentUserName, // User's display name
            'rating': _rating,
            'comment': _commentController.text,
            'date': DateTime.now(),
            'uid': user.uid, // Store the user ID for update and delete checks
          });

          _resetForm();
          _fetchReviews();
          Navigator.pop(context); // Close the modal bottom sheet
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add review.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating and a comment.')),
      );
    }
  }

  void _resetForm() {
    _commentController.clear();
    _rating = 0;
  }

  void _showAddReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 16.0,
                left: 16.0,
                right: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rating:',
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          color: index < _rating ? Colors.orange : Colors.grey,
                        ),
                        onPressed: () {
                          setModalState(() {
                            _rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Comment',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Submit Review'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Delete Review
  void _deleteReview(String reviewId) async {
    try {
      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(reviewId)
          .delete();
      _fetchReviews();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete review.')),
      );
    }
  }

  // Update Review
  void _updateReview(String reviewId, String comment, int rating) async {
    try {
      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(reviewId)
          .update({
        'comment': comment,
        'rating': rating,
      });
      _fetchReviews();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update review.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      child:
                          Text(review['name']![0]), // First letter of the name
                    ),
                    title: Text(review['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(
                            review['rating'],
                            (star) => const Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 16.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(review['comment']),
                        const SizedBox(height: 4),
                        Text(
                          review['date']
                              .toString()
                              .substring(0, 10), // Format date
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: review['uid'] ==
                            FirebaseAuth.instance.currentUser?.uid
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.orange),
                                onPressed: () {
                                  _commentController.text = review['comment'];
                                  _rating = review['rating'];
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setModalState) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              top: 16.0,
                                              left: 16.0,
                                              right: 16.0,
                                              bottom: MediaQuery.of(context)
                                                      .viewInsets
                                                      .bottom +
                                                  16.0,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text('Rating:'),
                                                Row(
                                                  children:
                                                      List.generate(5, (index) {
                                                    return IconButton(
                                                      icon: Icon(
                                                        Icons.star,
                                                        color: index < _rating
                                                            ? Colors.orange
                                                            : Colors.grey,
                                                      ),
                                                      onPressed: () {
                                                        setModalState(() {
                                                          _rating = index + 1;
                                                        });
                                                      },
                                                    );
                                                  }),
                                                ),
                                                TextField(
                                                  controller:
                                                      _commentController,
                                                  maxLines: 4,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Comment',
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    _updateReview(
                                                        review['id'],
                                                        _commentController.text,
                                                        _rating);
                                                    Navigator.pop(context);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.orange,
                                                    minimumSize: const Size(
                                                        double.infinity, 50),
                                                  ),
                                                  child: const Text(
                                                      'Update Review'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.orange),
                                onPressed: () {
                                  _deleteReview(review['id']);
                                },
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showAddReviewSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Add Review'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentIndex: 3,
        name: '',
        phone: '',
        email: '',
      ),
    );
  }
}
