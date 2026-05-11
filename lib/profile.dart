import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    var uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('vvusers')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {

          String displayName = 'User';
          int savedCount = 0;

          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            var firestoreName = data['vvfullname'] as String? ?? '';
            if (firestoreName.isNotEmpty) {
              displayName = firestoreName;
            } else {
              displayName = FirebaseAuth.instance.currentUser?.displayName ?? 'User';
            }
            var saved = data['saved_restaurants'] as List<dynamic>? ?? [];
            savedCount = saved.length;
          } else {
            displayName = FirebaseAuth.instance.currentUser?.displayName ?? 'User';
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            shrinkWrap: true,
            children: [

              const SizedBox(height: 40),

              Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8950A),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFF5F5F7), width: 2),
                          ),
                          child: const Icon(Icons.settings, size: 12, color: Color(0xFF6E6E73)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
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
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Edit profile coming soon!')),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Edit profile',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE8950A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Stats row
              StreamBuilder(
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
                        var data = doc.data();
                        total = total + ((data['rating'] ?? 0) as num).toDouble();
                      }
                      avgRating = total / reviewCount;
                    }
                  }

                  return Row(
                    children: [

                      // Reviews
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
                              const Text(
                                'Reviews',
                                style: TextStyle(fontSize: 12, color: Color(0xFF6E6E73)),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Saved
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

                      // Avg
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
                                'Avg',
                                style: TextStyle(fontSize: 12, color: Color(0xFF6E6E73)),
                              ),
                            ],
                          ),
                        ),
                      ),

                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Menu rows
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [

                    ListTile(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('My reviews coming soon!')),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Saved restaurants coming soon!')),
                        );
                      },
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8950A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.bookmark_rounded, color: Colors.white, size: 20),
                      ),
                      title: const Text(
                        'Saved restaurants',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Color(0xFFAEAEB2)),
                    ),

                    const Divider(height: 1, indent: 56, color: Color(0xFFE5E5EA)),

                    ListTile(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Settings coming soon!')),
                        );
                      },
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8E8E93),
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

              const SizedBox(height: 40),

            ],
          );
        },
      ),
    );
  }
}