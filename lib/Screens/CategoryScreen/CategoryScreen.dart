import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:materialwalpper/Provider/AppProvider.dart';
import 'package:materialwalpper/Screens/CategoryScreen/CategoryDetailsScreen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool _isLoading = true;
  bool _isGridView = false; // Toggle between list and grid view
  List<dynamic> _categories = [];
  final String apiUrl = 'https://gaming.sunztech.com/api/v1/api.php';
  final Map<String, String> headers = {
    'Cache-Control': 'max-age=0',
    'Data-Agent': 'Material Wallpaper',
  };

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$apiUrl?get_categories'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            _categories = data['categories'];
          });
        }
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String getCategoryImageUrl(String imageName) {
    return 'https://gaming.sunztech.com/upload/category/$imageName';
  }

  void _navigateToCategoryDetails(String categoryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailsScreen(categoryId: categoryId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
        // actions: [
        //   IconButton(
        //     icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
        //     onPressed: () {
        //       setState(() {
        //         _isGridView = !_isGridView;
        //       });
        //     },
        //   ),
        // ],
      ),
      body: _isLoading
          ? appProvider.displayCategory == 'Grid'
              ? _buildGridShimmer()
              : _buildListShimmer()
          : _categories.isEmpty
              ? const Center(child: Text('No categories found'))
              : appProvider.displayCategory == 'Grid'
                  ? _buildGridView()
                  : _buildListView(),
    );
  }

  Widget _buildListView() {
    Size size = MediaQuery.of(context).size;
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final imageUrl = getCategoryImageUrl(category['category_image']);

        return GestureDetector(
          onTap: () => _navigateToCategoryDetails(category['category_id']),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Stack(
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: size.height * 0.07,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category['category_name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${category['total_wallpaper']} Wallpapers',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3 / 2,
      ),
      itemBuilder: (context, index) {
        final category = _categories[index];
        final imageUrl = getCategoryImageUrl(category['category_image']);

        return GestureDetector(
          onTap: () => _navigateToCategoryDetails(category['category_id']),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    // image: NetworkImage(imageUrl),
                    image: CachedNetworkImageProvider(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['category_name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${category['total_wallpaper']} Wallpapers',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListShimmer() {
    final appProvider = Provider.of<AppProvider>(context);
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Shimmer.fromColors(
            baseColor:
                appProvider.isDarkTheme ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor:
                appProvider.isDarkTheme ? Colors.grey[700]! : Colors.grey[200]!,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridShimmer() {
    final appProvider = Provider.of<AppProvider>(context);
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3 / 2,
      ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor:
              appProvider.isDarkTheme ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor:
              appProvider.isDarkTheme ? Colors.grey[700]! : Colors.grey[200]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      },
    );
  }
}
