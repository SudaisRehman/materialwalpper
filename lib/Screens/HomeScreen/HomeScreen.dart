import 'dart:convert';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:materialwalpper/Provider/AppProvider.dart';
import 'package:materialwalpper/Screens/CategoryScreen/CategoryScreen.dart';
import 'package:materialwalpper/Screens/FavoriteScreen/FavoriteScreen.dart';
import 'package:materialwalpper/Screens/SearchScreen/SearchResultScreen.dart';
import 'package:materialwalpper/Screens/SettingScreen/SettingScreen.dart';
import 'package:materialwalpper/Screens/WallpaperScreen/WallpaperScreen.dart';
// import 'package:materialwalpper/wallpaper_services.dart';
import 'package:provider/provider.dart';

const IAdIdManager adIdManager = TestAdIdManager();

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Track the selected index for BottomNavigationBar
  int _selectedTabIndex = 0;
  List<dynamic> _wallpapers = [];
  bool _isLoading = false;
  String totalCount = '';
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  final String apiUrl = 'https://gaming.sunztech.com/api/v1/api.php';
  final Map<String, String> headers = {
    'Cache-Control': 'max-age=0',
    'Data-Agent': 'Material Wallpaper',
  };

  // Constants for filters and orders
  static const String FILTER_ALL = "g.image_extension != 'all'";
  static const String FILTER_WALLPAPER = "g.image_extension != 'image/gif'";
  static const String FILTER_LIVE = "g.image_extension = 'image/gif'";
  static const String ORDER_RECENT = "ORDER BY g.id DESC";
  static const String ORDER_FEATURED =
      "AND g.featured = 'yes' ORDER BY g.last_update DESC";
  static const String ORDER_POPULAR = "ORDER BY g.view_count DESC";
  static const String ORDER_RANDOM = "ORDER BY RAND()";
  static const String ORDER_LIVE = "ORDER BY g.id DESC";

  @override
  void initState() {
    super.initState();

    // Initialize the Easy Ads plugin
    EasyAds.instance.initialize(
      adIdManager,
      adMobAdRequest: const AdRequest(),
      fbTestMode: true, // Optional, if you are using Facebook Ads in test mode
    );
  }

  Future<void> fetchWallpapers([String query = '']) async {
    setState(() {
      _isLoading = true;
    });

    String orderFilter = ORDER_RECENT;
    String imageFilter = FILTER_WALLPAPER;

    try {
      int page = 1;
      bool hasMore = true;
      List<dynamic> fetchedWallpapers = [];

      while (hasMore) {
        // Modify API URL to include search query if provided
        final response = await http.get(
          Uri.parse(
              '$apiUrl?get_wallpapers&page=$page&count=20&filter=$imageFilter&order=$orderFilter&search=$query'),
          headers: headers,
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['status'] == 'ok') {
            fetchedWallpapers.addAll(data['posts']);
            totalCount = data['count_total'];

            if (fetchedWallpapers.length >= int.parse(totalCount)) {
              hasMore = false;
            } else {
              page++;
            }
          } else {
            hasMore = false;
          }
        } else {
          throw Exception('Failed to load wallpapers');
        }
      }

      setState(() {
        _wallpapers = fetchedWallpapers;
      });
    } catch (e) {
      print('Error fetching wallpapers: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearch() {
    setState(() {
      _searchQuery = _searchController.text;
    });

    // if (_searchQuery.isNotEmpty) {
    // Navigate to the SearchResultsScreen and pass the search query
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(
            // searchQuery: _searchQuery
            ),
      ),
    );
    // }
  }

  String getImageUrl(String imageUpload) {
    return 'https://gaming.sunztech.com/upload/$imageUpload';
  }

  // Widgets for each tab
  static List<Widget> _pages = <Widget>[
    WallpaperScreen(),
    CategoryScreen(),
    FavoritesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appProvider.isDarkTheme
            ? Colors.green[00]
            : Colors.green[100], // Dark mode background for AppBar
        title: GestureDetector(
          onTap: () {
            _onSearch();
          },
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: appProvider.isDarkTheme
                  ? Colors.grey[800]
                  : Colors.white, // Dark mode for text field background
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                TextField(
                  controller:
                      _searchController, // Use the controller for search input
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      color: appProvider.isDarkTheme
                          ? Colors.white70
                          : Colors.black, // Hint text color
                    ),
                    prefixIcon: GestureDetector(
                        onTap: () {
                          _onSearch();
                        },
                        child: Icon(Icons.arrow_back,
                            color: appProvider.isDarkTheme
                                ? Colors.white
                                : Colors.black)),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search,
                          color: appProvider.isDarkTheme
                              ? Colors.white
                              : Colors.black),
                      onPressed:
                          _onSearch, // Call search function when button is pressed
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: TextStyle(
                    color: appProvider.isDarkTheme
                        ? Colors.white
                        : Colors.black, // Text color inside TextField
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _onSearch();
                  },
                  child: Container(
                    height: 50,
                    color: Colors.transparent,
                    width: double.infinity,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.image,
                color: appProvider.isDarkTheme ? Colors.white : Colors.green),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(),
                ),
              );
              // Add functionality for an image button if needed
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _pages[_selectedIndex]),
          const EasySmartBannerAd(
            priorityAdNetworks: [
              AdNetwork.facebook,
              AdNetwork.admob,
              AdNetwork.unity,
              AdNetwork.appLovin,
            ],
            adSize: AdSize.banner,
          ),
        ],
      ), // Display the selected tab

      bottomNavigationBar: BottomNavigationBar(
        unselectedLabelStyle: TextStyle(color: Colors.black, fontSize: 14),
        selectedLabelStyle: TextStyle(color: Colors.green, fontSize: 14),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Wallpaper',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Category',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'Favorite',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}

// // Placeholder for the Wallpaper screen
// class WallpaperScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Wallpaper Screen',
//         style: TextStyle(fontSize: 24),
//       ),
//     );
//   }
// }

// // Placeholder for the Category screen
// class CategoryScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Category Screen',
//         style: TextStyle(fontSize: 24),
//       ),
//     );
//   }
// }

// // Placeholder for the Favorite screen
// class FavoriteScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Favorite Screen',
//         style: TextStyle(fontSize: 24),
//       ),
//     );
//   }
// }
