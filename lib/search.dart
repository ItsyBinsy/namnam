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
  var minRating = 0;
  final searchController = TextEditingController();

  final List<String> filterCategories = [
    'All',
    'Asian',
    'Casual',
    'Chicken',
    'Grill',
    'Italian',
    'Japanese',
    'Drinks',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

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

              // Search bar
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

              SizedBox(
                height: 34,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filterCategories.length,
                  itemBuilder: (context, index) {
                    var category = filterCategories[index];
                    var isSelected = selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            selectedCategory = selectedCategory == category ? '' : category;
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: isSelected ? const Color(0xFFE8950A) : const Color(0xFF6E6E73),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              category,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? const Color(0xFFE8950A) : const Color(0xFF6E6E73),
                              ),
                            ),
                            const SizedBox(height: 2),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 2,
                              width: isSelected ? 20 : 0,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8950A),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Text(
                    'Min rating: ',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6E6E73)),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      var star = index + 1;
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            minRating = minRating == star ? 0 : star;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          index < minRating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: const Color(0xFFE8950A),
                          size: 24,
                        ),
                      );
                    }),
                  ),
                  if (minRating > 0)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          minRating = 0;
                        });
                      },
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFAEAEB2),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

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

              var results = allRestaurants.where((doc) {
                var data = doc.data();
                var name = (data['name'] ?? '').toString().toLowerCase();
                var category = (data['category'] ?? '').toString();
                var rating = (data['rating'] ?? 0) as num;

                var matchesSearch = searchQuery.isEmpty || name.contains(searchQuery);
                var matchesCategory = selectedCategory.isEmpty || selectedCategory == 'All' || category == selectedCategory;
                var matchesRating = minRating == 0 || rating >= minRating;

                return matchesSearch && matchesCategory && matchesRating;
              }).toList();

              if (searchQuery.isEmpty && selectedCategory.isEmpty && minRating == 0) {
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
                        Icons.search_rounded,
                        color: Color(0xFFE8950A),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Hungry? Let\'s find it.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D1D1F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Search by name or browse\nby category.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6E6E73),
                      ),
                    ),
                  ],
                );
              }

              // No results
              if (results.isEmpty) {
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
                        Icons.restaurant_outlined,
                        color: Color(0xFFE8950A),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No restaurants found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D1D1F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Try a different name\nor category.',
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
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: results.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
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
                    );
                  }

                  var restaurant = results[index - 1];
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
              );
            },
          ),
        ),
      ],
    );
  }
}