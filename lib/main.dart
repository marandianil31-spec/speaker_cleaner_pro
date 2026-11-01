import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'screens/home_screen.dart';
import 'screens/cleaning_screen.dart';
import 'screens/speaker_test_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/frequency_screen.dart';
import 'screens/about_screen.dart';

const String topBannerAdId =
    'ca-app-pub-6724668039220554/2205955881';

const String homeBannerAdId =
    'ca-app-pub-6724668039220554/1019946859';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MobileAds.instance.initialize();

  runApp(const SpeakerCleanerApp());
}

class SpeakerCleanerApp extends StatelessWidget {
  const SpeakerCleanerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Speaker Cleaner Pro',

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF081116),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00D6B2),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => const MainScreen(),
        '/water': (context) => const CleaningScreen(),
        '/dust': (context) => const CleaningScreen(),
        '/test': (context) => const SpeakerTestScreen(),
        '/frequency': (context) => const FrequencyScreen(),
        '/about': (context) => const AboutScreen(),
      },
    );
  }
}

// REUSABLE BANNER AD
class AdBanner extends StatefulWidget {
  final String adUnitId;

  const AdBanner({
    super.key,
    required this.adUnitId,
  });

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? bannerAd;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    loadBanner();
  }

  void loadBanner() {
    final ad = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }

          setState(() {
            bannerAd = ad as BannerAd;
            isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();

          debugPrint('Banner Ad Error: $error');
        },
      ),
    );

    bannerAd = ad;
    ad.load();
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded || bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: bannerAd!.size.height.toDouble(),
      color: const Color(0xFF081116),
      child: AdWidget(ad: bannerAd!),
    );
  }
}

// MAIN SCREEN
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    CleaningScreen(),
    SpeakerTestScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isHome = selectedIndex == 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (isHome)
              const AdBanner(
                adUnitId: topBannerAdId,
              ),

            Expanded(
              child: IndexedStack(
                index: selectedIndex,
                children: screens,
              ),
            ),

            if (isHome)
              const AdBanner(
                adUnitId: homeBannerAdId,
              ),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        backgroundColor: const Color(0xFF122128),

        indicatorColor:
            const Color(0xFF00D6B2).withValues(alpha: 0.2),

        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.cleaning_services_outlined),
            label: 'Cleaning',
          ),

          NavigationDestination(
            icon: Icon(Icons.speaker_outlined),
            label: 'Test',
          ),

          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

