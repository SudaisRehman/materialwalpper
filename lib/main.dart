// import 'package:ad_gridview/ad_gridview.dart';
// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const Homepage(),
//     );
//   }
// }

// class Homepage extends StatefulWidget {
//   const Homepage({super.key});

//   @override
//   State<Homepage> createState() => _HomepageState();
// }

// class _HomepageState extends State<Homepage> {
//   List list = [
//     1,
//     2,
//     3,
//     4,
//     5,
//     6,
//     7,
//     8,
//     9,
//     10,
//     11,
//     12,
//     13,
//     14,
//     15,
//     16,
//     17,
//     18,
//     19,
//     20,
//     21,
//     22,
//     23,
//     24,
//     25,
//     26,
//     27,
//     28,
//     29,
//     30
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("AdGridView Homepage")),
//       body: AdGridView(
//         crossAxisCount: 4,
//         itemCount: list.length,
//         adIndex: 2,
//         itemMainAspectRatio: 1 / 1,
//         adWidget: Container(
//           height: 150,
//           margin: const EdgeInsets.symmetric(horizontal: 5),
//           color: Colors.blue,
//           child: const Center(
//               child: Text(
//             "Native Ad",
//             style: TextStyle(fontSize: 60),
//           )),
//         ),
//         itemWidget: (context, index) {
//           return Container(
//             height: 150,
//             width: 160,
//             margin: const EdgeInsets.all(5),
//             color: Colors.grey,
//             child: Center(
//               child: Text(
//                 "${list[index]}",
//                 style: const TextStyle(fontSize: 30),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:materialwalpper/Provider/AppProvider.dart';
import 'package:materialwalpper/Provider/FavoriteProvider.dart';
import 'package:materialwalpper/Screens/SplashScreen/SplashScreen.dart';
// import 'package:your_app_name/home_screen.dart'; // Replace with your actual home screen
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
// bool _hasAdBeenShown = false;

