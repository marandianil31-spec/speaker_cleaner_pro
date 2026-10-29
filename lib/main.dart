
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const SpeakerCleanerApp());
}

const bg = Color(0xFF081116);
const panel = Color(0xFF122128);
const teal = Color(0xFF00D6B2);
const muted = Color(0xFF91A5AB);

class SpeakerCleanerApp extends StatelessWidget {
  const SpeakerCleanerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speaker Cleaner Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: teal,
          brightness: Brightness.dark,
        ),
      ),
      home: const CleanerHome(),
    );
  }
}

class CleanerHome extends StatefulWidget {
  const CleanerHome({super.key});

  @override
  State<CleanerHome> createState() => _CleanerHomeState();
}

class _CleanerHomeState extends State<CleanerHome> {
  final AudioPlayer _player = AudioPlayer();

  bool _playing = false;
  bool _showFrequencies = false;
  String _status = 'Your speaker is ready';
  String _activeTool = '';
  double _volume = 0.25;

  final List<int> _frequencies = [
    60, 80, 100, 165, 250, 500, 1000, 2000, 4000,
  ];

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _playing = false;
        _status = 'Test completed';
      });
    });
  }

  Future<void> _play(String file, String tool) async {
    try {
      await _player.stop();
      await _player.setVolume(_volume);
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('audio/$file'));

      if (!mounted) return;
      setState(() {
        _playing = true;
        _activeTool = tool;
        _status = '$tool is running';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _playing = false;
        _status = 'Audio unavailable. Check audio assets.';
      });
    }
  }

  Future<void> _stop() async {
    await _player.stop();
    if (!mounted) return;
    setState(() {
      _playing = false;
      _activeTool = '';
      _status = 'Cleaning stopped';
    });
  }

  Future<void> _setVolume(double value) async {
    setState(() => _volume = value);
    await _player.setVolume(value);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Widget _toolCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    return Material(
      color: highlighted ? const Color(0xFF153C37) : panel,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: highlighted
                  ? teal.withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: teal.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: teal, size: 24),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: muted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heading(String title, String caption) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: const TextStyle(color: muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.speaker_group_rounded,
                    color: teal,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Speaker Cleaner',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'PRO  •  AUDIO TOOLS',
                        style: TextStyle(
                          color: muted,
                          fontSize: 10,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Speaker Cleaner Pro',
                      applicationVersion: '1.0.0',
                      children: const [
                        Text(
                          'Audio tools for speaker care and sound testing.',
                        ),
                      ],
                    );
                  },
                  icon: const Icon(Icons.info_outline_rounded),
                  color: muted,
                ),
              ],
            ),

            const SizedBox(height: 28),

            Container(
              padding: const EdgeInsets.fromLTRB(20, 23, 20, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF173B39),
                    Color(0xFF10232B),
                    Color(0xFF101B23),
                  ],
                ),
                border: Border.all(
                  color: teal.withValues(alpha: 0.20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: teal.withValues(alpha: 0.08),
                      border: Border.all(
                        color: teal.withValues(alpha: 0.32),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _playing
                          ? Icons.graphic_eq_rounded
                          : Icons.speaker_rounded,
                      size: 53,
                      color: teal,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _playing ? 'CLEANING IN PROGRESS' : 'SPEAKER CARE',
                    style: const TextStyle(
                      fontSize: 11,
                      color: teal,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    _playing ? _activeTool : 'Give your speaker a check',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: teal,
                        foregroundColor: const Color(0xFF06201D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _playing
                          ? _stop
                          : () => _play('tone_165.wav', 'Cleaning Tone'),
                      icon: Icon(
                        _playing
                            ? Icons.stop_rounded
                            : Icons.water_drop_outlined,
                      ),
                      label: Text(
                        _playing ? 'STOP CLEANING' : 'START CLEANING',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _heading('Cleaning Tools', 'Choose a tool for your speaker'),

            _toolCard(
              icon: Icons.water_drop_outlined,
              title: 'Water Eject',
              subtitle: 'Play a tone to help dislodge moisture',
              onTap: () => _play('sweep.wav', 'Water Eject'),
            ),
            const SizedBox(height: 10),
            _toolCard(
              icon: Icons.cleaning_services_outlined,
              title: 'Dust Removal',
              subtitle: 'Use a sound tone for speaker care',
              onTap: () => _play('tone_165.wav', 'Dust Removal'),
            ),
            const SizedBox(height: 10),
            _toolCard(
              icon: Icons.verified_outlined,
              title: 'Speaker Test',
              subtitle: 'Check sound output with a test tone',
              onTap: () => _play('sweep.wav', 'Speaker Test'),
            ),

            _heading('Sound Settings', 'Adjust the test volume safely'),

            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.volume_down_rounded,
                        color: teal,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Test Volume',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        '${(_volume * 100).round()}%',
                        style: const TextStyle(
                          color: teal,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _volume,
                    min: 0.05,
                    max: 0.5,
                    divisions: 9,
                    activeColor: teal,
                    onChanged: _setVolume,
                  ),
                  const Text(
                    'Begin at low volume. Increase gradually.',
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),
            ),

            _heading(
              'Frequency Test',
              'For checking different sound ranges',
            ),

            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: teal,
                side: BorderSide(
                  color: teal.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                setState(() {
                  _showFrequencies = !_showFrequencies;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.tune_rounded),
                  const SizedBox(width: 8),
                  Text(
                    _showFrequencies
                        ? 'HIDE FREQUENCIES'
                        : 'EXPLORE FREQUENCIES',
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    _showFrequencies
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),

            if (_showFrequencies) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: _frequencies.map((hz) {
                  final label =
                      hz >= 1000 ? '${hz ~/ 1000} kHz' : '$hz Hz';

                  return OutlinedButton(
                    onPressed: () =>
                        _play('tone_$hz.wav', '$label Frequency Test'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: teal,
                      side: BorderSide(
                        color: teal.withValues(alpha: 0.35),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(label),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 26),
            const Center(
              child: Text(
                'SPEAKER CLEANER PRO',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sound tones may help with minor moisture, but cannot guarantee removal of water or dust. Avoid high volume and stop if the speaker sounds distorted.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: muted,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
