import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllReviewsPage extends StatelessWidget {
  final String restaurantId;
  final String restaurantName;

  const AllReviewsPage({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reviews',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D1D1F),
                        ),
                      ),
                      Text(
                        restaurantName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6E6E73),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Reviews list
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('reviews')
                  .where('restaurant_id', isEqualTo: restaurantId)
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
                        'Be the first to review\nthis restaurant.',
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
                    var r = reviews[index].data();
                    var reviewRating = (r['rating'] ?? 0) as int;
                    var content = (r['content'] ?? '').toString();
                    var photoUrl = r['photo_url']?.toString();

                    var ts = r['timestamp'];
                    var date = '';
                    if (ts is Timestamp) {
                      var dt = ts.toDate();
                      const months = ['Jan','Feb','Mar','Apr','May','Jun',
                        'Jul','Aug','Sep','Oct','Nov','Dec'];
                      date = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
                    }

                    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: r['user_id'] == 'Anonymous'
                          ? const Stream.empty()
                          : FirebaseFirestore.instance
                          .collection('users')
                          .doc(r['user_id'])
                          .snapshots(),
                      builder: (context, userSnap) {
                        String reviewerName = 'Anonymous';
                        String? userPhotoUrl;

                        if (r['user_id'] == 'Anonymous') {
                          reviewerName = 'Anonymous';
                        } else if (userSnap.hasData && userSnap.data!.exists) {
                          var userData = userSnap.data!.data();
                          reviewerName = userData?['fullname'] ?? r['user_id'] ?? 'Anonymous';
                          userPhotoUrl = userData?['photo_url'] as String?;
                        }

                        var parts = reviewerName.trim().split(' ');
                        var avatarText = parts.length >= 2
                            ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
                            : reviewerName
                            .substring(0, reviewerName.length.clamp(0, 2))
                            .toUpperCase();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: const Color(0xFFE8950A),
                                    backgroundImage: userPhotoUrl != null && userPhotoUrl.isNotEmpty
                                        ? NetworkImage(userPhotoUrl)
                                        : null,
                                    child: userPhotoUrl != null && userPhotoUrl.isNotEmpty
                                        ? null
                                        : Text(
                                            avatarText,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      reviewerName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF2C2C2E),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    date,
                                    style: const TextStyle(
                                      color: Color(0xFF8E8E93),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: List.generate(
                                  5,
                                      (i) => Icon(
                                    i < reviewRating ? Icons.star : Icons.star_border,
                                    size: 16,
                                    color: const Color(0xFFE8950A),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                content,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF4A4A4F),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (photoUrl != null && photoUrl.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    photoUrl,
                                    width: double.infinity,
                                    height: 160,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                  ),
                                ),
                              ],
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