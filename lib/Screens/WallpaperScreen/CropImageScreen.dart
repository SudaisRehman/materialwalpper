import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:materialwalpper/Provider/AppProvider.dart';
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

class ImageViewerScreen extends StatelessWidget {
  final Uint8List image;
  const ImageViewerScreen({Key? key, required this.image}) : super(key: key);

  // Set wallpaper function using flutter_wallpaper_manager
  Future<void> setWallpaper(int location) async {
    try {
      // Since we're working with image bytes, save the image temporarily
      final file = await _saveImageToTempFile(
        image,
      );
      final bool result =
          await WallpaperManager.setWallpaperFromFile(file.path, location);

      if (result) {
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Failed to set wallpaper.')),
        // );
      }
    } on PlatformException {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Error setting wallpaper.')),
      // );
    }
  }

  // Helper function to save image bytes to a temporary file
  Future<File> _saveImageToTempFile(Uint8List imageBytes) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_image.jpg');
    await tempFile.writeAsBytes(imageBytes);
    return tempFile;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cropped Image'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Image.memory(image),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show bottom sheet to select wallpaper location
          showModalBottomSheet(
            backgroundColor: Colors.white,
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: size.height * 0.3,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home),
                      title: const Text('Home Screen'),
                      onTap: () async {
                        Navigator.pop(context);
                        await setWallpaper(WallpaperManager.HOME_SCREEN);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Lock Screen'),
                      onTap: () async {
                        Navigator.pop(context);
                        await setWallpaper(WallpaperManager.LOCK_SCREEN);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.smartphone),
                      title: const Text('Both'),
                      onTap: () async {
                        Navigator.pop(context);
                        await setWallpaper(WallpaperManager.BOTH_SCREEN);
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
