import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/audio_service.dart';

class SpeakerTestScreen extends StatefulWidget {
  const SpeakerTestScreen({super.key});

  @override
  State<SpeakerTestScreen> createState() =>
      _SpeakerTestScreenState();
}

class _SpeakerTestScreenState extends State<SpeakerTestScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController animationController;

  double volume = 0.7;
  int? selectedFrequency;
  String currentTest = 'Ready to Test';
  bool isPlaying = false;

  final List<int> frequencies = [
    60, 80, 100, 165, 250, 500, 1000, 2000, 4000
  ];

  // ADMOB BANNER

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  static const String _bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

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

          debugPrint('Speaker Test Banner Loaded');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Speaker Test Banner Error: $error');
        },
      ),
    );

    banner.load();
  }

  // PLAY TEST

  Future<void> playTest(
    String fileName,
    String testName, {
    int? frequency,
  }) async {
    try {
      await AudioService.instance.stopAudio();

      await AudioService.instance.setVolume(volume);

      await AudioService.instance.playAudio(fileName);

      if (!mounted) return;

      setState(() {
        currentTest = testName;
        selectedFrequency = frequency;
        isPlaying = true;
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

  // STOP TEST

  Future<void> stopTest() async {
    await AudioService.instance.stopAudio();

    if (!mounted) return;

    setState(() {
      isPlaying = false;
      selectedFrequency = null;
      currentTest = 'Ready to Test';
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    _bannerAd?.dispose();
    AudioService.instance.stopAudio();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speaker Test'),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                'AUDIO TESTING CENTER',
                style: TextStyle(
                  color: Color(0xFF00D6B2),
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Test Your Speaker',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              // ANIMATED SPEAKER

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),

                decoration: BoxDecoration(
                  color: const Color(0xFF122128),
                  borderRadius: BorderRadius.circular(22),
                ),

                child: Column(
                  children: [

                    AnimatedBuilder(
                      animation: animationController,

                      builder: (context, child) {
                        final scale = isPlaying
                            ? 1 + animationController.value * 0.12
                            : 1.0;

                        return Transform.scale(
                          scale: scale,
                          child: Icon(
                            Icons.speaker,
                            size: 105,
                            color: isPlaying
                                ? const Color(0xFF00D6B2)
                                : Colors.white54,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 15),

                    Text(
                      currentTest,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      isPlaying
                          ? 'Audio Playing'
                          : 'Ready to Test',
                      style: const TextStyle(
                        color: Colors.white54,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,

                      child: ElevatedButton.icon(
                        onPressed: stopTest,
                        icon: const Icon(Icons.stop),
                        label: const Text('STOP TEST'),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // SPEAKER CHANNEL TEST

              const Text(
                'Speaker Channel Test',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: channelButton(
                      'Left Test',
                      Icons.volume_down,
                      'sweep.wav',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: channelButton(
                      'Right Test',
                      Icons.volume_up,
                      'sweep.wav',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: channelButton(
                  'Stereo / Full Test',
                  Icons.surround_sound,
                  'sweep.wav',
                ),
              ),

              const SizedBox(height: 28),

              // FREQUENCY TEST

              const Text(
                'Frequency Generator',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Choose a frequency to test your speaker.',
                style: TextStyle(color: Colors.white54),
              ),

              const SizedBox(height: 15),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),

                itemCount: frequencies.length,

                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                ),

                itemBuilder: (context, index) {
                  final frequency = frequencies[index];

                  final selected =
                      selectedFrequency == frequency;

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),

                    onTap: () {
                      playTest(
                        'tone_$frequency.wav',
                        '$frequency Hz Test',
                        frequency: frequency,
                      );
                    },

                    child: Container(
                      alignment: Alignment.center,

                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF00D6B2)
                                .withValues(alpha: 0.18)
                            : const Color(0xFF122128),

                        borderRadius: BorderRadius.circular(12),

                        border: Border.all(
                          color: selected
                              ? const Color(0xFF00D6B2)
                              : Colors.white12,
                        ),
                      ),

                      child: Text(
                        '$frequency Hz',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selected
                              ? const Color(0xFF00D6B2)
                              : Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              // VOLUME CONTROL

              const Text(
                'Test Volume',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Slider(
                value: volume,
                min: 0,
                max: 1,
                divisions: 10,
                activeColor: const Color(0xFF00D6B2),

                onChanged: (value) {
                  setState(() {
                    volume = value;
                  });

                  AudioService.instance.setVolume(value);
                },
              ),

              Center(
                child: Text(
                  '${(volume * 100).round()}%',
                  style: const TextStyle(
                    color: Color(0xFF00D6B2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Keep volume low during frequency testing. '
                'Avoid prolonged loud tones.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
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

  // CHANNEL BUTTON

  Widget channelButton(
    String title,
    IconData icon,
    String fileName,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        playTest(fileName, title);
      },

      icon: Icon(icon),
      label: Text(title),

      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF122128),
        foregroundColor: const Color(0xFF00D6B2),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}

