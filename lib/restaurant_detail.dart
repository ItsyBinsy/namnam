import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'write_review.dart';

class RestaurantDetailPage extends StatelessWidget {
  final String restaurantId;

  const RestaurantDetailPage({
    super.key,
    required this.restaurantId,
  });

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance
        .collection('tbl_restaurants')
        .doc(restaurantId);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: docRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Failed to load restaurant details.'));
            }
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFE8950A)),
              );
            }

            final data = snapshot.data!.data();
            if (data == null) {
              return const Center(child: Text('Restaurant not found.'));
            }

            final name = (data['name'] ?? '').toString();
            final category = (data['category'] ?? '').toString();
            final address = (data['address'] ?? '').toString();
            final rating = (data['rating'] ?? 0).toString();
            final reviewsCount = (data['reviews_count'] ?? 0).toString();

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F5),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: const Color(0xFFE3E3E8)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3EFE6),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(26),
                                topRight: Radius.circular(26),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _circleIconButton(
                                        icon: Icons.arrow_back,
                                        onTap: () => Navigator.pop(context),
                                      ),
                                      const Text('...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3A3A3C))),
                                      _circleIconButton(icon: Icons.bookmark_border_rounded, onTap: () {}),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  const Text('🍜', style: TextStyle(fontSize: 56)),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Color(0xFF1C1C1E))),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _pill(category.isEmpty ? 'Category' : category),
                                    const SizedBox(width: 10),
                                    const Icon(Icons.star, size: 17, color: Color(0xFFE8950A)),
                                    const SizedBox(width: 4),
                                    Text(rating, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2C2C2E))),
                                    const SizedBox(width: 8),
                                    Text('$reviewsCount reviews', style: const TextStyle(fontSize: 20, color: Color(0xFF9A9AA1), fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFFE8950A)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        address.isEmpty ? 'No address' : address,
                                        style: const TextStyle(fontSize: 18, color: Color(0xFF55555A), fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(height: 1, color: const Color(0xFFDADADF)),
                                const SizedBox(height: 12),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text('Reviews', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Color(0xFF1C1C1E), letterSpacing: -0.6)),
                                    Text('See all', style: TextStyle(fontSize: 20, color: Color(0xFFE8950A), fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                  stream: FirebaseFirestore.instance
                                      .collection('reviews')
                                      .where('restaurant_id', isEqualTo: restaurantId)
                                      .orderBy('timestamp', descending: true)
                                      .limit(5)
                                      .snapshots(),
                                  builder: (context, reviewSnap) {
                                    if (reviewSnap.hasError) {
                                      return const Text('Failed to load reviews.');
                                    }
                                    if (!reviewSnap.hasData) {
                                      return const Center(
                                        child: CircularProgressIndicator(color: Color(0xFFE8950A)),
                                      );
                                    }

                                    final reviews = reviewSnap.data!.docs;

                                    if (reviews.isEmpty) {
                                      return const Text(
                                        'No reviews yet. Be the first!',
                                        style: TextStyle(color: Color(0xFF9A9AA1), fontSize: 16),
                                      );
                                    }

                                    return Column(
                                      children: reviews.asMap().entries.map((entry) {
                                        final i = entry.key;
                                        final r = entry.value.data();

                                        final source = '';
                                        final rating = (r['rating'] ?? 0) as int;
                                        final text = (r['content'] ?? '').toString();
                                        final photoUrl = r['photo_url']?.toString();

                                        final ts = r['timestamp'];
                                        String date = '';
                                        if (ts is Timestamp) {
                                          final dt = ts.toDate();
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

                                            var perpost = r;
                                            String reviewerName = 'Anonymous';

                                            if (r['user_id'] == 'Anonymous') {
                                              reviewerName = 'Anonymous';
                                            } else if (userSnap.hasData && userSnap.data!.exists) {
                                              final userData = userSnap.data!.data();
                                              reviewerName = userData?['vvfullname']
                                                  ?? perpost['user_id']
                                                  ?? 'Anonymous';
                                            }

                                            final parts = reviewerName.trim().split(' ');
                                            final avatarText = parts.length >= 2
                                                ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
                                                : reviewerName
                                                .substring(0, reviewerName.length.clamp(0, 2))
                                                .toUpperCase();

                                            return Column(
                                              children: [
                                                _reviewCard(
                                                  avatarText: avatarText,
                                                  name: reviewerName,
                                                  source: source,
                                                  date: date,
                                                  rating: rating,
                                                  text: text,
                                                  photoUrl: photoUrl,
                                                ),
                                                if (i < reviews.length - 1) const SizedBox(height: 12),
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
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8950A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WriteReviewPage(
                              restaurantId: restaurantId,
                              restaurantName: name,
                            ),
                          ),
                        );
                      },
                      child: const Text('+ Write a review', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }


  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Color(0xFF3A3A3C)),
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3D79A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF76520A),
        ),
      ),
    );
  }

  Widget _reviewCard({
    required String avatarText,
    required String name,
    required String source,
    required String date,
    required int rating,
    required String text,
    String? photoUrl,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFECECF1),
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
                child: Text(avatarText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2C2C2E))),
                    if (source.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Text('· $source', style: const TextStyle(color: Color(0xFF4C84D8), fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),
              Text(date, style: const TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              5,
                  (index) => Icon(index < rating ? Icons.star : Icons.star_border, size: 16, color: const Color(0xFFE8950A)),
            ),
          ),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(fontSize: 16, color: Color(0xFF4A4A4F), fontWeight: FontWeight.w600)),
          if (photoUrl != null && photoUrl.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                photoUrl,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _photoPlaceholder(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(color: const Color(0xFFE8E2D6), borderRadius: BorderRadius.circular(10)),
      alignment: Alignment.center,
      child: const Text('📷 Food photo', style: TextStyle(color: Color(0xFF9A8F7A), fontWeight: FontWeight.w700)),
    );
  }
}