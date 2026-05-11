import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? '';
    final isGoogle = user?.providerData.any(
          (p) => p.providerId == 'google.com',
    ) ??
        false;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vvusers')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          // Resolve display name: Firestore > Auth displayName > email prefix > 'User'
          String displayName = 'User';
          int savedCount = 0;

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final firestoreName = data['vvfullname'] as String? ?? '';
            if (firestoreName.isNotEmpty) {
              displayName = firestoreName;
            } else {
              displayName =
                  FirebaseAuth.instance.currentUser?.displayName ?? 'User';
            }
            final saved = data['saved_restaurants'] as List<dynamic>? ?? [];
            savedCount = saved.length;
          } else {
            displayName =
                FirebaseAuth.instance.currentUser?.displayName ?? 'User';
          }

          final initials = _getInitials(displayName);

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                // Avatar + name + sign-in provider
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8950A),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // Edit icon badge
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFF5F5F7),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.settings,
                              size: 12,
                              color: Color(0xFF6E6E73),
                            ),
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
                        const SizedBox(height: 2),
                        if (isGoogle)
                          const Text(
                            'G · Signed in with Google',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4285F4),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        const SizedBox(height: 2),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Edit profile coming soon!'),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: const Color(0xFFE8950A),
                          ),
                          child: const Text(
                            'Edit profile',
                            style: TextStyle(
                              fontSize: 13,
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
                _buildStatsFromFirestore(uid, savedCount),

                const SizedBox(height: 24),

                // Menu rows
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      _buildMenuRow(
                        icon: Icons.star_rounded,
                        iconBg: const Color(0xFFE8950A),
                        label: 'My reviews',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('My reviews coming soon!'),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 56, color: Color(0xFFE5E5EA)),
                      _buildMenuRow(
                        icon: Icons.bookmark_rounded,
                        iconBg: const Color(0xFFE8950A),
                        label: 'Saved restaurants',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Saved restaurants coming soon!'),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 56, color: Color(0xFFE5E5EA)),
                      _buildMenuRow(
                        icon: Icons.settings_rounded,
                        iconBg: const Color(0xFF8E8E93),
                        label: 'Settings',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Settings coming soon!')),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 56, color: Color(0xFFE5E5EA)),
                      _buildMenuRow(
                        icon: Icons.logout_rounded,
                        iconBg: const Color(0xFFFF3B30),
                        label: 'Sign out',
                        labelColor: const Color(0xFFFF3B30),
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                                (route) => false,
                          );
                        },
                        showChevron: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsFromFirestore(String uid, int savedCount) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('user_id', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        int reviewCount = 0;
        double avgRating = 0.0;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final docs = snapshot.data!.docs;
          reviewCount = docs.length;
          final total = docs.fold<double>(
            0,
                (sum, doc) {
              final data = doc.data() as Map<String, dynamic>;
              return sum + ((data['rating'] as num?)?.toDouble() ?? 0);
            },
          );
          avgRating = total / reviewCount;
        }

        return Row(
          children: [
            _buildStatBox(
              value: reviewCount.toString(),
              label: 'Reviews',
            ),
            const SizedBox(width: 12),
            _buildStatBox(
              value: savedCount.toString(),
              label: 'Saved',
            ),
            const SizedBox(width: 12),
            _buildStatBox(
              value: reviewCount > 0 ? avgRating.toStringAsFixed(1) : '—',
              label: 'Avg',
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatBox({required String value, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE8950A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6E6E73),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuRow({
    required IconData icon,
    required Color iconBg,
    required String label,
    required VoidCallback onTap,
    Color labelColor = const Color(0xFF1D1D1F),
    bool showChevron = true,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: labelColor,
        ),
      ),
      trailing: showChevron
          ? const Icon(
        Icons.chevron_right,
        color: Color(0xFFAEAEB2),
        size: 20,
      )
          : null,
    );
  }
}