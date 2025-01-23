import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:materialwalpper/Provider/AppProvider.dart';
import 'package:materialwalpper/Screens/WallpaperScreen/DownloadScreen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:path_provider/path_provider.dart';

class CropImageScreen extends StatefulWidget {
  final String imageUrl;

  const CropImageScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<CropImageScreen> createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<CropImageScreen> {
  final CropController _cropController = CropController();
  bool _isCropping = false;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _downloadImage();
  }

  Future<void> _downloadImage() async {
    try {
      _imageBytes = await _loadImageBytes(widget.imageUrl);
      setState(() {});
    } catch (e) {
      print('Error downloading image: $e');
    }
  }

  Future<Uint8List> _loadImageBytes(String imageUrl) async {
    if (imageUrl.startsWith('http')) {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load image from network');
      }
    } else {
      final ByteData data = await rootBundle.load(imageUrl);
      return data.buffer.asUint8List();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final appProvider = Provider.of<AppProvider>(context);
    return Scaffold(
      backgroundColor: appProvider.isDarkTheme ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Crop Image'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: _isCropping
            ? const CircularProgressIndicator()
            : _imageBytes == null
                ? const CircularProgressIndicator()
                : Crop(
                    controller: _cropController,
                    image: _imageBytes!,
                    onCropped: (result) {
                      switch (result) {
                        case CropSuccess(:final croppedImage):
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ImageViewerScreen(image: croppedImage)));
                          // Return cropped image
                          break;
                        case CropFailure(:final cause):
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Error'),
                              content: Text('Failed to crop image: $cause'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          setState(() => _isCropping = false);
                      }
                    },
                    aspectRatio:
                        null, // Set aspect ratio to null for full image
                    // initialSize: 0.8,
                    initialRectBuilder: InitialRectBuilder.withSizeAndRatio(
                      aspectRatio: 0.5,
                    ),
                    withCircleUi:
                        false, // Change to true if you want circular cropping
                  ),
      ),
      floatingActionButton: _imageBytes == null
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isCropping = true;
                });

                _cropController.crop();
              },
              child: const Icon(Icons.done),
              backgroundColor: Colors.green,
            ),
    );
  }
}

class ImageViewerScreen extends StatefulWidget {
  final Uint8List image;
  const ImageViewerScreen({Key? key, required this.image}) : super(key: key);

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  // Set wallpaper function using flutter_wallpaper_manager
  Future<void> setWallpaper(int location) async {
    try {
      // Since we're working with image bytes, save the image temporarily
      final file = await _saveImageToTempFile(
        widget.image,
      );
      final bool result =
          await WallpaperManager.setWallpaperFromFile(file.path, location);

      if (result) {
      } else {}
    } on PlatformException {}
  }

  // Helper function to save image bytes to a temporary file
  Future<File> _saveImageToTempFile(Uint8List imageBytes) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_image.jpg');
    await tempFile.writeAsBytes(imageBytes);
    return tempFile;
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

  void _showRewardedAd(context) {
    if (_isAdLoaded) {
      _rewardedAd?.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          print('User earned reward: ${reward.amount} ${reward.type}');
          _downloadImage(context); // Proceed with the download after the ad
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

  void _showAd(context) {
    if (_isAdLoaded) {
      _showRewardedAd(context);
    }

    // _downloadImage();
  }

  Future<void> _downloadImage(context) async {
    try {
      print('Downloading image...');
      final result = await ImageGallerySaver.saveImage(
        widget.image,
        quality: 60,
        name: "wallpaper_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (result['isSuccess']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Downloadscreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save image.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cropped Image'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Image.memory(widget.image),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show bottom sheet to select wallpaper location
          showModalBottomSheet(
            backgroundColor: appProvider.isDarkTheme
                ? Colors.black
                : Colors.white, // Set background color based on theme
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: size.height * 0.3,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.home,
                        color: appProvider.isDarkTheme
                            ? Colors.white
                            : Colors.black,
                      ),
                      title: Text('Home Screen',
                          style: TextStyle(
                            color: appProvider.isDarkTheme
                                ? Colors.white
                                : Colors.black,
                          )),
                      onTap: () async {
                        Navigator.pop(context);
                        await setWallpaper(WallpaperManager.HOME_SCREEN);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.lock,
                        color: appProvider.isDarkTheme
                            ? Colors.white
                            : Colors.black,
                      ),
                      title: Text(
                        'Lock Screen',
                        style: TextStyle(
                          color: appProvider.isDarkTheme
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        await setWallpaper(WallpaperManager.LOCK_SCREEN);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.smartphone,
                        color: appProvider.isDarkTheme
                            ? Colors.white
                            : Colors.black,
                      ),
                      title: Text(
                        'Both',
                        style: TextStyle(
                          color: appProvider.isDarkTheme
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        await setWallpaper(WallpaperManager.BOTH_SCREEN);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.download,
                        color: appProvider.isDarkTheme
                            ? Colors.white
                            : Colors.black,
                      ),
                      title: Text(
                        'Download',
                        style: TextStyle(
                          color: appProvider.isDarkTheme
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      onTap: () {
                        //Save image to device
                        // save to App Directory
                        // _downloadImage();
                        int _timerSeconds = 5; // Countdown timer
                        Timer? timer; // Timer reference

                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                // Start the timer when the dialog is shown
                                timer ??= Timer.periodic(
                                  const Duration(seconds: 1),
                                  (timer) {
                                    if (_timerSeconds > 1) {
                                      setState(() {
                                        _timerSeconds--;
                                      });
                                    } else {
                                      timer.cancel(); // Stop the timer
                                      // timer =
                                      //     null; // Reset the timer reference
                                      if (Navigator.canPop(dialogContext)) {
                                        // Navigator.of(dialogContext)
                                        //     .pop(); // Close the dialog
                                      }
                                      _showAd(
                                          context); // Show the ad after dialog is closed
                                    }
                                  },
                                );

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
                                        if (timer != null && timer!.isActive) {
                                          timer!
                                              .cancel(); // Cancel the timer if active
                                          timer =
                                              null; // Reset the timer reference
                                        }
                                        Navigator.of(dialogContext)
                                            .pop(); // Close the dialog
                                      },
                                    ),
                                    SizedBox(width: 30),
                                    TextButton(
                                      child: Text(
                                        'Ad Starts in $_timerSeconds',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                      onPressed: () {
                                        if (timer != null && timer!.isActive) {
                                          timer!.cancel(); // Cancel the timer
                                          timer =
                                              null; // Reset the timer reference
                                        }
                                        // Navigator.of(dialogContext)
                                        //     .pop(); // Close the dialog
                                        _showAd(context); // Show the ad
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ).then((_) {
                          // Ensure timer cleanup when dialog is dismissed
                          if (timer != null && timer!.isActive) {
                            timer!.cancel();
                            timer = null;
                          }
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.wallpaper),
        backgroundColor: Colors.green,
      ),
    );
  }
}
