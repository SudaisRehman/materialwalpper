import 'dart:convert';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:materialwalpper/Screens/CategoryScreen/CategoryDetailsScreen.dart';
import 'package:provider/provider.dart';
import 'package:materialwalpper/Provider/AppProvider.dart';
import 'package:materialwalpper/Screens/WallpaperScreen/WallpaperDetailsScreen.dart';

const IAdIdManager adIdManager = TestAdIdManager();

class SearchResultsScreen extends StatefulWidget {
  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  List<dynamic> _wallpapers = [];
  List<dynamic> _categories = [];
  bool _isLoading = false;
  bool _isCategorySelected = false; // Toggle for Wallpaper or Category
  TextEditingController _searchController = TextEditingController();

  final String apiUrl = 'https://gaming.sunztech.com/api/v1/api.php';
  final Map<String, String> headers = {
    'Cache-Control': 'max-age=0',
    'Data-Agent': 'Material Wallpaper',
  };

  @override
  void initState() {
    super.initState();

    EasyAds.instance.initialize(
      adIdManager,
      adMobAdRequest: const AdRequest(),
      fbTestMode: true, // Optional, if you are using Facebook Ads in test mode
    );
  }

  Future<void> fetchWallpapers(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$apiUrl?get_search&count=120&search=$query'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            _wallpapers = data['posts'] ?? [];
          });
        } else {
          setState(() {
            _wallpapers = [];
          });
        }
      } else {
        throw Exception('Failed to load wallpapers');
      }
    } catch (e) {
      print('Error fetching wallpapers: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchCategories(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$apiUrl?get_search_category&search=$query'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            _categories = data['categories'] ?? [];
          });
        } else {
          setState(() {
            _categories = [];
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

  String getImageUrl(String? imageUpload) {
    if (imageUpload == null || imageUpload.isEmpty) {
      return 'https://via.placeholder.com/150'; // Placeholder image
    }
    return 'https://gaming.sunztech.com/upload/$imageUpload';
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
    Size size = MediaQuery.of(context).size;
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(
              color: appProvider.isDarkTheme
                  ? Colors.white70
                  : Colors.black, // Hint text color
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.search,
                color: appProvider.isDarkTheme ? Colors.white : Colors.black,
              ),
              onPressed: () {
                if (_isCategorySelected) {
                  fetchCategories(_searchController.text);
                } else {
                  fetchWallpapers(_searchController.text);
                }
              },
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
          ),
          style: TextStyle(
            color: appProvider.isDarkTheme
                ? Colors.white
                : Colors.black, // Text color
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<bool>(
                    value: false,
                    groupValue: _isCategorySelected,
                    onChanged: (value) {
                      setState(() {
                        _isCategorySelected = value!;
                      });
                      fetchWallpapers(_searchController.text);
                    },
                  ),
                  Text('Wallpaper'),
                  Radio<bool>(
                    value: true,
                    groupValue: _isCategorySelected,
                    onChanged: (value) {
                      setState(() {
                        _isCategorySelected = value!;
                      });
                      fetchCategories(_searchController.text);
                    },
                  ),
                  Text('Category'),
                ],
              ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _isCategorySelected
                        ? appProvider.displayCategory == 'Grid'
                            ? _buildCategoryGrid(size)
                            : _buildListView()
                        // _buildCategoryGrid(size)
                        : _buildWallpaperGrid(size),
              ),
            ],
          ),
          const Positioned(
            bottom: 2,
            left: 0,
            right: 0,
            child: EasySmartBannerAd(
              priorityAdNetworks: [
                AdNetwork.facebook,
                AdNetwork.admob,
                AdNetwork.unity,
                AdNetwork.appLovin,
              ],
              adSize: AdSize.banner,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWallpaperGrid(Size size) {
    final appProvider = Provider.of<AppProvider>(context);
    return _wallpapers.isEmpty
        ? Center(child: Text('No wallpapers found'))
        : GridView.builder(
            controller: ScrollController(),
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: appProvider.displayWallpaperColumns,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 0.6,
            ),
            itemCount: _wallpapers.length,
            itemBuilder: (context, index) {
              final wallpaper = _wallpapers[index];
              final imageUrl = getImageUrl(wallpaper['image_upload']);

              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Container(
                      height: size.height * 0.8,
                      width: size.width * 0.5,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WallpaperDetailsScreen(
                                wallpapers: _wallpapers,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: Image.network(
                          fit: BoxFit.cover,
                          imageUrl,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: Colors.green,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }

  Widget _buildCategoryGrid(Size size) {
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
          onTap: () {
            _navigateToCategoryDetails(category['category_id']);
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
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
                      category['category_name'] ?? 'Unknown Category',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${category['total_wallpaper'] ?? 0} Wallpapers',
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

  Widget _buildListView() {
    Size size = MediaQuery.of(context).size;
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final imageUrl = getCategoryImageUrl(category['category_image']);

        return GestureDetector(
          onTap: () {
            _navigateToCategoryDetails(category['category_id']);
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Stack(
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
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
                            category['category_name'] ?? 'Unknown Category',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${category['total_wallpaper'] ?? 0} Wallpapers',
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
}
