import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'restaurant_detail.dart';

class SavedPage extends StatefulWidget {
  SavedPage({Key? key}) : super(key: key);

  @override
  State<SavedPage> createState() => SavedPageState();
}

class SavedPageState extends State<SavedPage> {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  String? get uid => auth.currentUser?.uid;

  Future<void> removeSaved(String restaurantId) async {
    if (uid == null) return;
    await firestore.collection('saved').doc(uid).update({
      'saved_restaurants': FieldValue.arrayRemove([restaurantId])
    });
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return Center(child: Text('Sign in to see saved places'));
    }

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saved',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D1D1F),
                ),
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: firestore.collection('saved').doc(uid).snapshots(),
                builder: (context, snapshot) {
                  var count = 0;
                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>?;
                    count = (data?['saved_restaurants'] as List<dynamic>?)?.length ?? 0;
                  }
                  return Text(
                    '$count places',
                    style: const TextStyle(
                      color: Color(0xFFE8950A),
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<DocumentSnapshot>(
            stream: firestore.collection('saved').doc(uid).snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFE8950A)));
              }

              var doc = snap.data;
              if (doc == null || !doc.exists) {
                return const Center(child: Text('No saved places yet'));
              }

              var data = doc.data() as Map<String, dynamic>? ?? {};
              var savedIds = data['saved_restaurants'] as List<dynamic>? ?? [];

              if (savedIds.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8EC),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.bookmark_outline_rounded,
                        color: Color(0xFFE8950A),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No saved places yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D1D1F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the bookmark icon on any\nrestaurant to save it here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6E6E73),
                      ),
                    ),
                  ],
                );
              }

              var futures = savedIds.map<Future<DocumentSnapshot>>((id) {
                return firestore.collection('tbl_restaurants').doc(id as String).get();
              }).toList();

              return FutureBuilder<List<DocumentSnapshot>>(
                future: Future.wait(futures),
                builder: (context, restaurantsSnap) {
                  if (restaurantsSnap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFE8950A)));
                  }

                  var restaurants = restaurantsSnap.data ?? [];

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      var rDoc = restaurants[index];
                      if (!rDoc.exists) return const SizedBox.shrink();
                      var r = rDoc.data() as Map<String, dynamic>? ?? {};
                      var name = r['name'] ?? 'Unnamed';
                      var category = r['category'] ?? '';
                      var address = r['address'] ?? '';
                      var rating = (r['rating'] is num) ? (r['rating'] as num).toDouble() : 0.0;
                      var reviewsCount = r['reviews_count']?.toString() ?? '0';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RestaurantDetailPage(
                                  restaurantId: rDoc.id,
                                ),
                              ),
                            );
                          },
                          leading: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8EC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.restaurant,
                              color: Color(0xFFE8950A),
                              size: 28,
                            ),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1D1D1F),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.isNotEmpty ? '$category · $address' : address,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6E6E73),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Color(0xFFE8950A), size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${rating.toStringAsFixed(1)} · $reviewsCount reviews',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6E6E73),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.bookmark, color: Color(0xFFE8950A)),
                            onPressed: () => removeSaved(rDoc.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}