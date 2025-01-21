import 'package:ad_gridview/ad_gridview.dart';
import 'package:admob_easy/ads/admob_easy.dart';
import 'package:admob_easy/ads/services/admob_easy_native.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:materialwalpper/Provider/AppProvider.dart';
import 'package:materialwalpper/Provider/FavoriteProvider.dart';
import 'package:materialwalpper/Screens/WallpaperScreen/WallpaperDetailsScreen.dart';
// import 'package:materialwalpper/wallpaper_detail.dart';
import 'package:provider/provider.dart'; // Import for Provider

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  InterstitialAd? _interstitialAd;
  bool isInterstitialAdLoaded = false;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);
    final favorites = favoriteProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        centerTitle: true,
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 100,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Whoops!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Your favorite list is empty because\nyou have not added any wallpapers in\nthe favorite menu.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : AdGridView(
              padding: const EdgeInsets.all(8.0),
              // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  appProvider.displayWallpaperColumns, // Number of columns
              //   crossAxisSpacing: 8.0,
              //   mainAxisSpacing: 8.0,
              //   childAspectRatio:
              //       0.7, // Adjust to fit the wallpaper aspect ratio
              // ),
              controller: ScrollController(),
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

              adGridViewType: AdGridViewType.custom,
              // itemCount: _wallpapers.length, // Total number of wallpapers
              adIndex: 3,
              itemMainAspectRatio: 1.5,
              customAdIndex: [3, 15, 30, 45, 60, 75, 90, 105],
              itemCount: favorites.length,
              itemWidget: (context, index) {
                final wallpaper = favorites[index];
                final imageUrl =
                    'https://gaming.sunztech.com/upload/${wallpaper['image_upload']}';

                return GestureDetector(
                  onTap: () {
                    final wallpaper = favorites[index];

                    // Validate required fields
                    if (wallpaper['image_upload'] == null ||
                        wallpaper['id'] == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Invalid wallpaper data. Cannot open details.'),
                        ),
                      );
                      return;
                    }
                    print('favorites: $favorites');
                    print('indexnn: $index');
                    _handleTap();
                    // Optional: Navigate to a detailed wallpaper view if needed
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WallpaperDetailsScreen(
                                  wallpapers: favorites,
                                  initialIndex: index,
                                )));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Image.network(
                          //   imageUrl,
                          //   fit: BoxFit.cover,
                          //   errorBuilder: (context, error, stackTrace) =>
                          //       const Center(
                          //     child: Icon(
                          //       Icons.broken_image,
                          //       size: 50,
                          //       color: Colors.grey,
                          //     ),
                          //   ),
                          // ),
                          CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8.0,
                            right: 8.0,
                            child: IconButton(
                              icon: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                favoriteProvider
                                    .removeFavorite(wallpaper['id']);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Removed from favorites'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
