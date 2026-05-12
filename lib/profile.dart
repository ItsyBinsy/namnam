import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'my_reviews.dart';
import 'edit_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    var uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    var email = FirebaseAuth.instance.currentUser?.email ?? '';

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {

        String displayName = 'User';
        String memberSince = '';

        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          var firestoreName = data['fullname'] as String? ?? '';
          if (firestoreName.isNotEmpty) {
            displayName = firestoreName;
          } else {
            displayName = FirebaseAuth.instance.currentUser?.displayName ?? 'User';
          }

          var createdAt = data['created_at'];
          if (createdAt is Timestamp) {
            var dt = createdAt.toDate();
            const months = ['Jan','Feb','Mar','Apr','May','Jun',
              'Jul','Aug','Sep','Oct','Nov','Dec'];
            memberSince = 'Member since ${months[dt.month - 1]} ${dt.year}';
          }
        } else {
          displayName = FirebaseAuth.instance.currentUser?.displayName ?? 'User';
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 40),
          shrinkWrap: true,
          children: [

            // avatar and info
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8950A),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D1D1F),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6E6E73),
                        ),
                      ),
                      if (memberSince.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          memberSince,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFAEAEB2),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // stats row
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('saved')
                  .doc(uid)
                  .snapshots(),
              builder: (context, savedSnap) {
                var savedCount = 0;
                if (savedSnap.hasData && savedSnap.data!.exists) {
                  var data = savedSnap.data!.data() as Map<String, dynamic>?;
                  savedCount = (data?['saved_restaurants'] as List<dynamic>?)?.length ?? 0;
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('reviews')
                      .where('user_id', isEqualTo: uid)
                      .snapshots(),
                  builder: (context, reviewSnap) {
                    var reviewCount = 0;
                    var avgRating = 0.0;

                    if (reviewSnap.hasData) {
                      var docs = reviewSnap.data!.docs;
                      reviewCount = docs.length;

                      if (reviewCount > 0) {
                        var total = 0.0;
                        for (var doc in docs) {
                          var data = doc.data() as Map<String, dynamic>;
                          total += ((data['rating'] ?? 0) as num).toDouble();
                        }
                        avgRating = total / reviewCount;
                      }
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  reviewCount.toString(),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE8950A),
                                  ),
                                ),
                                Text(
                                  reviewCount == 1 ? 'Review' : 'Reviews',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF6E6E73)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  savedCount.toString(),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE8950A),
                                  ),
                                ),
                                const Text(
                                  'Saved',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF6E6E73)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  reviewCount > 0 ? avgRating.toStringAsFixed(1) : '—',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE8950A),
                                  ),
                                ),
                                const Text(
                                  'Avg Rating',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF6E6E73)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            // rows
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [

                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyReviewsPage(uid: uid),
                        ),
                      );
                    },
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8950A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.star_rounded, color: Colors.white, size: 20),
                    ),
                    title: const Text(
                      'My reviews',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFFAEAEB2)),
                  ),

                  const Divider(height: 1, indent: 56, color: Color(0xFFE5E5EA)),

                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(
                            uid: uid,
                            currentName: displayName,
                          ),
                        ),
                      );
                    },
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                    ),
                    title: const Text(
                      'Edit profile',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFFAEAEB2)),
                  ),

                  const Divider(height: 1, indent: 56, color: Color(0xFFE5E5EA)),

                  ListTile(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings is coming soon!')),
                      );
                    },
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF636366),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.settings_rounded, color: Colors.white, size: 20),
                    ),
                    title: const Text(
                      'Settings',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFFAEAEB2)),
                  ),

                  const Divider(height: 1, indent: 56, color: Color(0xFFE5E5EA)),

                  ListTile(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                            (route) => false,
                      );
                    },
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                    ),
                    title: const Text(
                      'Sign out',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFF3B30),
                      ),
                    ),
                  ),

                ],
              ),
            ),

          ],
        );
      },
    );
  }
}