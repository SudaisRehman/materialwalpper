import 'package:flutter/material.dart';
import 'package:materialwalpper/Provider/AppProvider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    bool isDarkTheme = appProvider.isDarkTheme;

    return Scaffold(
      backgroundColor:
          isDarkTheme ? Colors.black : Colors.white, // Background color
      appBar: AppBar(
        title: const Text('Settings'),
        leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back)),
        backgroundColor:
            isDarkTheme ? Colors.black : Colors.white, // AppBar color
        foregroundColor:
            isDarkTheme ? Colors.white : Colors.black, // Text color
        elevation: 1,
      ),
      body: ListView(
        children: [
          // Dark Theme Toggle
          SwitchListTile(
            title: const Text('Dark Theme'),
            subtitle: const Text('Better for eyesight & battery life'),
            value: appProvider.isDarkTheme,
            onChanged: (bool value) {
              appProvider.toggleTheme(value);
            },
            activeColor: Colors.green,
          ),
          const Divider(),

          // Wallpaper Display Columns
          ListTile(
            title: Text(
              'Display Wallpaper',
              style: TextStyle(
                  fontSize: 16,
                  color:
                      isDarkTheme ? Colors.white : Colors.black, // Text color
                  fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${appProvider.displayWallpaperColumns} Columns',
              style: TextStyle(
                color: isDarkTheme
                    ? Colors.white70
                    : Colors.black54, // Subtitle color
              ),
            ),
            onTap: () {
              _showColumnSelectionDialog(context);
            },
          ),
          const Divider(),

          // Display Category (List/Grid)
          ListTile(
            title: Text(
              'Display Category',
              style: TextStyle(
                  fontSize: 16,
                  color:
                      isDarkTheme ? Colors.white : Colors.black, // Text color
                  fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              appProvider.displayCategory,
              style: TextStyle(
                color: isDarkTheme
                    ? Colors.white70
                    : Colors.black54, // Subtitle color
              ),
            ),
            onTap: () {
              _showCategorySelectionDialog(context);
            },
          ),
          const Divider(),

          // Clear Cache
          ListTile(
            title: Text(
              'Clear Cache',
              style: TextStyle(
                  fontSize: 16,
                  color:
                      isDarkTheme ? Colors.white : Colors.black, // Text color
                  fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('Free up space'),
            onTap: () {
              appProvider.clearCache();
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Cache cleared')));
            },
          ),
          const Divider(),

          // Clear Search History
          ListTile(
            title: Text(
              'Clear Search History',
              style: TextStyle(
                  fontSize: 16,
                  color:
                      isDarkTheme ? Colors.white : Colors.black, // Text color
                  fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('Remove searches you have performed'),
            onTap: () {
              appProvider.clearSearchHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search history cleared')));
            },
          ),
          const Divider(),

          // Wallpaper Save Location
          ListTile(
            title: Text(
              'Wallpaper Saved To',
              style: TextStyle(
                  fontSize: 16,
                  color:
                      isDarkTheme ? Colors.white : Colors.black, // Text color
                  fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('To Gallery'),
          ),
          const Divider(),

          // Copyright Information
          ListTile(
            title: Text(
              'Copyright Information',
              style: TextStyle(
                  fontSize: 16,
                  color:
                      isDarkTheme ? Colors.white : Colors.black, // Text color
                  fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'All wallpapers that are available in the App are free and '
              'its credit goes to their respective owners. These wallpapers '
              'are licensed under the Creative Commons Zero (CC0) license. '
              'Please contact us if you find any wallpaper that violates any rules, '
              'and we will remove the wallpaper.',
              style: TextStyle(
                color: isDarkTheme
                    ? Colors.white70
                    : Colors.black54, // Subtitle color
              ),
            ),
          ),
          const Divider(),

          // Privacy Policy
          ListTile(
            title: Text(
              'Privacy Policy',
              style: TextStyle(
                  fontSize: 16,
                  color:
                      isDarkTheme ? Colors.white : Colors.black, // Text color
                  fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('App Terms & Policies'),
            onTap: () {
              // Add navigation to privacy policy
            },
          ),
          const Divider(),

          // Rate Us
          ListTile(
            title: Text(
              'Rate Us',
              style: TextStyle(
                  fontSize: 16,
                  color:
                      isDarkTheme ? Colors.white : Colors.black, // Text color
                  fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('Give your rating and review for the app'),
            onTap: () {
              // Add logic for rating the app
            },
          ),
          const Divider(),

          // Share
          ListTile(
            title: Text(
              'Share',
              style: TextStyle(
                  fontSize: 16,
                  color:
                      isDarkTheme ? Colors.white : Colors.black, // Text color
                  fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('Share to your friends'),
            onTap: () {
              // Add share logic here
            },
          ),
          const Divider(),

          // More Apps
          ListTile(
            title: Text(
              'More Apps',
              style: TextStyle(
                  fontSize: 16,
                  color:
                      isDarkTheme ? Colors.white : Colors.black, // Text color
                  fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('Discover our other apps for you'),
            onTap: () {
              // Add navigation to more apps
            },
          ),
          const Divider(),

          // About
          ListTile(
            title: Text(
              'About',
              style: TextStyle(
                  fontSize: 16,
                  color:
                      isDarkTheme ? Colors.white : Colors.black, // Text color
                  fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('App info & build version'),
            onTap: () {
              // Add logic to display app info
            },
          ),
        ],
      ),
    );
  }

  void _showColumnSelectionDialog(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Column Count'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [2, 3]
                .map((e) => RadioListTile<int>(
                      title: Text('$e Columns'),
                      value: e,
                      groupValue: appProvider.displayWallpaperColumns,
                      onChanged: (value) {
                        appProvider.setWallpaperColumns(value!);
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  void _showCategorySelectionDialog(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Display Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['List', 'Grid']
                .map((e) => RadioListTile<String>(
                      title: Text(e),
                      value: e,
                      groupValue: appProvider.displayCategory,
                      onChanged: (value) {
                        appProvider.setDisplayCategory(value!);
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}
