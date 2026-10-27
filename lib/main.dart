
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

  String _selectedMode = 'tone';
  String _status = 'Ready to clean your speaker';
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;

      setState(() {
        _isPlaying = false;
        _status = 'Cleaning session completed';
      });
    });

    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;

      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
  }

  Future<void> _startCleaning() async {
    if (_isPlaying) return;

    final String asset = _selectedMode == 'tone'
        ? 'audio/tone_165.wav'
        : 'audio/sweep.wav';

    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.stop);

      if (!mounted) return;

      setState(() {
        _isPlaying = true;
        _status = _selectedMode == 'tone'
            ? 'Playing Speaker Tone...'
            : 'Playing Frequency Sweep...';
      });

      await _player.play(AssetSource(asset));
    } catch (error) {
      debugPrint('Audio playback error: $error');

      if (!mounted) return;

      setState(() {
        _isPlaying = false;
        _status = 'Audio error. Check audio files.';
      });
    }
  }

  Future<void> _stopCleaning() async {
    try {
      await _player.stop();
    } catch (error) {
      debugPrint('Stop error: $error');
    }

    if (!mounted) return;

    setState(() {
      _isPlaying = false;
      _status = 'Cleaning stopped';
    });
  }

  @override
  void dispose() {
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
                      'Use moderate volume and keep the phone away '
                      'from your ears. Cleaning tones cannot guarantee '
                      'removal of water or dust.',
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
    final bool selected = _selectedMode == mode;

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
