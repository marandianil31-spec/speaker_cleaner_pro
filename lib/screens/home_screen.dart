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

  // Google official test banner ID
  static const String _bannerId =
      'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    final ad = BannerAd(
      adUnitId: _bannerId,
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
        },

        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner Ad Error: $error');
          ad.dispose();

          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isBannerLoaded = false;
            });
          }
        },
      ),
    );

    _bannerAd = ad;
    ad.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            onTap: () => Navigator.pushNamed(context, '/water'),
          ),

          ToolCard(
            title: 'Dust Removal',
            subtitle: 'Clean speaker using sound vibration',
            icon: Icons.air,
            onTap: () => Navigator.pushNamed(context, '/dust'),
          ),

          ToolCard(
            title: 'Speaker Test',
            subtitle: 'Check your speaker sound',
            icon: Icons.speaker,
            onTap: () => Navigator.pushNamed(context, '/test'),
          ),

          ToolCard(
            title: 'Frequency Generator',
            subtitle: 'Play different sound frequencies',
            icon: Icons.graphic_eq,
            onTap: () => Navigator.pushNamed(context, '/frequency'),
          ),

          // Banner Ad
          if (_isBannerLoaded && _bannerAd != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              child: Center(
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

