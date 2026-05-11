import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'restaurant_detail.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var searchQuery = '';
  var selectedCategory = '';
  final searchController = TextEditingController();

  final List<String> filterCategories = [
    'Asian',
    'Japanese',
    'Italian',
    'Casual',
    'Chicken',
    'Grill',
    'Drinks',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
                const SizedBox(height: 12),

                // Search bar with gold border when active
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: searchQuery.isNotEmpty
                          ? const Color(0xFFE8950A)
                          : const Color(0xFFE5E5EA),
                      width: searchQuery.isNotEmpty ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.search, color: Color(0xFFE8950A), size: 20),
                      ),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value.trim().toLowerCase();
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search restaurants...',
                            hintStyle: TextStyle(color: Color(0xFFAEAEB2)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      if (searchQuery.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              searchQuery = '';
                            });
                          },
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Icon(Icons.close, color: Color(0xFFAEAEB2), size: 18),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Filter pills
                Row(
                  children: [
                    const Text(
                      'Filter: ',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6E6E73)),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 34,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: filterCategories.length,
                          itemBuilder: (context, index) {
                            var category = filterCategories[index];
                            var isSelected = selectedCategory == category;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    if (selectedCategory == category) {
                                      selectedCategory = '';
                                    } else {
                                      selectedCategory = category;
                                    }
                                  });
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: isSelected
                                      ? const Color(0xFFFFF8EC)
                                      : Colors.white,
                                  foregroundColor: isSelected
                                      ? const Color(0xFFE8950A)
                                      : const Color(0xFF6E6E73),
                                  side: BorderSide(
                                    color: isSelected
                                        ? const Color(0xFFE8950A)
                                        : const Color(0xFFE5E5EA),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  category,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('tbl_restaurants')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE8950A)),
                  );
                }

                var allRestaurants = snapshot.data!.docs;

                // Filter by search query and selected category
                var results = allRestaurants.where((doc) {
                  var data = doc.data();
                  var name = (data['name'] ?? '').toString().toLowerCase();
                  var category = (data['category'] ?? '').toString();

                  var matchesSearch = searchQuery.isEmpty || name.contains(searchQuery);
                  var matchesCategory = selectedCategory.isEmpty || category == selectedCategory;

                  return matchesSearch && matchesCategory;
                }).toList();

                // Show empty state if nothing typed yet
                if (searchQuery.isEmpty && selectedCategory.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 48, color: Color(0xFFAEAEB2)),
                        SizedBox(height: 12),
                        Text(
                          'Search for a restaurant',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6E6E73),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (results.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant, size: 48, color: Color(0xFFAEAEB2)),
                        SizedBox(height: 12),
                        Text(
                          'No restaurants found.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6E6E73),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  children: [

                    // Results count
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${results.length} results',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D1D1F),
                              ),
                            ),
                            if (searchQuery.isNotEmpty)
                              TextSpan(
                                text: ' for "$searchQuery"',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6E6E73),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Restaurant list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        var restaurant = results[index];
                        var data = restaurant.data();

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
                                    restaurantId: restaurant.id,
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
                              data['name'] ?? '',
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
                                  '${data['category'] ?? ''} · ${data['address'] ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6E6E73),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_outline,
                                      color: Color(0xFFE8950A),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${data['rating'] ?? 0.0} · ${data['reviews_count'] ?? 0} reviews',
                                      style: const TextStyle(
                                        fontSize: 12,
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
                    ),

                  ],
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}