
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

  String _status = 'Choose a frequency';
  String? _currentFile;
  bool _playing = false;
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
        _status = 'Playback finished';
      });
    });
  }

  Future<void> _playFile(String file, String label) async {
    try {
      await _player.stop();
      await _player.setVolume(_volume);
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('audio/$file'));

      if (!mounted) return;
      setState(() {
        _currentFile = file;
        _playing = true;
        _status = 'Playing $label';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _playing = false;
        _status = 'Could not play audio. Check assets.';
      });
    }
  }

  Future<void> _stopSound() async {
    try {
      await _player.stop();
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _playing = false;
      _status = 'Sound stopped';
    });
  }

  Future<void> _changeVolume(double value) async {
    setState(() => _volume = value);
    await _player.setVolume(value);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00D6B2)),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _toneButton(int hz) {
    final bool selected = _currentFile == 'tone_$hz.wav';

    return Card(
      color: selected
          ? const Color(0xFF15564D)
          : const Color(0xFF14242A),
      child: ListTile(
        leading: const Icon(
          Icons.graphic_eq,
          color: Color(0xFF00D6B2),
        ),
        title: Text(hz >= 1000 ? '${hz ~/ 1000} kHz' : '$hz Hz'),
        subtitle: Text('$hz Hz frequency tone'),
        trailing: Icon(
          selected && _playing ? Icons.volume_up : Icons.play_arrow,
          color: const Color(0xFF00D6B2),
        ),
        onTap: () => _playFile('tone_$hz.wav', '$hz Hz'),
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
          const SizedBox(height: 12),
          const Icon(
            Icons.speaker_group,
            size: 76,
            color: Color(0xFF00D6B2),
          ),
          const SizedBox(height: 10),
          const Text(
            'SPEAKER CARE',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Frequency generator and sound tests',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),

          _sectionTitle('Bass Test', Icons.speaker),
          _toneButton(60),
          _toneButton(80),
          _toneButton(100),

          _sectionTitle('Frequency Test', Icons.graphic_eq),
          ..._frequencies
              .where((hz) => hz >= 165)
              .map((hz) => _toneButton(hz)),

          _sectionTitle('Speaker Cleaner', Icons.water_drop),
          Card(
            color: const Color(0xFF14242A),
            child: ListTile(
              leading: const Icon(
                Icons.water_drop,
                color: Color(0xFF00D6B2),
              ),
              title: const Text('Cleaner Tone'),
              subtitle: const Text('165 Hz tone'),
              trailing: const Icon(Icons.play_arrow),
              onTap: () => _playFile(
                'tone_165.wav',
                'Cleaner Tone',
              ),
            ),
          ),

          _sectionTitle('Frequency Sweep', Icons.waves),
          Card(
            color: const Color(0xFF14242A),
            child: ListTile(
              leading: const Icon(
                Icons.waves,
                color: Color(0xFF00D6B2),
              ),
              title: const Text('Run Sweep'),
              subtitle: const Text('Changing frequency test'),
              trailing: const Icon(Icons.play_arrow),
              onTap: () => _playFile('sweep.wav', 'Frequency Sweep'),
            ),
          ),

          _sectionTitle('Volume Control', Icons.volume_down),
          Card(
            color: const Color(0xFF14242A),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Test volume'),
                      Text('${(_volume * 100).round()}%'),
                    ],
                  ),
                  Slider(
                    value: _volume,
                    min: 0.05,
                    max: 0.5,
                    divisions: 9,
                    activeColor: const Color(0xFF00D6B2),
                    onChanged: _changeVolume,
                  ),
                  const Text(
                    'Start at low volume and increase carefully.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),
          Card(
            color: const Color(0xFF14242A),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _playing ? _stopSound : null,
                      icon: const Icon(Icons.stop),
                      label: const Text('STOP SOUND'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
