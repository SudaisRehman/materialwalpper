// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:materialwalpper/Provider/AppProvider.dart';
// import 'package:materialwalpper/Screens/WallpaperDetailsScreen.dart';
// import 'package:provider/provider.dart';

// class WallpaperScreen extends StatefulWidget {
//   @override
//   _WallpaperScreenState createState() => _WallpaperScreenState();
// }

// class _WallpaperScreenState extends State<WallpaperScreen> {
//   int _selectedTabIndex = 0;
//   List<dynamic> _wallpapers = [];
//   bool _isLoading = false;
//   String totalCount = '';
//   String _searchQuery = '';

//   final String apiUrl = 'https://gaming.sunztech.com/api/v1/api.php';
//   final Map<String, String> headers = {
//     'Cache-Control': 'max-age=0',
//     'Data-Agent': 'Material Wallpaper',
//   };

//   // Constants for filters and orders
//   static const String FILTER_ALL = "g.image_extension != 'all'";
//   static const String FILTER_WALLPAPER = "g.image_extension != 'image/gif'";
//   static const String FILTER_LIVE = "g.image_extension = 'image/gif'";
//   static const String ORDER_RECENT = "ORDER BY g.id DESC";
//   static const String ORDER_FEATURED =
//       "AND g.featured = 'yes' ORDER BY g.last_update DESC";
//   static const String ORDER_POPULAR = "ORDER BY g.view_count DESC";
//   static const String ORDER_RANDOM = "ORDER BY RAND()";
//   static const String ORDER_LIVE = "ORDER BY g.id DESC";

//   @override
//   void initState() {
//     super.initState();
//     fetchWallpapers(); // Fetch the wallpapers when the screen is initialized
//   }

//   Future<void> fetchWallpapers(
//       [String category = 'recent', String query = '']) async {
//     setState(() {
//       _isLoading = true;
//     });

//     String orderFilter = ORDER_RECENT;
//     String imageFilter = FILTER_WALLPAPER;

//     // Adjust API parameters based on category selection
//     switch (category) {
//       case 'recent':
//         orderFilter = ORDER_RECENT;
//         imageFilter = FILTER_WALLPAPER;
//         break;
//       case 'featured':
//         orderFilter = ORDER_FEATURED;
//         imageFilter = FILTER_WALLPAPER;
//         break;
//       case 'popular':
//         orderFilter = ORDER_POPULAR;
//         imageFilter = FILTER_WALLPAPER;
//         break;
//       case 'random':
//         orderFilter = ORDER_RANDOM;
//         imageFilter = FILTER_WALLPAPER;
//         break;
//       case 'live_wallpaper':
//         orderFilter = ORDER_LIVE;
//         imageFilter = FILTER_LIVE;
//         break;
//       default:
//         orderFilter = ORDER_RECENT;
//         imageFilter = FILTER_WALLPAPER;
//     }

//     try {
//       int page = 1;
//       bool hasMore = true;
//       List<dynamic> fetchedWallpapers = [];

//       while (hasMore) {
//         // Modify API URL to include search query if provided
//         final response = await http.get(
//           Uri.parse(
//               '$apiUrl?get_wallpapers&page=$page&count=20&filter=$imageFilter&order=$orderFilter&search=$query'),
//           headers: headers,
//         );

//         if (response.statusCode == 200) {
//           final data = json.decode(response.body);

//           if (data['status'] == 'ok') {
//             fetchedWallpapers.addAll(data['posts']);
//             totalCount = data['count_total'];

//             if (fetchedWallpapers.length >= int.parse(totalCount)) {
//               hasMore = false;
//             } else {
//               page++;
//             }
//           } else {
//             hasMore = false;
//           }
//         } else {
//           throw Exception('Failed to load wallpapers');
//         }
//       }

//       setState(() {
//         _wallpapers = fetchedWallpapers;
//       });
//     } catch (e) {
//       print('Error fetching wallpapers: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _onTabSelected(int index) {
//     setState(() {
//       _selectedTabIndex = index;
//     });

//     // Fetch wallpapers based on the selected tab
//     switch (index) {
//       case 0:
//         fetchWallpapers('recent');
//         break;
//       case 1:
//         fetchWallpapers('featured');
//         break;
//       case 2:
//         fetchWallpapers('popular');
//         break;
//       case 3:
//         fetchWallpapers('random');
//         break;
//       case 4:
//         fetchWallpapers('live_wallpaper');
//         break;
//     }
//   }

