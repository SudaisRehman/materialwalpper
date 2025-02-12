import 'dart:convert';
import 'package:ad_gridview/ad_gridview.dart';
import 'package:admob_easy/ads/admob_easy.dart';
import 'package:admob_easy/ads/services/admob_easy_native.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:materialwalpper/Screens/CategoryScreen/CategoryDetailsScreen.dart';
import 'package:provider/provider.dart';
import 'package:materialwalpper/Provider/AppProvider.dart';
import 'package:materialwalpper/Screens/WallpaperScreen/WallpaperDetailsScreen.dart';
import 'package:shimmer/shimmer.dart';

const IAdIdManager adIdManager = TestAdIdManager();

class SearchResultsScreen extends StatefulWidget {
  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  InterstitialAd? _interstitialAd;
  bool isInterstitialAdLoaded = false;

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
    _loadInterstitialAd();
    // Fetch the wallpapers when the screen is initialized
    AdmobEasy.instance.initialize(
      androidNativeAdID: 'ca-app-pub-3940256099942544/2247696110',
      // testDevices: ['543E082C0B43E6BF17AF6D4F72541F51']
    );
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          setState(() {
            _interstitialAd = ad;
            isInterstitialAdLoaded = true;
          });
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              _loadInterstitialAd(); // Load a new interstitial ad
            },
            onAdFailedToShowFullScreenContent: (Ad ad, AdError error) {
              ad.dispose(); // Dispose if it fails to show
              _loadInterstitialAd(); // Load a new interstitial ad
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Failed to load interstitial ad: $error');
          isInterstitialAdLoaded = false;
          // Retry loading the ad after a delay or log the error
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      // Ensure the ad is not null
      _interstitialAd!.show();
      setState(() {
        _interstitialAd = null; // Dispose of the ad after showing
        isInterstitialAdLoaded = false;
      });
      _loadInterstitialAd(); // Load a new interstitial ad
    } else {
      print('Tapp Interstitial ad not loaded yet.');
    }
  }

  void _handleTap() {
    // tapCount++;
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.incrementTapCount();
    //  action();
    if (appProvider.tapCount % 2 == 0) {
      _showInterstitialAd();
      // adManager?.showInterstitialAd();
      print('Tapped ${appProvider.tapCount} even times');
      print('Showing Interstitial Ad');
    }
    print('Tapped ${appProvider.tapCount} times');
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
                    ? _isCategorySelected
                        ? appProvider.displayCategory == 'Grid'
                            ? _buildGridShimmer()
                            : _buildListShimmer()
                        : GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  appProvider.displayWallpaperColumns,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.67,
                            ),
                            itemCount: 12,
                            itemBuilder: (context, index) {
                              return Shimmer.fromColors(
                                baseColor: appProvider.isDarkTheme
                                    ? Colors.grey[800]!
                                    : Colors.grey[300]!,
                                highlightColor: appProvider.isDarkTheme
                                    ? Colors.grey[700]!
                                    : Colors.grey[200]!,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: size.height * 0.8,
                                    width: size.width * 0.5,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            })
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
        : AdGridView(
            controller: ScrollController(),
            crossAxisCount: appProvider.displayWallpaperColumns,
            adGridViewType: AdGridViewType.custom,
            itemCount: _wallpapers.length, // Total number of wallpapers
            adIndex: 3,
            itemMainAspectRatio: 1.5,
            customAdIndex: [3, 15, 30, 45, 60, 75, 90, 105],
            adWidget: Column(
              children: [
                AdmobEasyNative.mediumTemplate(
                  minWidth: 320,
                  minHeight: 320,
                  maxWidth: 360,
                  maxHeight: 360,
                  onAdOpened: (ad) => print("Ad Opened"),
                  onAdClosed: (ad) => print("Ad Closed"),
                  onPaidEvent: (ad, value, precision, currencyCode) {
                    print(
                        "Paid event: $value $currencyCode with precision: $precision");
                  },
                ),
                // SizedBox(height: 10),
              ],
            ),
       
            itemWidget: (context, index) {
              final wallpaper = _wallpapers[index];
              final imageUrl = getImageUrl(wallpaper['image_upload']);

              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Container(
                        height: size.height * 0.8,
                        width: size.width * 0.5,
                        child: GestureDetector(
                          onTap: () {
                            _handleTap();
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
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: imageUrl,
                            placeholder: (context, url) => Center(
                              child: Shimmer.fromColors(
                                baseColor: appProvider.isDarkTheme
                                    ? Colors.grey[800]!
                                    : Colors.grey[300]!,
                                highlightColor: appProvider.isDarkTheme
                                    ? Colors.grey[700]!
                                    : Colors.grey[200]!,
                                child: Container(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            errorWidget: (context, error, stackTrace) => Center(
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
            _handleTap();
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
            _handleTap();
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
