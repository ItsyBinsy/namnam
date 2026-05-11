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
    var docRef = firestore.collection('saved').doc(uid);
    await docRef.update({
      'saved_restaurants': FieldValue.arrayRemove([restaurantId])
    });
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Saved')),
        body: Center(child: Text('Sign in to see saved places')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Saved'),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: firestore.collection('saved').doc(uid).snapshots(),
            builder: (context, snapshot) {
              var doc = snapshot.data;
              var count = (doc?.data() as Map<String, dynamic>?)?['saved_restaurants']?.length ?? 0;
              return Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Center(child: Text('$count places', style: TextStyle(color: Colors.orange))),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: firestore.collection('saved').doc(uid).snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          var doc = snap.data;
          if (doc == null || !doc.exists) {
            return Center(child: Text('No saved places yet'));
          }
          var data = doc.data() as Map<String, dynamic>? ?? {};
          var savedIds = data['saved_restaurants'] as List<dynamic>? ?? [];

          if (savedIds.isEmpty) {
            return Center(child: Text('Your saved places will appear here.'));
          }

          var futures = savedIds.map<Future<DocumentSnapshot>>((id) {
            return firestore.collection('tbl_restaurants').doc(id as String).get();
          }).toList();

          return FutureBuilder<List<DocumentSnapshot>>(
            future: Future.wait(futures),
            builder: (context, restaurantsSnap) {
              if (restaurantsSnap.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              var restaurants = restaurantsSnap.data ?? [];
              return ListView.separated(
                padding: EdgeInsets.all(16),
                itemCount: restaurants.length,
                separatorBuilder: (_, __) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  var rDoc = restaurants[index];
                  if (!rDoc.exists) return SizedBox.shrink();
                  var r = rDoc.data() as Map<String, dynamic>? ?? {};
                  var name = r['name'] ?? 'Unnamed';
                  var category = r['category'] ?? '';
                  var address = r['address'] ?? '';
                  var rating = (r['rating'] is num) ? (r['rating'] as num).toDouble() : 0.0;
                  var reviewsCount = r['reviews_count']?.toString() ?? '0';

                  return Material(
                    elevation: 0.6,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(Icons.restaurant_menu, color: Colors.orange.shade400),
                          ),
                        ),
                        title: Text(name, style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              category.isNotEmpty ? '$category · $address' : address,
                              style: TextStyle(color: Colors.black54, fontSize: 13),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.orange.shade400, size: 16),
                                SizedBox(width: 4),
                                Text(rating.toStringAsFixed(1), style: TextStyle(fontWeight: FontWeight.w600)),
                                SizedBox(width: 8),
                                Text('· $reviewsCount reviews', style: TextStyle(color: Colors.black54, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.bookmark, color: Colors.orange),
                          onPressed: () => removeSaved(rDoc.id),
                          tooltip: 'Remove saved place',
                        ),
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
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}