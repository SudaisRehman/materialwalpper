import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:materialwalpper/Provider/AppProvider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _privacyPolicy = "";
  bool _isLoading = true;
  String _more_apps_url = "";
  String _package_name = "";

  @override
  void initState() {
    super.initState();
    _fetchPrivacyPolicy();
  }

  Future<void> _fetchPrivacyPolicy() async {
    try {
      final response = await http.get(
          Uri.parse('https://gaming.sunztech.com/api/v1/api.php?get_settings'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _privacyPolicy = data['settings']['privacy_policy'] ??
              'Privacy policy not available.';
          _more_apps_url = data['settings']['more_apps_url'] ??
              'https://play.google.com/store/apps/developer?id=SunzTech';
          _package_name = data['settings']['package_name'] ??
              'com.sunztech.materialwallpaper';
          _isLoading = false;
        });
      } else {
        setState(() {
          _privacyPolicy = 'Failed to load privacy policy.';
          _more_apps_url = 'Failed to load more apps.';
          _package_name = 'com.app.materialwallpaper';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _privacyPolicy = 'An error occurred: $error';
        _more_apps_url = 'An error occurred: $error';
        _package_name = 'com.app.materialwallpaper';
        _isLoading = false;
      });
    }
  }

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

            // subtitle: const Text('Free up $mb space'),
            subtitle: FutureBuilder<int>(
              future: appProvider.getSharedPreferencesSize(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Calculating...');
                } else if (snapshot.hasError) {
                  return const Text('Error calculating cache size');
                } else {
                  final mb = (snapshot.data ?? 0) / (1024 * 1024);
                  final kb = (snapshot.data ?? 0) / 1024;
                  return Text('Free up ${kb.toStringAsFixed(2)} MB');
                }
              },
            ),
            onTap: () {
              appProvider.clearSharedPreferences();
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Cache cleared')));
            },
          ),
          // const Divider(),

          // // Clear Search History
          // ListTile(
          //   title: Text(
          //     'Clear Search History',
          //     style: TextStyle(
          //         fontSize: 16,
          //         color:
          //             isDarkTheme ? Colors.white : Colors.black, // Text color
          //         fontWeight: FontWeight.w500),
          //   ),
          //   subtitle: const Text('Remove searches you have performed'),
          //   onTap: () {
          //     appProvider.clearSearchHistory();
          //     ScaffoldMessenger.of(context).showSnackBar(
          //         const SnackBar(content: Text('Search history cleared')));
          //   },
          // ),
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
              //  final appProvider = Provider.of<AppProvider>(context, listen: false);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: appProvider.isDarkTheme
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    content: _isLoading
                        ? const CircularProgressIndicator()
                        : SingleChildScrollView(
                            child: Html(
                              data: _privacyPolicy, // Render HTML content
                              style: {
                                "body": Style(
                                  fontSize: FontSize(14.0),
                                  color: Colors.black87,
                                ),
                              },
                            ),
                          ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.green,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
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
              final String appUrl =
                  'https://play.google.com/store/apps/details?id=${_package_name}';
              launchUrl(Uri.parse(appUrl));
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
              final String appUrl =
                  'https://play.google.com/store/apps/details?id=${_package_name}';
              Share.share('Check out this amazing app: $appUrl');
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
            onTap: () async {
              print('More Apps URL: $_more_apps_url');
              Uri uri = Uri.parse(_more_apps_url);
              if (await canLaunchUrl(uri)) {
                print('Launching URL: $_more_apps_url');
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                print('Launched URL: $_more_apps_url');
              } else {
                throw 'Could not launch $_more_apps_url';
              }

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
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    actionsPadding: EdgeInsets.only(
                      right: 10,
                      bottom: 10,
                    ),
                    // title: Text(
                    //   'About',
                    //   style: TextStyle(
                    //     color: appProvider.isDarkTheme
                    //         ? Colors.white
                    //         : Colors.black,
                    //   ),
                    // ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Material Wallpaper',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: appProvider.isDarkTheme
                                  ? Colors.white
                                  : Colors.black,
                            )),
                        Text('Version 1.0.0',
                            style: TextStyle(
                              fontSize: 16,
                              color: appProvider.isDarkTheme
                                  ? Colors.grey
                                  : Colors.black54,
                            )),
                        Text(
                          'Copyright © 2022 BrainyBella ',
                          style: TextStyle(
                            fontSize: 16,
                            color: appProvider.isDarkTheme
                                ? Colors.grey
                                : Colors.black54,
                          ),
                        ),
                        Text(
                          'All rights reserved',
                          style: TextStyle(
                            fontSize: 16,
                            color: appProvider.isDarkTheme
                                ? Colors.grey
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.green,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
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
