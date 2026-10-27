
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ad initialization failure should not prevent Flutter startup.
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint('Ad initialization failed: $e');
  }

  runApp(const SpeakerCleanerApp());
}

class SpeakerCleanerApp extends StatelessWidget {
  const SpeakerCleanerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speaker Cleaner Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF081116),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00D6B2),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const CleanerHomePage(),
    );
  }
}

class CleanerHomePage extends StatefulWidget {
  const CleanerHomePage({super.key});

  @override
  State<CleanerHomePage> createState() => _CleanerHomePageState();
}

class _CleanerHomePageState extends State<CleanerHomePage> {
  final AudioPlayer _player = AudioPlayer();

  // Official Google test ad-unit IDs.
  static const String _bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  static const String _interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  bool _bannerReady = false;
  bool _isPlaying = false;
  bool _adsInitialized = false;

  String _selectedMode = 'tone';
  String _status = 'Ready to clean your speaker';

  DateTime? _lastInterstitialShown;

  @override
  void initState() {
    super.initState();

    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;

      setState(() {
        _isPlaying = false;
        _status = 'Cleaning session completed';
      });

      _showInterstitialIfAllowed();
    });

    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;

      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _initializeAds();
  }

  Future<void> _initializeAds() async {
    try {
      await MobileAds.instance.initialize();

      if (!mounted) return;
      _adsInitialized = true;

      _loadBannerAd();
      _loadInterstitialAd();
    } catch (e) {
      debugPrint('Ads unavailable: $e');
    }
  }

  void _loadBannerAd() {
    if (!_adsInitialized) return;

    final ad = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }

          setState(() {
            _bannerReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();

          if (!mounted) return;
          setState(() {
            _bannerReady = false;
          });

          debugPrint('Banner ad failed: $error');
        },
      ),
    );

    _bannerAd = ad;
    ad.load();
  }

  void _loadInterstitialAd() {
    if (!_adsInitialized) return;

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          debugPrint('Interstitial ad failed: $error');
        },
      ),
    );
  }

  void _showInterstitialIfAllowed() {
    final now = DateTime.now();

    if (_lastInterstitialShown != null &&
        now.difference(_lastInterstitialShown!) <
            const Duration(minutes: 3)) {
      return;
    }

    final ad = _interstitialAd;
    if (ad == null) return;

    _interstitialAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _lastInterstitialShown = DateTime.now();
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial display failed: $error');
        ad.dispose();
        _loadInterstitialAd();
      },
    );

    ad.show();
  }

  Future<void> _startCleaning() async {
    if (_isPlaying) return;

    final asset = _selectedMode == 'tone'
        ? 'audio/tone_165.wav'
        : 'audio/sweep.wav';

    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.stop);

      if (!mounted) return;

      setState(() {
        _status = _selectedMode == 'tone'
            ? 'Playing Speaker Tone...'
            : 'Playing Frequency Sweep...';
        _isPlaying = true;
      });

      await _player.play(AssetSource(asset));
    } catch (e) {
      debugPrint('Audio playback failed: $e');

      if (!mounted) return;

      setState(() {
        _isPlaying = false;
        _status = 'Audio error. Please try again.';
      });
    }
  }

  Future<void> _stopCleaning() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('Audio stop failed: $e');
    }

    if (!mounted) return;

    setState(() {
      _isPlaying = false;
      _status = 'Cleaning stopped';
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.graphic_eq_rounded,
                          size: 34,
                          color: Color(0xFF00D6B2),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Speaker Cleaner Pro',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF123B40),
                            Color(0xFF10252D),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: const Color(0xFF00D6B2)
                              .withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _isPlaying
                                ? Icons.graphic_eq_rounded
                                : Icons.speaker_rounded,
                            size: 86,
                            color: const Color(0xFF00D6B2),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _isPlaying
                                ? 'Cleaning in Progress'
                                : 'Clean Your Speaker',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _status,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Choose Cleaning Mode',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _modeCard(
                      title: 'Speaker Tone',
                      subtitle: '165 Hz • 8 seconds',
                      icon: Icons.waves_rounded,
                      mode: 'tone',
                    ),
                    const SizedBox(height: 12),
                    _modeCard(
                      title: 'Frequency Sweep',
                      subtitle: '120–600 Hz • 12 seconds',
                      icon: Icons.multitrack_audio_rounded,
                      mode: 'sweep',
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isPlaying ? _stopCleaning : _startCleaning,
                        icon: Icon(
                          _isPlaying
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                          size: 28,
                        ),
                        label: Text(
                          _isPlaying ? 'STOP CLEANING' : 'START CLEANING',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.7,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D6B2),
                          foregroundColor: const Color(0xFF081116),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Tip: Keep your phone speaker facing downward. '
                      'Use moderate volume and keep the phone away '
                      'from your ears.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_bannerReady && _bannerAd != null)
              SizedBox(
                width: double.infinity,
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _modeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String mode,
  }) {
    final selected = _selectedMode == mode;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: _isPlaying
          ? null
          : () {
              setState(() {
                _selectedMode = mode;
                _status = 'Ready to clean your speaker';
              });
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF123B40)
              : const Color(0xFF111E25),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? const Color(0xFF00D6B2)
                : Colors.white12,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30,
              color: const Color(0xFF00D6B2),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected
                  ? const Color(0xFF00D6B2)
                  : Colors.white38,
            ),
          ],
        ),
      ),
    );
  }
}
