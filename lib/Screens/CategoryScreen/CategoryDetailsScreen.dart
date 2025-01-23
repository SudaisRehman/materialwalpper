import 'dart:convert';
import 'package:ad_gridview/ad_gridview.dart';
import 'package:admob_easy/ads/services/admob_easy_native.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:materialwalpper/Provider/AppProvider.dart';
import 'package:materialwalpper/Screens/SearchScreen/SearchResultScreen.dart';
import 'package:materialwalpper/Screens/WallpaperScreen/WallpaperDetailsScreen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

const IAdIdManager adIdManager = TestAdIdManager();

class CategoryDetailsScreen extends StatefulWidget {
  final String categoryId;
  CategoryDetailsScreen({required this.categoryId});

  @override
  _CategoryDetailsScreenState createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  bool _isLoading = true;
  List<dynamic> _wallpapers = [];
  final String apiUrl = 'https://gaming.sunztech.com/api/v1/api.php';
  final Map<String, String> headers = {
    'Cache-Control': 'max-age=0',
    'Data-Agent': 'Material Wallpaper',
  };
  InterstitialAd? _interstitialAd;
  bool isInterstitialAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchCategoryDetails();
    _loadInterstitialAd();
    EasyAds.instance.initialize(
      adIdManager,
      adMobAdRequest: const AdRequest(),
      fbTestMode: true, // Optional, if you are using Facebook Ads in test mode
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

  Future<void> _fetchCategoryDetails({int sortOption = 0}) async {
    setState(() {
      _isLoading = true;
    });

    List<dynamic> wallpapers = [];
    int page = 1;
    bool hasMore = true;

    // Map the sort options to API parameters
    String orderBy;
    switch (sortOption) {
      case 1:
        orderBy = "ORDER BY g.featured DESC";
        break;
      case 2:
        orderBy = "ORDER BY g.view_count DESC";
        break;
      case 3:
        orderBy = "ORDER BY RAND()";
        break;
      case 4:
        orderBy = "ORDER BY g.live_wallpaper DESC";
        break;
      default:
        orderBy = "ORDER BY g.id DESC"; // Recent
    }

    try {
      while (hasMore) {
        final response = await http.get(
          Uri.parse(
              '$apiUrl?get_category_details&page=$page&count=20&id=${widget.categoryId}&filter=g.image_extension != \"all\"&order=$orderBy'),
          headers: headers,
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'ok') {
            wallpapers.addAll(data['posts']);

            // Check if more pages exist
            if (data['posts'].length < 20) {
              hasMore = false;
            } else {
              page++;
            }
          } else {
            hasMore = false;
          }
        } else {
          throw Exception('Failed to load category details');
        }
      }
    } catch (e) {
      print('Error fetching category details: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _wallpapers = wallpapers;
      });
    }
  }

  String getImageUrl(String imageUpload) {
    return 'https://gaming.sunztech.com/upload/$imageUpload';
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Category Details'),
          backgroundColor: Colors.green,
          actions: [
            // three lines type icon
            IconButton(
              icon: Icon(Icons.sort),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    int _selectedSortOption = 0; // Default sort option (Recent)

                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: Text(
                            'Sort Wallpapers',
                            style: TextStyle(
                              color: appProvider.isDarkTheme
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RadioListTile<int>(
                                value: 0,
                                activeColor: Colors.green,
                                groupValue: _selectedSortOption,
                                title: Text('Recent'),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSortOption = value!;
                                  });
                                },
                              ),
                              RadioListTile<int>(
                                value: 1,
                                activeColor: Colors.green,
                                groupValue: _selectedSortOption,
                                title: Text('Featured'),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSortOption = value!;
                                  });
                                },
                              ),
                              RadioListTile<int>(
                                value: 2,
                                groupValue: _selectedSortOption,
                                activeColor: Colors.green,
                                title: Text('Popular'),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSortOption = value!;
                                  });
                                },
                              ),
                              RadioListTile<int>(
                                value: 3,
                                groupValue: _selectedSortOption,
                                activeColor: Colors.green,
                                title: Text('Random'),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSortOption = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel',
                                  style: TextStyle(color: Colors.blue)),
                            ),
                            TextButton(
                              onPressed: () {
                                // Handle the selected sort option here
                                _fetchCategoryDetails(
                                    sortOption: _selectedSortOption);
                                print(
                                    'Selected Sort Option: $_selectedSortOption');
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'OK',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),

            //search icon
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // action
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SearchResultsScreen()));
              },
            ),
          ],
        ),
        body: Stack(children: [
          _isLoading
              ? GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: appProvider.displayWallpaperColumns,
                    // crossAxisSpacing: 10,
                    // mainAxisSpacing: 10,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: 22, // Number of shimmer items
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: appProvider.isDarkTheme
                          ? Colors.grey[800]!
                          : Colors.grey[300]!,
                      highlightColor: appProvider.isDarkTheme
                          ? Colors.grey[700]!
                          : Colors.grey[200]!,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                )
              : _wallpapers.isEmpty
                  ? Center(child: Text('No wallpapers found'))
                  : AdGridView(
                      padding: EdgeInsets.all(5),
                      // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      //   crossAxisCount: 3,
                      //   crossAxisSpacing: 10,
                      //   mainAxisSpacing: 10,
                      // ),
                      controller: ScrollController(),

                      crossAxisCount: appProvider.displayWallpaperColumns,
                      adGridViewType: AdGridViewType.custom,
                      itemCount:
                          _wallpapers.length, // Total number of wallpapers
                      adIndex: 3,
                      // itemMainAspectRatio: 1,
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
                      // itemCount: _wallpapers.length,
                      itemWidget: (context, index) {
                        final wallpaper = _wallpapers[index];
                        final imageUrl = getImageUrl(wallpaper['image_upload']);

                        return Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: GestureDetector(
                              onTap: () {
                                _handleTap();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            WallpaperDetailsScreen(
                                              wallpapers: _wallpapers,
                                              initialIndex: index,
                                            )));
                              },
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
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
                                errorWidget: (context, url, error) =>
                                    Center(child: Icon(Icons.broken_image)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: const EasySmartBannerAd(
              priorityAdNetworks: [
                AdNetwork.facebook,
                AdNetwork.admob,
                AdNetwork.unity,
                AdNetwork.appLovin,
              ],
              adSize: AdSize.banner,
            ),
          ),
        ]));
  }
}
