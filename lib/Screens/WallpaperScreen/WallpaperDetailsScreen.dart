import 'dart:async';
import 'dart:developer';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:materialwalpper/Provider/AppProvider.dart';
import 'package:materialwalpper/Provider/FavoriteProvider.dart';
import 'package:materialwalpper/Screens/WallpaperScreen/CropImageScreen.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // For the BackdropFilter widget
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';

const IAdIdManager adIdManager = TestAdIdManager();

class WallpaperDetailsScreen extends StatefulWidget {
  final List<dynamic> wallpapers;
  final int initialIndex;

  WallpaperDetailsScreen(
      {required this.wallpapers, required this.initialIndex});

  @override
  _WallpaperDetailsScreenState createState() => _WallpaperDetailsScreenState();
}

class _WallpaperDetailsScreenState extends State<WallpaperDetailsScreen> {
  late int _currentIndex;
  InterstitialAd? _interstitialAd;
  bool isInterstitialAdLoaded = false;
  int _timerSeconds = 5;
  Timer? _timer;
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 1;

    log('WallpaperDetailsScreen: initState() ${widget.wallpapers}');
    log('WallpaperDetailsScreen: initState() $_currentIndex');
    EasyAds.instance.initialize(
      adIdManager,
      adMobAdRequest: const AdRequest(),
      fbTestMode: true, // Optional, if you are using Facebook Ads in test mode
    );
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          print('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_isAdLoaded) {
      _rewardedAd?.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          print('User earned reward: ${reward.amount} ${reward.type}');
          _downloadImage(); // Proceed with the download after the ad
        },
      );
      _rewardedAd = null; // Dispose of the rewarded ad
      _loadRewardedAd(); // Load a new rewarded ad for the next use
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad not ready. Please try again later.')),
      );
    }
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

  // void _startTimer() {
  //   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     if (_timerSeconds > 1) {
  //       setState(() {
  //         _timerSeconds--;
  //       });
  //     } else {
  //       timer.cancel();
  //       _showAd();
  //     }
  //   });
  // }

  void _showAd() {
    if (_isAdLoaded) {
      _showRewardedAd();
    }
    // _downloadImage();
  }

  Future<void> _downloadImage() async {
    print('Download Image');
    final wallpapers = widget.wallpapers;

    final response = await http
        .get(Uri.parse(getImageUrl(wallpapers[_currentIndex]['image_upload'])));
    if (response.statusCode == 200) {
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.bodyBytes),
        quality: 60,
        name: "wallpaper_${DateTime.now().millisecondsSinceEpoch}",
      );
      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to gallery!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download image.')),
      );
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

  // String getImageUrl(String imageUpload) {
  //   return 'https://gaming.sunztech.com/upload/$imageUpload';
  // }
  String getImageUrl(String? imageUpload) {
    if (imageUpload == null || imageUpload.isEmpty) {
      throw Exception('Image upload path is null or empty');
    }
    return 'https://gaming.sunztech.com/upload/$imageUpload';
  }

  // Set wallpaper function using flutter_wallpaper_manager
  Future<void> setWallpaper(location) async {
    try {
      final wallpaperUrl =
          getImageUrl(widget.wallpapers[_currentIndex]['image_upload']);
      // int location = WallpaperManager
      //     .BOTH_SCREEN; // You can change it to LOCK_SCREEN if needed.
      var file = await DefaultCacheManager().getSingleFile(wallpaperUrl);
      final bool result =
          await WallpaperManager.setWallpaperFromFile(file.path, location);
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wallpaper set successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to set wallpaper.')),
        );
      }
    } on PlatformException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error setting wallpaper.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    Size size = MediaQuery.of(context).size;
    final wallpapers = widget.wallpapers;
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    // Get the current wallpaper's image URL for the background
    final backgroundImageUrl =
        getImageUrl(wallpapers[_currentIndex]['image_upload']);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Blur and Opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.5, // Adjust opacity as needed
              child: BackdropFilter(
                filter:
                    ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Apply blur
                child: Image.network(
                  backgroundImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Foreground Content
          Column(
            children: [
              Expanded(
                child: CarouselSlider.builder(
                  itemCount: wallpapers.length,
                  itemBuilder: (context, index, realIndex) {
                    final wallpaper = wallpapers[index];
                    final imageUrl = getImageUrl(wallpaper['image_upload']);

                    return GestureDetector(
                      onTap: () {
                        // Optional: Handle tap on wallpaper
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: 480,
                    viewportFraction: 0.69, // Show adjacent images partially
                    aspectRatio: 2.0,
                    enlargeCenterPage: true, // Enlarges the current image
                    initialPage: widget.initialIndex ?? 1,
                    enableInfiniteScroll: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: size.height * 0.06,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: appProvider.isDarkTheme
                            ? Colors.grey[800]
                            : Colors.white,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.share,
                          color: appProvider.isDarkTheme
                              ? Colors.white
                              : Colors.black,
                        ),
                        onPressed: () {
                          Share.share(
                              'Check out this wallpaper: $backgroundImageUrl');
                        },
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: appProvider.isDarkTheme
                            ? Colors.grey[800]
                            : Colors.white,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.download_outlined,
                          color: appProvider.isDarkTheme
                              ? Colors.white
                              : Colors.black,
                        ),
                        onPressed: () async {
                          int _timerSeconds = 5;

                          Timer? timer;

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  // Start the timer when the dialog is shown
                                  // Timer.periodic(const Duration(seconds: 1),
                                  //     (timer) {
                                  //   if (_timerSeconds > 1) {
                                  //     setState(() {
                                  //       _timerSeconds--;
                                  //     });
                                  //   } else {
                                  //     timer.cancel();
                                  //     // Navigator.pop(context);
                                  //     Navigator.of(context)
                                  //         .pop(); // Close the dialog
                                  //     // _showAd(); // Show the interstitial ad
                                  //   }
                                  // });

                                  // Future.delayed(
                                  //     Duration(seconds: _timerSeconds), () {
                                  //   if (mounted) {
                                  //     Navigator.of(context)
                                  //         .pop(); // Close the dialog
                                  //   }
                                  // });

                                  timer ??= Timer.periodic(
                                      const Duration(seconds: 1), (timer) {
                                    if (_timerSeconds > 1) {
                                      setState(() {
                                        _timerSeconds--;
                                      });
                                    } else {
                                      timer.cancel();
                                      if (Navigator.canPop(context)) {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      }
                                      _showAd(); // Uncomment this to show the ad after dialog closes
                                    }
                                  });

                                  return AlertDialog(
                                    title: Text(
                                      'Download Free Wallpaper',
                                      style: TextStyle(
                                        fontSize: 19,
                                        color: appProvider.isDarkTheme
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    content: Text(
                                      'Wallpaper will be downloaded after the short ad.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: appProvider.isDarkTheme
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text(
                                          'No Thanks',
                                          style: TextStyle(
                                              color: Colors.blue, fontSize: 12),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      SizedBox(width: 30),
                                      TextButton(
                                        child: Text(
                                          'Ad Start in $_timerSeconds',
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _showAd();
                                          //   final response = await http
                                          //       .get(Uri.parse(backgroundImageUrl));
                                          //   if (response.statusCode == 200) {

                                          //     final result =
                                          //         await ImageGallerySaver.saveImage(
                                          //       Uint8List.fromList(
                                          //           response.bodyBytes),
                                          //       quality: 60,
                                          //       name:
                                          //           "wallpaper_${DateTime.now().millisecondsSinceEpoch}",
                                          //     );
                                          //     if (result['isSuccess']) {
                                          //       ScaffoldMessenger.of(context)
                                          //           .showSnackBar(
                                          //         SnackBar(
                                          //             content: Text(
                                          //                 'Image saved to gallery!')),
                                          //       );
                                          //     } else {
                                          //       ScaffoldMessenger.of(context)
                                          //           .showSnackBar(
                                          //         SnackBar(
                                          //             content: Text(
                                          //                 'Failed to save image.')),
                                          //       );
                                          //     }
                                          //   } else {
                                          //     ScaffoldMessenger.of(context)
                                          //         .showSnackBar(
                                          //       SnackBar(
                                          //           content: Text(
                                          //               'Failed to download image.')),
                                          //     );
                                          //   }
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: appProvider.isDarkTheme
                            ? Colors.grey[800]
                            : Colors.white,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.wallpaper,
                          color: appProvider.isDarkTheme
                              ? Colors.white
                              : Colors.black,
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            backgroundColor: appProvider.isDarkTheme
                                ? Colors.black
                                : Colors.white,
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height: size.height * 0.4,
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.home,
                                          color: appProvider.isDarkTheme
                                              ? Colors.white
                                              : Colors.black),
                                      title: Text('Home Screen',
                                          style: TextStyle(
                                            color: appProvider.isDarkTheme
                                                ? Colors.white
                                                : Colors.black,
                                          )),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        await setWallpaper(
                                            WallpaperManager.HOME_SCREEN);
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.lock,
                                          color: appProvider.isDarkTheme
                                              ? Colors.white
                                              : Colors.black),
                                      title: Text('Lock Screen',
                                          style: TextStyle(
                                            color: appProvider.isDarkTheme
                                                ? Colors.white
                                                : Colors.black,
                                          )),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        await setWallpaper(
                                            WallpaperManager.LOCK_SCREEN);
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.smartphone,
                                          color: appProvider.isDarkTheme
                                              ? Colors.white
                                              : Colors.black),
                                      title: Text('Both',
                                          style: TextStyle(
                                            color: appProvider.isDarkTheme
                                                ? Colors.white
                                                : Colors.black,
                                          )),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        await setWallpaper(
                                            WallpaperManager.BOTH_SCREEN);
                                      },
                                    ),
                                    // crop wallpaper for croping image navigate next screen passing the image
                                    ListTile(
                                      leading: Icon(Icons.crop,
                                          color: appProvider.isDarkTheme
                                              ? Colors.white
                                              : Colors.black),
                                      title: Text('Crop',
                                          style: TextStyle(
                                            color: appProvider.isDarkTheme
                                                ? Colors.white
                                                : Colors.black,
                                          )),
                                      onTap: () async {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CropImageScreen(
                                                        imageUrl:
                                                            backgroundImageUrl)));
                                      },
                                    ),
                                    //Save to device

                                    ListTile(
                                      leading: Icon(Icons.save,
                                          color: appProvider.isDarkTheme
                                              ? Colors.white
                                              : Colors.black),
                                      title: Text('Save to Device',
                                          style: TextStyle(
                                            color: appProvider.isDarkTheme
                                                ? Colors.white
                                                : Colors.black,
                                          )),
                                      onTap: () async {
                                        //Save image to device
                                        // save to App Directory
                                        _downloadImage();
                                        Navigator.pop(context);
                                      },
                                    ),

                                    // ListTile(
                                    //   leading: Icon(Icons.saveto_device,
                                    //       color: appProvider.isDarkTheme
                                    //           ? Colors.white
                                    //           : Colors.black),
                                    //   title: Text('Save to Device',
                                    //       style: TextStyle(
                                    //         color: appProvider.isDarkTheme
                                    //             ? Colors.white
                                    //             : Colors.black,
                                    //       )),
                                    //   onTap: () async {},
                                    // ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    // Container(
                    //   width: 40,
                    //   height: 40,
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(10),
                    //     color: appProvider.isDarkTheme
                    //         ? Colors.grey[800]
                    //         : Colors.white,
                    //   ),
                    //   child: IconButton(
                    //     icon: Builder(builder: (context) {
                    //       log('Favorite Icon: ${widget.wallpapers[_currentIndex]}');

                    //       return Icon(
                    //         favoriteProvider.isFavorite(
                    //                 widget.wallpapers[_currentIndex]
                    //                         ['image_id'] ??
                    //                     '')
                    //             ? Icons.favorite
                    //             : Icons.favorite_border,
                    //         color: favoriteProvider.isFavorite(
                    //                 widget.wallpapers[_currentIndex]
                    //                         ['image_id'] ??
                    //                     '')
                    //             ? Colors.red
                    //             : appProvider.isDarkTheme
                    //                 ? Colors.white
                    //                 : Colors.black,
                    //       );
                    //     }),
                    //     onPressed: () {
                    //       final wallpaper = widget.wallpapers[_currentIndex];

                    //       // Validate if the required fields are present
                    //       if (wallpaper['image_id'] == null ||
                    //           wallpaper['image_upload'] == null) {
                    //         ScaffoldMessenger.of(context).showSnackBar(
                    //           SnackBar(
                    //             content: Text(
                    //               'Invalid wallpaper data. Cannot update favorites.',
                    //             ),
                    //           ),
                    //         );
                    //         return;
                    //       }

                    //       // Check if the wallpaper is already in favorites
                    //       if (favoriteProvider
                    //           .isFavorite(wallpaper['image_id'])) {
                    //         // Remove from favorites
                    //         favoriteProvider
                    //             .removeFavorite(wallpaper['image_id']);
                    //         ScaffoldMessenger.of(context).showSnackBar(
                    //           SnackBar(
                    //             content:
                    //                 Text('Wallpaper removed from favorites!'),
                    //           ),
                    //         );
                    //       } else {
                    //         // Add to favorites
                    //         favoriteProvider.addFavorite({
                    //           'id': wallpaper['image_id'] ??
                    //               '', // Use image_id as the id
                    //           'image_upload': wallpaper['image_upload'] ?? '',
                    //           'image_name':
                    //               wallpaper['image_name'] ?? 'Unknown',
                    //           'category_name':
                    //               wallpaper['category_name'] ?? 'Unknown',
                    //         });
                    //         ScaffoldMessenger.of(context).showSnackBar(
                    //           SnackBar(
                    //             content: Text('Wallpaper added to favorites!'),
                    //           ),
                    //         );
                    //       }
                    //     },
                    //   ),
                    // ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: appProvider.isDarkTheme
                            ? Colors.grey[800]
                            : Colors.white,
                      ),
                      child: IconButton(
                        icon: Builder(
                          builder: (context) {
                            final wallpaper = widget.wallpapers[_currentIndex];
                            final imageId = wallpaper['image_id'];
                            final fallbackId = wallpaper[
                                'id']; // Fallback to id if image_id is null
                            final isFavorite = (imageId != null &&
                                    favoriteProvider.isFavorite(imageId)) ||
                                (imageId == null &&
                                    fallbackId != null &&
                                    favoriteProvider.isFavorite(fallbackId));

                            // Debug log
                            log('Favorite Icon: $wallpaper');
                            return Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? Colors.red
                                  : appProvider.isDarkTheme
                                      ? Colors.white
                                      : Colors.black,
                            );
                          },
                        ),
                        onPressed: () {
                          final wallpaper = widget.wallpapers[_currentIndex];
                          final imageId = wallpaper['image_id'] ??
                              wallpaper['id']; // Use id as fallback

                          // Validate if the wallpaper has an ID to work with
                          if (imageId == null ||
                              wallpaper['image_upload'] == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Invalid wallpaper data. Cannot update favorites.',
                                ),
                              ),
                            );
                            return;
                          }

                          // Check if the wallpaper is already in favorites
                          if (favoriteProvider.isFavorite(imageId)) {
                            // Remove from favorites
                            favoriteProvider.removeFavorite(imageId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Wallpaper removed from favorites!'),
                              ),
                            );
                          } else {
                            // Add to favorites
                            favoriteProvider.addFavorite({
                              'id': imageId, // Use the resolved image ID
                              'image_upload': wallpaper['image_upload'] ?? '',
                              'image_name':
                                  wallpaper['image_name'] ?? 'Unknown',
                              'category_name':
                                  wallpaper['category_name'] ?? 'Unknown',
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Wallpaper added to favorites!'),
                              ),
                            );
                          }
                        },
                      ),
                    ),

                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: appProvider.isDarkTheme
                            ? Colors.grey[800]
                            : Colors.white,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.info_outline,
                          color: appProvider.isDarkTheme
                              ? Colors.white
                              : Colors.black,
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            backgroundColor: appProvider.isDarkTheme
                                ? Colors.black
                                : Colors.white,
                            context: context,
                            builder: (BuildContext context) {
                              final wallpaper =
                                  widget.wallpapers[_currentIndex];
                              return Container(
                                height: size.height * 0.4,
                                width: size.width,
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Wallpaper Details',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: appProvider.isDarkTheme
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Name: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        appProvider.isDarkTheme
                                                            ? Colors.white
                                                            : Colors.black,
                                                  )),
                                              SizedBox(height: 5),
                                              Text('Resolution: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        appProvider.isDarkTheme
                                                            ? Colors.white
                                                            : Colors.black,
                                                  )),
                                              SizedBox(height: 5),
                                              Text('Size: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        appProvider.isDarkTheme
                                                            ? Colors.white
                                                            : Colors.black,
                                                  )),
                                              SizedBox(height: 5),
                                              Text('Views: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        appProvider.isDarkTheme
                                                            ? Colors.white
                                                            : Colors.black,
                                                  )),
                                              SizedBox(height: 5),
                                              Text('Downloads: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        appProvider.isDarkTheme
                                                            ? Colors.white
                                                            : Colors.black,
                                                  )),
                                              SizedBox(height: 5),
                                              Text('Category: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        appProvider.isDarkTheme
                                                            ? Colors.white
                                                            : Colors.black,
                                                  )),
                                              SizedBox(height: 5),
                                              Text('Last Update: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        appProvider.isDarkTheme
                                                            ? Colors.white
                                                            : Colors.black,
                                                  )),
                                              SizedBox(height: 5),
                                              Divider(
                                                color: appProvider.isDarkTheme
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                              Container(
                                                padding: EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                  top: 5,
                                                  bottom: 5,
                                                ),
                                                child: Text('Tags: ',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: appProvider
                                                              .isDarkTheme
                                                          ? Colors.white
                                                          : Colors.black,
                                                    )),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('${wallpaper['image_name']}',
                                                  style: TextStyle(
                                                    color:
                                                        appProvider.isDarkTheme
                                                            ? Colors.white
                                                            : Colors.black,
                                                  )),
                                              SizedBox(height: 5),
                                              Text('${wallpaper['resolution']}',
                                                  style: TextStyle(
                                                    color:
                                                        appProvider.isDarkTheme
                                                            ? Colors.white
                                                            : Colors.black,
                                                  )),
                                              SizedBox(height: 5),
                                              Text('${wallpaper['size']}',
                                                  style: TextStyle(
                                                    color:
                                                        appProvider.isDarkTheme
                                                            ? Colors.white
                                                            : Colors.black,
                                                  )),
                                              SizedBox(height: 5),
                                              Text('${wallpaper['views']}',
                                                  style: TextStyle(
                                                    color:
                                                        appProvider.isDarkTheme
                                                            ? Colors.white
                                                            : Colors.black,
                                                  )),
                                              SizedBox(height: 5),
                                              Text('${wallpaper['downloads']}',
                                                  style: TextStyle(
                                                    color:
                                                        appProvider.isDarkTheme
                                                            ? Colors.white
                                                            : Colors.black,
                                                  )),
                                              SizedBox(height: 5),
                                              Text(
                                                  '${wallpaper['category_name']}',
                                                  style: TextStyle(
                                                    color:
                                                        appProvider.isDarkTheme
                                                            ? Colors.white
                                                            : Colors.black,
                                                  )),
                                              SizedBox(height: 5),
                                              Text(
                                                  '${wallpaper['last_update']}',
                                                  style: TextStyle(
                                                    color:
                                                        appProvider.isDarkTheme
                                                            ? Colors.white
                                                            : Colors.black,
                                                  )),
                                              SizedBox(height: 5),
                                              Divider(
                                                color: appProvider.isDarkTheme
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                              Container(
                                                padding: EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                  top: 5,
                                                  bottom: 5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color.fromARGB(
                                                      255, 94, 206, 97),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child:
                                                    Text('${wallpaper['tags']}',
                                                        style: TextStyle(
                                                          color: appProvider
                                                                  .isDarkTheme
                                                              ? Colors.white
                                                              : Colors.black,
                                                        )),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
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
}
