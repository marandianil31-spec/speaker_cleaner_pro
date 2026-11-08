
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/audio_service.dart';

class FrequencyScreen extends StatefulWidget {
  const FrequencyScreen({super.key});

  @override
  State<FrequencyScreen> createState() => _FrequencyScreenState();
}

class _FrequencyScreenState extends State<FrequencyScreen> {

  static const List<int> frequencies = [
    60, 80, 100, 165, 250, 500, 1000, 2000, 4000
  ];

  int? selectedFrequency;

  // ADMOB BANNER

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  static const String _bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  // LOAD BANNER AD

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
            _isBannerAdLoaded = true;
          });

          debugPrint('Frequency Banner Ad Loaded');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Frequency Banner Error: $error');
        },
      ),
    );

    banner.load();
  }

  // PLAY FREQUENCY

  Future<void> playFrequency(int frequency) async {
    try {
      await AudioService.instance.playAudio(
        'tone_$frequency.wav',
      );

      if (!mounted) return;

      setState(() {
        selectedFrequency = frequency;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio could not be played.'),
        ),
      );
    }
  }

  // STOP FREQUENCY

  Future<void> stopFrequency() async {
    await AudioService.instance.stopAudio();

    if (!mounted) return;

    setState(() {
      selectedFrequency = null;
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    AudioService.instance.stopAudio();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequency Generator'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            'Select Frequency',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          ...frequencies.map(
            (frequency) {
              final selected = selectedFrequency == frequency;

              return Card(
                color: const Color(0xFF122128),

                child: ListTile(
                  leading: Icon(
                    Icons.graphic_eq,
                    color: selected
                        ? Colors.greenAccent
                        : const Color(0xFF00D6B2),
                  ),

                  title: Text(
                    '$frequency Hz',
                    style: TextStyle(
                      color: selected
                          ? Colors.greenAccent
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  trailing: Icon(
                    selected
                        ? Icons.equalizer
                        : Icons.play_circle,
                    color: const Color(0xFF00D6B2),
                  ),

                  onTap: () {
                    playFrequency(frequency);
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: stopFrequency,
            icon: const Icon(Icons.stop),
            label: const Text('Stop Frequency'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),

      // BOTTOM BANNER AD

      bottomNavigationBar:
          _isBannerAdLoaded && _bannerAd != null
              ? SafeArea(
                  child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: Center(
                      child: AdWidget(ad: _bannerAd!),
                    ),
                  ),
                )
              : null,
    );
  }
}