//   String getImageUrl(String imageUpload) {
//     return 'https://gaming.sunztech.com/upload/$imageUpload';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final appProvider = Provider.of<AppProvider>(context);
//     Size size = MediaQuery.of(context).size;
//     return Scaffold(
//       body: Column(
//         children: [
//           // Search bar

//           // Tab bar
//           Container(
//             color: appProvider.isDarkTheme ? Colors.black : Colors.grey[200],
//             padding: const EdgeInsets.symmetric(vertical: 10),
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _buildTab('Recent', 0),
//                   _buildTab('Featured', 1),
//                   _buildTab('Popular', 2),
//                   _buildTab('Random', 3),
//                   _buildTab('Live Wallpaper', 4),
//                 ],
//               ),
//             ),
//           ),

//           // Grid of wallpapers
//           Expanded(
//             child: _isLoading
//                 ? Center(
//                     child: CircularProgressIndicator(
//                     color: Colors.green,
//                   ))
//                 : _wallpapers.isEmpty
//                     ? Center(child: Text('No wallpapers found'))
//                     : GridView.builder(
//                         controller: ScrollController(),
//                         padding: EdgeInsets.all(10),
//                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: appProvider.displayWallpaperColumns,
//                           crossAxisSpacing: 6,
//                           mainAxisSpacing: 6,
//                           childAspectRatio: 0.6,
//                         ),
//                         itemCount: _wallpapers.length,
//                         itemBuilder: (context, index) {
//                           final wallpaper = _wallpapers[index];
//                           final imageUrl =
//                               getImageUrl(wallpaper['image_upload']);

//                           return ClipRRect(
//                             borderRadius: BorderRadius.circular(10),
//                             child: Stack(
//                               children: [
//                                 Container(
//                                   height: size.height * 0.8,
//                                   width: size.width * 0.5,
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                               builder: (context) =>
//                                                   WallpaperDetailsScreen(
//                                                     wallpapers: _wallpapers,
//                                                     initialIndex: index,
//                                                   )));
//                                     },
//                                     child: Image.network(
//                                       fit: BoxFit.cover,
//                                       imageUrl,
//                                       loadingBuilder:
//                                           (context, child, loadingProgress) {
//                                         if (loadingProgress == null)
//                                           return child;
//                                         return Center(
//                                           child: CircularProgressIndicator(
//                                             color: Colors.green,
//                                             value: loadingProgress
//                                                         .expectedTotalBytes !=
//                                                     null
//                                                 ? loadingProgress
//                                                         .cumulativeBytesLoaded /
//                                                     loadingProgress
//                                                         .expectedTotalBytes!
//                                                 : null,
//                                           ),
//                                         );
//                                       },
//                                       errorBuilder:
//                                           (context, error, stackTrace) =>
//                                               Center(
//                                         child: Icon(
//                                           Icons.broken_image,
//                                           color: Colors.grey,
//                                           size: 50,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTab(String title, int index) {
//     final appProvider = Provider.of<AppProvider>(context);
//     bool isSelected = _selectedTabIndex == index;
//     return GestureDetector(
//       onTap: () => _onTabSelected(index),
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 200),
//         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.green : Colors.transparent,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Text(
//           title,
//           style: TextStyle(
//             color: isSelected
//                 ? Colors.white
//                 : appProvider.isDarkTheme
//                     ? Colors.white70
//                     : Colors.black54,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:ad_gridview/ad_gridview.dart';
import 'package:admob_easy/ads/admob_easy.dart';
import 'package:admob_easy/ads/services/admob_easy_native.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:materialwalpper/Provider/AppProvider.dart';
import 'package:materialwalpper/Screens/WallpaperScreen/WallpaperDetailsScreen.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';

