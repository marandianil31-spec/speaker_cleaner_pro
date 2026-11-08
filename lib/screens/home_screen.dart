
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../widgets/app_header.dart';
import '../widgets/tool_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  // Real AdMob Home Banner ID
  static const String _bannerAdUnitId =
      'ca-app-pub-6724668039220554/1019946859';

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    final banner = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }

          setState(() {
            _bannerAd = ad as BannerAd;
            _isBannerLoaded = true;
          });

          debugPrint('Real Home Banner Ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            'Home Banner Ad failed: ${error.code} ${error.message}',
          );
          ad.dispose();
        },
      ),
    );

    banner.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                const AppHeader(),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Clean Your Speaker',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Remove water and dust from your phone speaker.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),

                ToolCard(
                  title: 'Water Eject',
                  subtitle: 'Remove water using sound waves',
                  icon: Icons.water_drop,
                  onTap: () =>
                      Navigator.pushNamed(context, '/water'),
                ),

                ToolCard(
                  title: 'Dust Removal',
                  subtitle: 'Clean speaker using sound vibration',
                  icon: Icons.air,
                  onTap: () =>
                      Navigator.pushNamed(context, '/dust'),
                ),

                ToolCard(
                  title: 'Speaker Test',
                  subtitle: 'Check your speaker sound',
                  icon: Icons.speaker,
                  onTap: () =>
                      Navigator.pushNamed(context, '/test'),
                ),

                ToolCard(
                  title: 'Frequency Generator',
                  subtitle: 'Play different sound frequencies',
                  icon: Icons.graphic_eq,
                  onTap: () =>
                      Navigator.pushNamed(context, '/frequency'),
                ),
              ],
            ),
          ),

          // Real AdMob Banner
          if (_isBannerLoaded && _bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              color: const Color(0xFF122128),
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }
}
