import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'write_review.dart';

class RestaurantDetailPage extends StatefulWidget {
  final String restaurantId;

  RestaurantDetailPage({
    super.key,
    required this.restaurantId,
  });

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  String? get uid => auth.currentUser?.uid;

  Future<void> toggleSaved(BuildContext context, bool currentlySaved) async {
    var currentUid = uid;
    if (currentUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in to save places')),
      );
      return;
    }

    var docRef = firestore.collection('saved').doc(currentUid);

    try {
      if (currentlySaved) {
        await docRef.update({
          'saved_restaurants': FieldValue.arrayRemove([widget.restaurantId])
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed from saved')),
        );
      } else {
        await docRef.set({
          'saved_restaurants': FieldValue.arrayUnion([widget.restaurantId])
        }, SetOptions(merge: true));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update saved: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var docRef = FirebaseFirestore.instance
        .collection('tbl_restaurants')
        .doc(widget.restaurantId);

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F7),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: docRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load restaurant details.'));
          }
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(color: Color(0xFFE8950A)),
            );
          }

          var data = snapshot.data!.data();
          if (data == null) {
            return Center(child: Text('Restaurant not found.'));
          }

          var name = (data['name'] ?? '').toString();
          var category = (data['category'] ?? '').toString();
          var address = (data['address'] ?? '').toString();
          var rating = (data['rating'] ?? 0).toString();
          var reviewsCount = (data['reviews_count'] ?? 0).toString();

          return Column(
            children: [
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Container(
                      margin: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Color(0xFFF2F2F5),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: Color(0xFFE3E3E8)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xFFF3EFE6),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(26),
                                topRight: Radius.circular(26),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(14, 10, 14, 18),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Back button
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size(34, 34),
                                          shape: CircleBorder(),
                                          backgroundColor: Colors.white,
                                        ),
                                        child: Icon(Icons.arrow_back, size: 18, color: Color(0xFF3A3A3C)),
                                      ),

                                      Text('...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3A3A3C))),

                                      if (uid == null)
                                        TextButton(
                                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Sign in to save places')),
                                          ),
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size(34, 34),
                                            shape: CircleBorder(),
                                            backgroundColor: Colors.white,
                                          ),
                                          child: Icon(Icons.bookmark_border_rounded, size: 18, color: Color(0xFF3A3A3C)),
                                        )
                                      else
                                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                          stream: firestore.collection('saved').doc(uid).snapshots(),
                                          builder: (context, savedSnap) {
                                            var isSaved = false;
                                            if (savedSnap.hasData && savedSnap.data!.exists) {
                                              var savedData = savedSnap.data!.data();
                                              var arr = savedData?['saved_restaurants'] as List<dynamic>?;
                                              isSaved = arr?.contains(widget.restaurantId) == true;
                                            }
                                            // Bookmark button
                                            return TextButton(
                                              onPressed: () => toggleSaved(context, isSaved),
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: Size(34, 34),
                                                shape: CircleBorder(),
                                                backgroundColor: Colors.white,
                                              ),
                                              child: Icon(
                                                isSaved ? Icons.bookmark : Icons.bookmark_border_rounded,
                                                size: 18,
                                                color: Color(0xFF3A3A3C),
                                              ),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 14),
                                  Text('🍜', style: TextStyle(fontSize: 56)),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Color(0xFF1C1C1E))),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF3D79A),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        category.isEmpty ? 'Category' : category,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF76520A),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(Icons.star, size: 17, color: Color(0xFFE8950A)),
                                    SizedBox(width: 4),
                                    Text(rating, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2C2C2E))),
                                    SizedBox(width: 8),
                                    Text('$reviewsCount reviews', style: TextStyle(fontSize: 20, color: Color(0xFF9A9AA1), fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, size: 18, color: Color(0xFFE8950A)),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        address.isEmpty ? 'No address' : address,
                                        style: TextStyle(fontSize: 18, color: Color(0xFF55555A), fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Container(height: 1, color: Color(0xFFDADADF)),
                                SizedBox(height: 12),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Reviews', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Color(0xFF1C1C1E), letterSpacing: -0.6)),
                                    Text('See all', style: TextStyle(fontSize: 20, color: Color(0xFFE8950A), fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                SizedBox(height: 12),

                                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                  stream: FirebaseFirestore.instance
                                      .collection('reviews')
                                      .where('restaurant_id', isEqualTo: widget.restaurantId)
                                      .orderBy('timestamp', descending: true)
                                      .limit(5)
                                      .snapshots(),
                                  builder: (context, reviewSnap) {
                                    if (reviewSnap.hasError) {
                                      return Text('Failed to load reviews.');
                                    }
                                    if (!reviewSnap.hasData) {
                                      return Center(
                                        child: CircularProgressIndicator(color: Color(0xFFE8950A)),
                                      );
                                    }

                                    var reviews = reviewSnap.data!.docs;

                                    if (reviews.isEmpty) {
                                      return Text(
                                        'No reviews yet. Be the first!',
                                        style: TextStyle(color: Color(0xFF9A9AA1), fontSize: 16),
                                      );
                                    }

                                    return Column(
                                      children: reviews.asMap().entries.map((entry) {
                                        var i = entry.key;
                                        var r = entry.value.data();

                                        var reviewRating = (r['rating'] ?? 0) as int;
                                        var text = (r['content'] ?? '').toString();
                                        var photoUrl = r['photo_url']?.toString();

                                        var ts = r['timestamp'];
                                        var date = '';
                                        if (ts is Timestamp) {
                                          var dt = ts.toDate();
                                          const months = ['Jan','Feb','Mar','Apr','May','Jun',
                                            'Jul','Aug','Sep','Oct','Nov','Dec'];
                                          date = '${months[dt.month - 1]} ${dt.day}';
                                        }

                                        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                          stream: r['user_id'] == 'Anonymous'
                                              ? const Stream.empty()
                                              : FirebaseFirestore.instance
                                              .collection('vvusers')
                                              .doc(r['user_id'])
                                              .snapshots(),
                                          builder: (context, userSnap) {
                                            String reviewerName = 'Anonymous';

                                            if (r['user_id'] == 'Anonymous') {
                                              reviewerName = 'Anonymous';
                                            } else if (userSnap.hasData && userSnap.data!.exists) {
                                              var userData = userSnap.data!.data();
                                              reviewerName = userData?['vvfullname']
                                                  ?? r['user_id']
                                                  ?? 'Anonymous';
                                            }

                                            var parts = reviewerName.trim().split(' ');
                                            var avatarText = parts.length >= 2
                                                ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
                                                : reviewerName
                                                .substring(0, reviewerName.length.clamp(0, 2))
                                                .toUpperCase();

                                            return Column(
                                              children: [
                                                Container(
                                                  width: double.infinity,
                                                  padding: EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFECECF1),
                                                    borderRadius: BorderRadius.circular(14),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 16,
                                                            backgroundColor: Color(0xFFE8950A),
                                                            child: Text(avatarText, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                                                          ),
                                                          SizedBox(width: 8),
                                                          Expanded(
                                                            child: Text(reviewerName, style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2C2C2E))),
                                                          ),
                                                          Text(date, style: TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.w600)),
                                                        ],
                                                      ),
                                                      SizedBox(height: 8),
                                                      Row(
                                                        children: List.generate(
                                                          5,
                                                              (index) => Icon(index < reviewRating ? Icons.star : Icons.star_border, size: 16, color: Color(0xFFE8950A)),
                                                        ),
                                                      ),
                                                      SizedBox(height: 6),
                                                      Text(text, style: TextStyle(fontSize: 16, color: Color(0xFF4A4A4F), fontWeight: FontWeight.w600)),
                                                      if (photoUrl != null && photoUrl.isNotEmpty) ...[
                                                        SizedBox(height: 10),
                                                        ClipRRect(
                                                          borderRadius: BorderRadius.circular(10),
                                                          child: Image.network(
                                                            photoUrl,
                                                            width: double.infinity,
                                                            height: 120,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (_, __, ___) => Container(
                                                              width: double.infinity,
                                                              height: 52,
                                                              decoration: BoxDecoration(color: Color(0xFFE8E2D6), borderRadius: BorderRadius.circular(10)),
                                                              alignment: Alignment.center,
                                                              child: Text('📷 Food photo', style: TextStyle(color: Color(0xFF9A8F7A), fontWeight: FontWeight.w700)),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                                if (i < reviews.length - 1) SizedBox(height: 12),
                                              ],
                                            );
                                          },
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE8950A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WriteReviewPage(
                            restaurantId: widget.restaurantId,
                            restaurantName: name,
                          ),
                        ),
                      );
                    },
                    child: Text('+ Write a review', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}