class WallpaperScreen extends StatefulWidget {
  @override
  _WallpaperScreenState createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen> {
  InterstitialAd? _interstitialAd;
  bool isInterstitialAdLoaded = false;

  int _selectedTabIndex = 0;
  List<dynamic> _wallpapers = [];
  bool _isLoading = false;
  String totalCount = '';
  String _searchQuery = '';
  Map<String, List<dynamic>> _wallpaperCache = {}; // Cache for wallpapers

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
    _loadInterstitialAd();
    fetchWallpapers(
        'recent'); // Fetch the wallpapers when the screen is initialized
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

  Future<void> fetchWallpapers(String category, [String query = '']) async {
    // Check if wallpapers are already cached for the selected category
    if (_wallpaperCache.containsKey(category)) {
      setState(() {
        _wallpapers = _wallpaperCache[category]!;
        _isLoading = false; // Ensure loading indicator is off
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Determine the API parameters based on the category
    String orderFilter = ORDER_RECENT;
    String imageFilter = FILTER_WALLPAPER;

    switch (category) {
      case 'recent':
        orderFilter = ORDER_RECENT;
        imageFilter = FILTER_WALLPAPER;
        break;
      case 'featured':
        orderFilter = ORDER_FEATURED;
        imageFilter = FILTER_WALLPAPER;
        break;
      case 'popular':
        orderFilter = ORDER_POPULAR;
        imageFilter = FILTER_WALLPAPER;
        break;
      case 'random':
        orderFilter = ORDER_RANDOM;
        imageFilter = FILTER_WALLPAPER;
        break;
      case 'live_wallpaper':
        orderFilter = ORDER_LIVE;
        imageFilter = FILTER_LIVE;
        break;
    }

    try {
      int page = 1;
      bool hasMore = true;
      List<dynamic> fetchedWallpapers = [];

      while (hasMore) {
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

      // Cache the fetched wallpapers
      setState(() {
        _wallpaperCache[category] = fetchedWallpapers;
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

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });

    // Fetch wallpapers only if they are not cached
    switch (index) {
      case 0:
        fetchWallpapers('recent');
        break;
      case 1:
        fetchWallpapers('featured');
        break;
      case 2:
        fetchWallpapers('popular');
        break;
      case 3:
        fetchWallpapers('random');
        break;
      case 4:
        fetchWallpapers('live_wallpaper');
        break;
    }
  }

  // Future<void> fetchWallpapers(
  //     [String category = 'recent', String query = '']) async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   String orderFilter = ORDER_RECENT;
  //   String imageFilter = FILTER_WALLPAPER;

  //   // Adjust API parameters based on category selection
  //   switch (category) {
  //     case 'recent':
  //       orderFilter = ORDER_RECENT;
  //       imageFilter = FILTER_WALLPAPER;
  //       break;
  //     case 'featured':
  //       orderFilter = ORDER_FEATURED;
  //       imageFilter = FILTER_WALLPAPER;
  //       break;
  //     case 'popular':
  //       orderFilter = ORDER_POPULAR;
  //       imageFilter = FILTER_WALLPAPER;
  //       break;
  //     case 'random':
  //       orderFilter = ORDER_RANDOM;
  //       imageFilter = FILTER_WALLPAPER;
  //       break;
  //     case 'live_wallpaper':
  //       orderFilter = ORDER_LIVE;
  //       imageFilter = FILTER_LIVE;
  //       break;
  //     default:
  //       orderFilter = ORDER_RECENT;
  //       imageFilter = FILTER_WALLPAPER;
  //   }

  //   try {
  //     int page = 1;
  //     bool hasMore = true;
  //     List<dynamic> fetchedWallpapers = [];

  //     while (hasMore) {
  //       // Modify API URL to include search query if provided
  //       final response = await http.get(
  //         Uri.parse(
  //             '$apiUrl?get_wallpapers&page=$page&count=20&filter=$imageFilter&order=$orderFilter&search=$query'),
  //         headers: headers,
  //       );

  //       if (response.statusCode == 200) {
  //         final data = json.decode(response.body);

  //         if (data['status'] == 'ok') {
  //           fetchedWallpapers.addAll(data['posts']);
  //           totalCount = data['count_total'];

  //           if (fetchedWallpapers.length >= int.parse(totalCount)) {
  //             hasMore = false;
  //           } else {
  //             page++;
  //           }
  //         } else {
  //           hasMore = false;
  //         }
  //       } else {
  //         throw Exception('Failed to load wallpapers');
  //       }
  //     }

  //     setState(() {
  //       _wallpapers = fetchedWallpapers;
  //     });
  //   } catch (e) {
  //     print('Error fetching wallpapers: $e');
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  // void _onTabSelected(int index) {
  //   setState(() {
  //     _selectedTabIndex = index;
  //   });

  //   // Fetch wallpapers based on the selected tab
  //   switch (index) {
  //     case 0:
  //       fetchWallpapers('recent');
  //       break;
  //     case 1:
  //       fetchWallpapers('featured');
  //       break;
  //     case 2:
  //       fetchWallpapers('popular');
  //       break;
  //     case 3:
  //       fetchWallpapers('random');
  //       break;
  //     case 4:
  //       fetchWallpapers('live_wallpaper');
  //       break;
  //   }
  // }

  String getImageUrl(String imageUpload) {
    return 'https://gaming.sunztech.com/upload/$imageUpload';
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          // Tab bar
          Container(
            width: size.width,
            color: appProvider.isDarkTheme ? Colors.black : Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTab('Recent', 0),

                _buildTab('Featured', 1),
                _buildTab('Popular', 2),
                _buildTab('Random', 3),
                // _buildTab('Live ', 4),
              ],
            ),
          ),

          // Grid of wallpapers
          Expanded(
              child: _isLoading
                  ? Padding(
                      padding: EdgeInsets.only(top: 7, left: 3, right: 3),
                      child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: appProvider.displayWallpaperColumns,
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
                          }),
                    )
                  : _wallpapers.isEmpty
                      ? Center(child: Text('No wallpapers found'))
                      :
                      // GridView.builder(
                      //     controller: ScrollController(),
                      //     padding: EdgeInsets.all(10),
                      //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      //       crossAxisCount: appProvider.displayWallpaperColumns,
                      //       crossAxisSpacing: 6,
                      //       mainAxisSpacing: 6,
                      //       childAspectRatio: 0.6,
                      //     ),
                      //     itemCount: _wallpapers.length +
                      //         (_wallpapers.length / 9).floor(),
                      //     itemBuilder: (context, index) {
                      //       if (index > 0 && index % 9 == 0) {
                      //         return Column(
                      //           children: [
                      //             const EasySmartBannerAd(
                      //               priorityAdNetworks: [
                      //                 AdNetwork.facebook,
                      //                 AdNetwork.admob,
                      //                 AdNetwork.unity,
                      //                 AdNetwork.appLovin,
                      //               ],
                      //               adSize: AdSize.banner,
                      //             ),
                      //             SizedBox(height: 10),
                      //           ],
                      //         );
                      //       }
                      //       final wallpaper =
                      //           _wallpapers[index - (index / 9).floor()];
                      //       final imageUrl =
                      //           getImageUrl(wallpaper['image_upload']);

                      //       return ClipRRect(
                      //         borderRadius: BorderRadius.circular(10),
                      //         child: Stack(
                      //           children: [
                      //             Container(
                      //               height: size.height * 0.8,
                      //               width: size.width * 0.5,
                      //               child: GestureDetector(
                      //                 onTap: () {
                      //                   _handleTap();
                      //                   Navigator.push(
                      //                       context,
                      //                       MaterialPageRoute(
                      //                           builder: (context) =>
                      //                               WallpaperDetailsScreen(
                      //                                 wallpapers: _wallpapers,
                      //                                 initialIndex: index,
                      //                               )));
                      //                 },
                      //                 child: CachedNetworkImage(
                      //                   imageUrl: imageUrl,
                      //                   fit: BoxFit.cover,
                      //                   placeholder: (context, url) => Center(
                      //                     child: CircularProgressIndicator(
                      //                       color: Colors.green,
                      //                     ),
                      //                   ),
                      //                   errorWidget: (context, url, error) =>
                      //                       Center(
                      //                     child: Icon(
                      //                       Icons.broken_image,
                      //                       color: Colors.grey,
                      //                       size: 50,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       );
                      //     },
                      //   ),
                      AdGridView(
                          controller: ScrollController(),

                          crossAxisCount: appProvider.displayWallpaperColumns,
                          adGridViewType: AdGridViewType.custom,
                          itemCount:
                              _wallpapers.length, // Total number of wallpapers
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
                                onPaidEvent:
                                    (ad, value, precision, currencyCode) {
                                  print(
                                      "Paid event: $value $currencyCode with precision: $precision");
                                },
                              ),
                              // SizedBox(height: 10),
                            ],
                          ),
                          itemWidget: (context, index) {
                            final wallpaper = _wallpapers[index];
                            final imageUrl =
                                getImageUrl(wallpaper['image_upload']);

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
                                                  builder: (context) =>
                                                      WallpaperDetailsScreen(
                                                        wallpapers: _wallpapers,
                                                        initialIndex: index,
                                                      )));
                                        },
                                        child: CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(
                                            child: Shimmer.fromColors(
                                              baseColor: appProvider.isDarkTheme
                                                  ? Colors.grey[800]!
                                                  : Colors.grey[300]!,
                                              highlightColor:
                                                  appProvider.isDarkTheme
                                                      ? Colors.grey[700]!
                                                      : Colors.grey[200]!,
                                              child: Container(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Center(
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
                        )),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final appProvider = Provider.of<AppProvider>(context);
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : appProvider.isDarkTheme
                    ? Colors.white70
                    : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// class WallpaperScreen extends StatefulWidget {
//   @override
//   _WallpaperScreenState createState() => _WallpaperScreenState();
// }

// class _WallpaperScreenState extends State<WallpaperScreen> {
//   InterstitialAd? _interstitialAd;
//   bool isInterstitialAdLoaded = false;

//   int _selectedTabIndex = 0;
//   Map<int, List<dynamic>> _cachedWallpapers = {};
//   Map<int, bool> _isTabLoaded = {};
//   Map<int, int> _tabPageTracker = {};
//   List<dynamic> _wallpapers = [];
//   bool _isLoading = false;
//   String totalCount = '';

//   final String apiUrl = 'https://gaming.sunztech.com/api/v1/api.php';
//   final Map<String, String> headers = {
//     'Cache-Control': 'max-age=0',
//     'Data-Agent': 'Material Wallpaper',
//   };

//   static const List<String> _categories = [
//     'recent',
//     'featured',
//     'popular',
//     'random',
//     'live_wallpaper',
//   ];

//   static const String FILTER_ALL = "g.image_extension != 'all'";
//   static const String FILTER_WALLPAPER = "g.image_extension != 'image/gif'";
//   static const String FILTER_LIVE = "g.image_extension = 'image/gif'";
//   static const String ORDER_RECENT = "ORDER BY g.id DESC";
//   static const String ORDER_FEATURED =
//       "AND g.featured = 'yes' ORDER BY g.last_update DESC";
//   static const String ORDER_POPULAR = "ORDER BY g.view_count DESC";
//   static const String ORDER_RANDOM = "ORDER BY RAND()";
//   static const String ORDER_LIVE = "ORDER BY g.id DESC";

//   @override
//   void initState() {
//     super.initState();
//     _loadInterstitialAd();
//     _fetchWallpapers();
//     AdmobEasy.instance.initialize(
//       androidNativeAdID: 'ca-app-pub-3940256099942544/2247696110',
//     );
//   }

//   void _loadInterstitialAd() {
//     InterstitialAd.load(
//       adUnitId: 'ca-app-pub-3940256099942544/1033173712',
//       request: AdRequest(),
//       adLoadCallback: InterstitialAdLoadCallback(
//         onAdLoaded: (InterstitialAd ad) {
//           setState(() {
//             _interstitialAd = ad;
//             isInterstitialAdLoaded = true;
//           });
//           ad.fullScreenContentCallback = FullScreenContentCallback(
//             onAdDismissedFullScreenContent: (InterstitialAd ad) {
//               ad.dispose();
//               _loadInterstitialAd();
//             },
//             onAdFailedToShowFullScreenContent: (Ad ad, AdError error) {
//               ad.dispose();
//               _loadInterstitialAd();
//             },
//           );
//         },
//         onAdFailedToLoad: (LoadAdError error) {
//           print('Failed to load interstitial ad: $error');
//           isInterstitialAdLoaded = false;
//         },
//       ),
//     );
//   }

//   void _showInterstitialAd() {
//     if (_interstitialAd != null) {
//       _interstitialAd!.show();
//       setState(() {
//         _interstitialAd = null;
//         isInterstitialAdLoaded = false;
//       });
//       _loadInterstitialAd();
//     } else {
//       print('Interstitial ad not loaded yet.');
//     }
//   }

//   void _handleTap() {
//     final appProvider = Provider.of<AppProvider>(context, listen: false);
//     appProvider.incrementTapCount();
//     if (appProvider.tapCount % 2 == 0) {
//       _showInterstitialAd();
//     }
//   }

//   Future<void> _fetchWallpapers({bool append = false}) async {
//     setState(() {
//       _isLoading = true;
//     });

//     String orderFilter = ORDER_RECENT;
//     String imageFilter = FILTER_WALLPAPER;
//     int tabIndex = _selectedTabIndex;
//     String category = _categories[tabIndex];

//     // Adjust filters based on category
//     switch (category) {
//       case 'featured':
//         orderFilter = ORDER_FEATURED;
//         break;
//       case 'popular':
//         orderFilter = ORDER_POPULAR;
//         break;
//       case 'random':
//         orderFilter = ORDER_RANDOM;
//         break;
//       case 'live_wallpaper':
//         imageFilter = FILTER_LIVE;
//         break;
//     }

//     try {
//       int page = _tabPageTracker[tabIndex] ?? 1;
//       final response = await http.get(
//         Uri.parse(
//             '$apiUrl?get_wallpapers&page=$page&count=12&filter=$imageFilter&order=$orderFilter'),
//         headers: headers,
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == 'ok') {
//           List<dynamic> fetchedWallpapers = data['posts'];
//           setState(() {
//             if (append) {
//               _cachedWallpapers[tabIndex]!.addAll(fetchedWallpapers);
//             } else {
//               _cachedWallpapers[tabIndex] = fetchedWallpapers;
//             }
//             _wallpapers = _cachedWallpapers[tabIndex]!;
//             _tabPageTracker[tabIndex] = page + 1;
//           });
//         }
//       } else {
//         throw Exception('Failed to load wallpapers');
//       }
//     } catch (e) {
//       print('Error fetching wallpapers: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//         _isTabLoaded[tabIndex] = true;
//       });
//     }
//   }

//   void _onTabSelected(int index) {
//     setState(() {
//       _selectedTabIndex = index;
//       _wallpapers = _cachedWallpapers[index] ?? [];
//     });
//     if (!(_isTabLoaded[index] ?? false)) {
//       _fetchWallpapers();
//     }
//   }

//   String getImageUrl(String imageUpload) {
//     return 'https://gaming.sunztech.com/upload/$imageUpload';
//   }

//   final int adIndex = 3;
//   @override
//   Widget build(BuildContext context) {
//     final appProvider = Provider.of<AppProvider>(context);
//     Size size = MediaQuery.of(context).size;
//     return Scaffold(
//       body: Column(children: [
//         // Tab bar
//         Container(
//           color: appProvider.isDarkTheme ? Colors.black : Colors.grey[200],
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: _categories
//                   .asMap()
//                   .entries
//                   .map((entry) => _buildTab(entry.value, entry.key))
//                   .toList(),
//             ),
//           ),
//         ),

//         // Grid of wallpapers
//         Expanded(
//           child: NotificationListener<ScrollNotification>(
//             onNotification: (ScrollNotification scrollInfo) {
//               if (scrollInfo.metrics.pixels ==
//                       scrollInfo.metrics.maxScrollExtent &&
//                   !_isLoading) {
//                 _fetchWallpapers(append: true);
//               }
//               return false;
//             },
//             child: _isLoading
//                 ? GridView.builder(
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: appProvider.displayWallpaperColumns,
//                       crossAxisSpacing: 6,
//                       mainAxisSpacing: 6,
//                       childAspectRatio: 0.6,
//                     ),
//                     itemCount: 15,
//                     itemBuilder: (context, index) {
//                       return Shimmer.fromColors(
//                         baseColor: appProvider.isDarkTheme
//                             ? Colors.grey[800]!
//                             : Colors.grey[300]!,
//                         highlightColor: appProvider.isDarkTheme
//                             ? Colors.grey[700]!
//                             : Colors.grey[200]!,
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: Container(
//                             height: size.height * 0.8,
//                             width: size.width * 0.5,
//                             color: Colors.white,
//                           ),
//                         ),
//                       );
//                     })
//                 : _wallpapers.isEmpty
//                     ? Center(child: Text('No wallpapers found'))
//                     : AdGridView(
//                         controller: ScrollController(),
//                         adGridViewType: AdGridViewType.repeated,
//                         crossAxisCount: appProvider.displayWallpaperColumns,
//                         itemCount:
//                             _wallpapers.length, // Total number of wallpapers
//                         adIndex:
//                             adIndex, // Insert ad after the 3rd wallpaper (index 3)
//                         itemMainAspectRatio: 1.5,
//                         adWidget: Column(
//                           children: [
//                             AdmobEasyNative.mediumTemplate(
//                               minWidth: 320,
//                               minHeight: 320,
//                               maxWidth: 360,
//                               maxHeight: 360,
//                               onAdOpened: (ad) => print("Ad Opened"),
//                               onAdClosed: (ad) => print("Ad Closed"),
//                               onPaidEvent:
//                                   (ad, value, precision, currencyCode) {
//                                 print(
//                                     "Paid event: $value $currencyCode with precision: $precision");
//                               },
//                             ),
//                             // You can add a SizedBox for spacing between the ad and the wallpapers
//                             // SizedBox(height: 10),
//                           ],
//                         ),
//                         itemWidget: (context, index) {
//                           final wallpaper = _wallpapers[index];
//                           final imageUrl =
//                               getImageUrl(wallpaper['image_upload']);

//                           return Padding(
//                             padding: const EdgeInsets.all(4.0),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: Stack(
//                                 children: [
//                                   Container(
//                                     height: size.height * 0.8,
//                                     width: size.width * 0.5,
//                                     child: GestureDetector(
//                                       onTap: () {
//                                         _handleTap();
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) =>
//                                                 WallpaperDetailsScreen(
//                                               wallpapers: _wallpapers,
//                                               initialIndex: index,
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                       child: CachedNetworkImage(
//                                         imageUrl: imageUrl,
//                                         fit: BoxFit.cover,
//                                         placeholder: (context, url) => Center(
//                                           child: Shimmer.fromColors(
//                                             baseColor: appProvider.isDarkTheme
//                                                 ? Colors.grey[800]!
//                                                 : Colors.grey[300]!,
//                                             highlightColor:
//                                                 appProvider.isDarkTheme
//                                                     ? Colors.grey[700]!
//                                                     : Colors.grey[200]!,
//                                             child: Container(
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                         ),
//                                         errorWidget: (context, url, error) =>
//                                             Center(
//                                           child: Icon(
//                                             Icons.broken_image,
//                                             color: Colors.grey,
//                                             size: 50,
//                                           ),
//                                         ),

//                                         // GridView.builder(
//                                         //     padding: EdgeInsets.all(10),
//                                         //     gridDelegate:
//                                         //         SliverGridDelegateWithFixedCrossAxisCount(
//                                         //       crossAxisCount: appProvider.displayWallpaperColumns,
//                                         //       crossAxisSpacing: 6,
//                                         //       mainAxisSpacing: 6,
//                                         //       childAspectRatio: 0.6,
//                                         //     ),
//                                         //     itemCount: _wallpapers.length,
//                                         //     itemBuilder: (context, index) {
//                                         //       final wallpaper = _wallpapers[index];
//                                         //       final imageUrl =
//                                         //           getImageUrl(wallpaper['image_upload']);

//                                         //       return ClipRRect(
//                                         //         borderRadius: BorderRadius.circular(10),
//                                         //         child: GestureDetector(
//                                         //           onTap: () {
//                                         //             _handleTap();
//                                         //             Navigator.push(
//                                         //               context,
//                                         //               MaterialPageRoute(
//                                         //                 builder: (context) =>
//                                         //                     WallpaperDetailsScreen(
//                                         //                   wallpapers: _wallpapers,
//                                         //                   initialIndex: index,
//                                         //                 ),
//                                         //               ),
//                                         //             );
//                                         //           },
//                                         //           child: CachedNetworkImage(
//                                         //             imageUrl: imageUrl,
//                                         //             fit: BoxFit.cover,
//                                         //             placeholder: (context, url) =>
//                                         //                 Shimmer.fromColors(
//                                         //               baseColor: appProvider.isDarkTheme
//                                         //                   ? Colors.grey[800]!
//                                         //                   : Colors.grey[300]!,
//                                         //               highlightColor: appProvider.isDarkTheme
//                                         //                   ? Colors.grey[700]!
//                                         //                   : Colors.grey[200]!,
//                                         //               child: Container(color: Colors.white),
//                                         //             ),
//                                         //             errorWidget: (context, url, error) => Icon(
//                                         //               Icons.broken_image,
//                                         //               color: Colors.grey,
//                                         //               size: 50,
//                                         //             ),
//                                         //           ),
//                                         //         ),
//                                         //       );
//                                         //     },
//                                         //   ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//           ),
//         )
//       ]),
//     );
//   }

//   Widget _buildTab(String title, int index) {
//     final appProvider = Provider.of<AppProvider>(context);
//     bool isSelected = _selectedTabIndex == index;
//     return GestureDetector(
//       onTap: () => _onTabSelected(index),
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 200),
//         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.green : Colors.transparent,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Text(
//           title,
//           style: TextStyle(
//             color: isSelected
//                 ? Colors.white
//                 : appProvider.isDarkTheme
//                     ? Colors.white70
//                     : Colors.black54,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }
