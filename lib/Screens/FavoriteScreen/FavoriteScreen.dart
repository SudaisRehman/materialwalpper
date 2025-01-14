import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:materialwalpper/Provider/FavoriteProvider.dart';
import 'package:materialwalpper/Screens/WallpaperScreen/WallpaperDetailsScreen.dart';
// import 'package:materialwalpper/wallpaper_detail.dart';
import 'package:provider/provider.dart'; // Import for Provider

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
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
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio:
                    0.7, // Adjust to fit the wallpaper aspect ratio
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
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
                    print('index: $index');
                    // Optional: Navigate to a detailed wallpaper view if needed
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WallpaperDetailsScreen(
                                  wallpapers: favorites,
                                  initialIndex: index,
                                )));
                  },
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
                              favoriteProvider.removeFavorite(wallpaper['id']);
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
                );
              },
            ),
    );
  }
}