void loadAds() async {
  print('Loading app open ad...');
  // var connectivityResult = await Connectivity().checkConnectivity();
  // if (connectivityResult == ConnectivityResult.none) {
  //   print('No internet connection, cannot load ads');
  //   return;
  // }

  AppOpenAd.load(
    adUnitId:
        'ca-app-pub-3940256099942544/9257395921', // Replace with your ad unit ID
    request: const AdRequest(),
    adLoadCallback: AppOpenAdLoadCallback(
      onAdLoaded: (ad) {
        _appOpenAd = ad;
        // if (!_hasAdBeenShown) {
        showAppOpenAd(); // Show the ad only if it hasn't been shown yet
        // }
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
    // return; // Return if ad is already showing or has been shown before
    // }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        // _hasAdBeenShown = true; // Mark the ad as shown
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
    // final adProvider = Provider.of<RemoteConfigProvider>(context, listen: false);

    // Load ads if splashInterstitial is enabled
    // if (adProvider.splashInterstitial) {
    //   loadAds();
    // }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // final adProvider = Provider.of<RemoteConfigProvider>(context, listen: false);
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
// import 'dart:async';
// import 'dart:io';

// import 'package:easy_ads_flutter/easy_ads_flutter.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// const IAdIdManager adIdManager = TestAdIdManager();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await ConsentManager.gatherGdprConsent(
//       debugGeography: kDebugMode ? DebugGeography.debugGeographyEea : null);
//   await ConsentManager.gatherPrivacyConsent();

//   await EasyAds.instance.initialize(
//     isShowAppOpenOnAppStateChange: false,
//     adIdManager,
//     unityTestMode: true,
//     adMobAdRequest: const AdRequest(),
//     admobConfiguration: RequestConfiguration(testDeviceIds: []),
//     fbTestingId: '73f92d66-f8f6-4978-999f-b5e0dd62275a',
//     fbTestMode: true,
//     showAdBadge: Platform.isIOS,
//     fbiOSAdvertiserTrackingEnabled: true,
//   );

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       title: 'Flutter Easy Ads Example',
//       home: CountryListScreen(),
//     );
//   }
// }

// class CountryListScreen extends StatefulWidget {
//   const CountryListScreen({Key? key}) : super(key: key);

//   @override
//   State<CountryListScreen> createState() => _CountryListScreenState();
// }

// class _CountryListScreenState extends State<CountryListScreen> {
//   /// Using it to cancel the subscribed callbacks
//   StreamSubscription? _streamSubscription;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Ad Network List"),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Text(
//                 'AppOpen',
//                 style: Theme.of(context)
//                     .textTheme
//                     .headlineMedium!
//                     .copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
//               ),
//               AdButton(
//                 networkName: 'Admob AppOpen',
//                 onTap: () => _showAd(AdNetwork.admob, AdUnitType.appOpen),
//               ),
//               const Divider(thickness: 2),
//               Text(
//                 'Interstitial',
//                 style: Theme.of(context)
//                     .textTheme
//                     .headlineMedium!
//                     .copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
//               ),
//               AdButton(
//                 networkName: 'Admob Interstitial',
//                 onTap: () => _showAd(AdNetwork.admob, AdUnitType.interstitial),
//               ),
//               AdButton(
//                 networkName: 'Facebook Interstitial',
//                 onTap: () =>
//                     _showAd(AdNetwork.facebook, AdUnitType.interstitial),
//               ),
//               AdButton(
//                 networkName: 'Unity Interstitial',
//                 onTap: () => _showAd(AdNetwork.unity, AdUnitType.interstitial),
//               ),
//               AdButton(
//                 networkName: 'Applovin Interstitial',
//                 onTap: () =>
//                     _showAd(AdNetwork.appLovin, AdUnitType.interstitial),
//               ),
//               AdButton(
//                 networkName: 'Available Interstitial',
//                 onTap: () => _showAvailableAd(AdUnitType.interstitial),
//               ),
//               const Divider(thickness: 2),
//               Text(
//                 'Rewarded',
//                 style: Theme.of(context)
//                     .textTheme
//                     .headlineMedium!
//                     .copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
//               ),
//               AdButton(
//                 networkName: 'Admob Rewarded',
//                 onTap: () => _showAd(AdNetwork.admob, AdUnitType.rewarded),
//               ),
//               AdButton(
//                 networkName: 'Facebook Rewarded',
//                 onTap: () => _showAd(AdNetwork.facebook, AdUnitType.rewarded),
//               ),
//               AdButton(
//                 networkName: 'Unity Rewarded',
//                 onTap: () => _showAd(AdNetwork.unity, AdUnitType.rewarded),
//               ),
//               AdButton(
//                 networkName: 'Applovin Rewarded',
//                 onTap: () => _showAd(AdNetwork.appLovin, AdUnitType.rewarded),
//               ),
//               AdButton(
//                 networkName: 'Available Rewarded',
//                 onTap: () => _showAvailableAd(AdUnitType.rewarded),
//               ),
//               const EasySmartBannerAd(
//                 priorityAdNetworks: [
//                   AdNetwork.facebook,
//                   AdNetwork.admob,
//                   AdNetwork.unity,
//                   AdNetwork.appLovin,
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showAd(AdNetwork adNetwork, AdUnitType adUnitType) {
//     if (EasyAds.instance.showAd(
//       adUnitType,
//       adNetwork: adNetwork,
//       context: context,
//       loaderDuration: 1,
//     )) {
//       // Canceling the last callback subscribed
//       _streamSubscription?.cancel();
//       // Listening to the callback from showRewardedAd()
//       _streamSubscription = EasyAds.instance.onEvent.listen((event) {
//         if (event.adUnitType == adUnitType) {
//           _streamSubscription?.cancel();
//           goToNextScreen(adNetwork: adNetwork);
//         }
//       });
//     } else {
//       goToNextScreen(adNetwork: adNetwork);
//     }
//   }

//   void _showAvailableAd(AdUnitType adUnitType) {
//     if (EasyAds.instance.showAd(adUnitType)) {
//       // Canceling the last callback subscribed
//       _streamSubscription?.cancel();
//       // Listening to the callback from showRewardedAd()
//       _streamSubscription = EasyAds.instance.onEvent.listen((event) {
//         if (event.adUnitType == adUnitType) {
//           _streamSubscription?.cancel();
//           goToNextScreen();
//         }
//       });
//     } else {
//       goToNextScreen();
//     }
//   }

//   void goToNextScreen({AdNetwork? adNetwork}) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => CountryDetailScreen(adNetwork: adNetwork),
//       ),
//     );
//   }
// }

// class CountryDetailScreen extends StatefulWidget {
//   final AdNetwork? adNetwork;
//   const CountryDetailScreen({Key? key, this.adNetwork}) : super(key: key);

//   @override
//   State<CountryDetailScreen> createState() => _CountryDetailScreenState();
// }

// class _CountryDetailScreenState extends State<CountryDetailScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('United States'),
//         centerTitle: true,
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Container(
//             height: 200,
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: NetworkImage(
//                     'https://cdn.britannica.com/33/4833-050-F6E415FE/Flag-United-States-of-America.jpg'),
//               ),
//             ),
//           ),
//           (widget.adNetwork == null)
//               ? const EasySmartBannerAd()
//               : EasyBannerAd(
//                   adNetwork: widget.adNetwork!,
//                   adSize: AdSize.largeBanner,
//                 ),
//           const Expanded(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: EdgeInsets.all(20.0),
//                 child: Text(
//                   'The U.S. is a country of 50 states covering a vast swath of North America, with Alaska in the northwest and Hawaii extending the nation’s presence into the Pacific Ocean. Major Atlantic Coast cities are New York, a global finance and culture center, and capital Washington, DC. Midwestern metropolis Chicago is known for influential architecture and on the west coast, Los Angeles\' Hollywood is famed for filmmaking',
//                   style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class AdButton extends StatelessWidget {
//   final String networkName;
//   final VoidCallback onTap;
//   const AdButton({Key? key, required this.onTap, required this.networkName})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text(
//             networkName,
//             style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w300),
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'dart:async';

// import 'package:flutter/services.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   String _platformVersion = 'Unknown';
//   String __heightWidth = "Unknown";
//   @override
//   void initState() {
//     super.initState();
//     initAppState();
//   }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initAppState() async {
//     String platformVersion;
//     String _heightWidth;
//     // Platform messages may fail, so we use a try/catch PlatformException.
//     // We also handle the message potentially returning null.
//     try {
//       platformVersion =
//           await WallpaperManager.platformVersion ?? 'Unknown platform version';
//     } on PlatformException {
//       platformVersion = 'Failed to get platform version.';
//     }

//     try {
//       int height = await WallpaperManager.getDesiredMinimumHeight();
//       int width = await WallpaperManager.getDesiredMinimumWidth();
//       _heightWidth =
//           "Width = " + width.toString() + " Height = " + height.toString();
//     } on PlatformException {
//       platformVersion = 'Failed to get platform version.';
//       _heightWidth = "Failed to get Height and Width";
//     }

//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;

//     setState(() {
//       __heightWidth = _heightWidth;
//       _platformVersion = platformVersion;
//     });
//   }

//   Future<void> setWallpaper() async {
//     try {
//       String url = "https://picsum.photos/1080/1920";
//       int location = WallpaperManager
//           .BOTH_SCREEN; // or location = WallpaperManager.LOCK_SCREEN;
//       var file = await DefaultCacheManager().getSingleFile(url);
//       final bool result =
//           await WallpaperManager.setWallpaperFromFile(file.path, location);
//       print(result);
//     } on PlatformException {}
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Plugin example app'),
//         ),
//         body: Center(
//             child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text('Running on: $_platformVersion\n'),
//             SizedBox(
//               height: 10,
//             ),
//             Text('$__heightWidth\n'),
//             SizedBox(
//               height: 10,
//             ),
//             TextButton(
//                 onPressed: () => {setWallpaper()},
//                 child: Text("Set Random Wallpaper")),
//             SizedBox(
//               height: 10,
//             ),
//             TextButton(
//                 onPressed: () => {(WallpaperManager.clearWallpaper())},
//                 child: Text("Clear Wallpaper"))
//           ],
//         )),
//       ),
//     );
//   }
// }
