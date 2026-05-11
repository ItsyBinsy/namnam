import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'search.dart';
import 'profile.dart';
import 'saved.dart';
import 'restaurant_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex =0;
  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Asian',
    'Italian',
    'Casual',
    'Japanese',
    'Chicken',
    'Drinks',
    'Grill',
  ];

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: _buildBody(context),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFFE8950A),
        unselectedItemColor: const Color(0xFFAEAEB2),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            activeIcon: Icon(Icons.bookmark_rounded),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (currentIndex ==0) return _buildHome(context);
    if (currentIndex == 1) return SearchPage();
    if (currentIndex ==2) return SavedPage();
    if (currentIndex ==3) return ProfilePage();
    return const Center(child: Text('Coming soon'));
  }

  Widget _buildHome(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16,50,16,12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width:32,
                    height:32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8950A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.rice_bowl_rounded,
                      color: Colors.white,
                      size:18,
                    ),
                  ),
                  const SizedBox(width:8),
                  const Text(
                    'NamNam',
                    style: TextStyle(
                      fontSize:20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D1D1F),
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF1D1D1F),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(
                height:36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedCategory == category;
                    return TextButton(
                      onPressed: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: isSelected ? const Color(0xFFE8950A)
                            : Colors.white,
                        foregroundColor: isSelected ? Colors.white : const Color(0xFF6E6E73),
                        padding: const EdgeInsets.symmetric(horizontal:16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(fontSize:13),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height:20),
              const Text(
                'Near you',
                style: TextStyle(
                  fontSize:20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D1D1F),
                ),
              ),
              const SizedBox(height:12),
              StreamBuilder<QuerySnapshot>(
                stream: selectedCategory == 'All'
                    ? FirebaseFirestore.instance.collection('tbl_restaurants').snapshots()
                    : FirebaseFirestore.instance .collection('tbl_restaurants')
                    .where('category', isEqualTo: selectedCategory)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE8950A),
                      ),
                    );
                  }

                  final restaurants = snapshot.data!.docs;

                  if (restaurants.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No restaurants found.',
                          style: TextStyle(color: Color(0xFF6E6E73)),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index];
                      final data = restaurant.data() as Map<String, dynamic>;

                      return Container(
                        margin: const EdgeInsets.only(bottom:12),
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
                                  restaurantId: restaurant.id,
                                ),
                              ),
                            );
                          },
                          leading: Container(
                            width:56,
                            height:56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8EC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.restaurant,
                              color: Color(0xFFE8950A),
                              size:28,
                            ),
                          ),
                          title: Text(
                            data['name'] ?? '',
                            style: const TextStyle(
                              fontSize:15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1D1D1F),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${data['category'] ?? ''} · ${data['address'] ?? ''}',
                                style: const TextStyle(
                                  fontSize:12,
                                  color: Color(0xFF6E6E73),
                                ),
                              ),
                              const SizedBox(height:4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_outline,
                                    color: Color(0xFFE8950A),
                                    size:14,
                                  ),
                                  const SizedBox(width:4),
                                  Text(
                                    '${data['rating'] ??0.0} · ${data['reviews_count'] ??0} reviews',
                                    style: const TextStyle(
                                      fontSize:12,
                                      color: Color(0xFF6E6E73),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Color(0xFFAEAEB2),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
