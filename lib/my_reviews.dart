import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'restaurant_detail.dart';

class MyReviewsPage extends StatelessWidget {
  final String uid;

  const MyReviewsPage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Column(
        children: [

          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Icon(Icons.arrow_back, color: Color(0xFF1D1D1F)),
                ),
                const SizedBox(width: 12),
                const Text(
                  'My Reviews',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
              ],
            ),
          ),

          // Reviews list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reviews')
                  .where('user_id', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE8950A)),
                  );
                }

                var reviews = snapshot.data!.docs;

                if (reviews.isEmpty) {
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
                          Icons.star_outline_rounded,
                          color: Color(0xFFE8950A),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No reviews yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D1D1F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your reviews will appear here\nafter you write one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6E6E73),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    var r = reviews[index].data() as Map<String, dynamic>;
                    var reviewRating = (r['rating'] ?? 0) as int;
                    var content = (r['content'] ?? '').toString();
                    var restaurantId = (r['restaurant_id'] ?? '').toString();
                    var photoUrl = r['photo_url']?.toString();

                    var ts = r['timestamp'];
                    var date = '';
                    if (ts is Timestamp) {
                      var dt = ts.toDate();
                      const months = ['Jan','Feb','Mar','Apr','May','Jun',
                        'Jul','Aug','Sep','Oct','Nov','Dec'];
                      date = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
                    }

                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('tbl_restaurants')
                          .doc(restaurantId)
                          .snapshots(),
                      builder: (context, restSnap) {
                        var restaurantName = 'Restaurant';
                        var restaurantCategory = '';
                        if (restSnap.hasData && restSnap.data!.exists) {
                          var restData = restSnap.data!.data() as Map<String, dynamic>;
                          restaurantName = restData['name'] ?? 'Restaurant';
                          restaurantCategory = restData['category'] ?? '';
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            restaurantName,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1D1D1F),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          date,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFFAEAEB2),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (restaurantCategory.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        restaurantCategory,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6E6E73),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Row(
                                      children: List.generate(
                                        5,
                                            (i) => Icon(
                                          i < reviewRating ? Icons.star_rounded : Icons.star_outline_rounded,
                                          size: 16,
                                          color: const Color(0xFFE8950A),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      content,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF4A4A4F),
                                      ),
                                    ),
                                    if (photoUrl != null && photoUrl.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          photoUrl,
                                          width: double.infinity,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Color(0xFFFF3B30), size: 20),
                                  onPressed: () async {
                                    bool? confirm = await showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Review'),
                                        content: const Text('Are you sure you want to delete this review?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, false),
                                            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6E6E73))),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF3B30))),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await FirebaseFirestore.instance.collection('reviews').doc(reviews[index].id).delete();

                                      // Optional: recount total average for restaurant
                                      var allRestReviews = await FirebaseFirestore.instance
                                          .collection('reviews')
                                          .where('restaurant_id', isEqualTo: restaurantId)
                                          .get();
                                      var docs = allRestReviews.docs;
                                      var count = docs.length;
                                      var total = 0.0;
                                      for (var d in docs) {
                                        total += ((d.data()['rating'] ?? 0) as num).toDouble();
                                      }
                                      var newAvg = count > 0 ? total / count : 0.0;

                                      await FirebaseFirestore.instance
                                          .collection('tbl_restaurants')
                                          .doc(restaurantId)
                                          .update({
                                        'reviews_count': count,
                                        'rating': double.parse(newAvg.toStringAsFixed(1)),
                                      });

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Review deleted')),
                                        );
                                      }
                                    }
                                  },
                                ),
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
          ),
        ],
      ),
    );
  }
}