import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:materialwalpper/Screens/HomeScreen/HomeScreen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late InterstitialAd _interstitialAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeAds();
    // Delay for a few seconds before navigating to the next screen
    Future.delayed(Duration(seconds: 3), () {
      _showInterstitialAd();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  void _initializeAds() {
    // Initialize Google Mobile Ads SDK
    MobileAds.instance.initialize();

    // Load the interstitial ad
    InterstitialAd.load(
      adUnitId:
          'ca-app-pub-3940256099942544/1033173712', // Replace with your ad unit ID
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _interstitialAd = ad;
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (error) {
          print('Interstitial Ad failed to load: $error');
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_isAdLoaded) {
      _interstitialAd.show();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set full-screen immersive mode
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wallpaper,
              size: 150.0,
              color: Colors.green,
            ),
            SizedBox(height: 20.0),
            Text(
              'Your App Name',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 30.0),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
