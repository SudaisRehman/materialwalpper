

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:materialwalpper/Provider/AppProvider.dart';
import 'package:materialwalpper/Provider/FavoriteProvider.dart';
import 'package:materialwalpper/Screens/SplashScreen/SplashScreen.dart';

import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  CachedNetworkImage.logLevel = CacheManagerLogLevel.debug;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => FavoriteProvider()..loadFavorites()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MyApp(),
    ),
  );
}

AppOpenAd? _appOpenAd;
bool _isShowingAd = false;


void loadAds() async {
  print('Loading app open ad...');
  

  AppOpenAd.load(
    adUnitId:
        'ca-app-pub-3940256099942544/9257395921', // Replace with your ad unit ID
    request: const AdRequest(),
    adLoadCallback: AppOpenAdLoadCallback(
      onAdLoaded: (ad) {
        _appOpenAd = ad;
      
        showAppOpenAd(); // Show the ad only if it hasn't been shown yet
        
      },
      onAdFailedToLoad: (error) {
        print('Failed to load app open ad: $error');
        Future.delayed(
            const Duration(seconds: 30), loadAds); // Retry after 30 seconds
      },
    ),
  );
}

void showAppOpenAd() {
  if (_appOpenAd == null) {
    
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
   
        ad.dispose();
        loadAds(); // Load a new ad after the current one is dismissed
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Failed to show app open ad: $error');
        _isShowingAd = false;
        ad.dispose();
        loadAds(); // Load a new ad if showing failed
      },
    );
  }
  _isShowingAd = true;
  _appOpenAd!.show();
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _wasInBackground = false; // Track if the app was in the background

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      _wasInBackground = true; // Set flag when the app goes to the background
    } else if (state == AppLifecycleState.resumed && _wasInBackground) {
      _wasInBackground =
          false; // Reset the flag when the app comes to the foreground

      loadAds(); // Load and show the ad only if it hasn't been shown yet
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Your App Name',
      theme: appProvider.isDarkTheme
          ? ThemeData.dark().copyWith(
              primaryColor: Colors.green,
              scaffoldBackgroundColor: Colors.black,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: Colors.white),
              ),
            )
          : ThemeData.light().copyWith(
              primaryColor: Colors.green,
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: Colors.black),
              ),
            ),
      home: SplashScreen(),
    );
  }
}
