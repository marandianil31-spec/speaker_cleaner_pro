import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const SpeakerCleanerApp());
}

class SpeakerCleanerApp extends StatelessWidget {
  const SpeakerCleanerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Speaker Cleaner Pro',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF081116),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00D6B2),
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
  String _status = 'Choose a sound test';
  bool _playing = false;

  Future<void> _playTone(String file) async {
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('audio/$file'));
      if (!mounted) return;
      setState(() {
        _playing = true;
        _status = 'Playing: $file';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _playing = false;
        _status = 'Audio error. Check audio assets.';
      });
    }
  }

  Future<void> _stopTone() async {
    await _player.stop();
    if (!mounted) return;
    setState(() {
      _playing = false;
      _status = 'Sound stopped';
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Widget _soundButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      color: const Color(0xFF14242A),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF00D6B2), size: 30),
        title: Text(title, style: const TextStyle(
          fontWeight: FontWeight.bold,
        )),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.play_arrow),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speaker Cleaner Pro'),
        centerTitle: true,
        backgroundColor: const Color(0xFF081116),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const SizedBox(height: 18),
          const Icon(
            Icons.speaker,
            size: 90,
            color: Color(0xFF00D6B2),
          ),
          const SizedBox(height: 12),
          const Text(
            'SPEAKER CARE',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a test to get started',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _soundButton(
            'Speaker Cleaner',
            'Play the tone audio',
            Icons.water_drop,
            () => _playTone('tone_165.wav'),
          ),
          _soundButton(
            'Frequency Sweep',
            'Play the sweep audio',
            Icons.graphic_eq,
            () => _playTone('sweep.wav'),
          ),
          _soundButton(
            'Bass / Sound Test',
            'Test speaker output',
            Icons.speaker_group,
            () => _playTone('tone_165.wav'),
          ),
          const SizedBox(height: 18),
          Card(
            color: const Color(0xFF14242A),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(_status, textAlign: TextAlign.center),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _playing ? _stopTone : null,
                      icon: const Icon(Icons.stop),
                      label: const Text('STOP SOUND'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

