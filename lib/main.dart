import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() => runApp(const SpeakerCleanerApp());

class SpeakerCleanerApp extends StatelessWidget {
  const SpeakerCleanerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Speaker Cleaner Pro',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF36D6C5), brightness: Brightness.dark),
      scaffoldBackgroundColor: const Color(0xFF081116),
    ),
    home: const CleanerHome(),
  );
}

class CleanerHome extends StatefulWidget {
  const CleanerHome({super.key});
  @override
  State<CleanerHome> createState() => _CleanerHomeState();
}

class _CleanerHomeState extends State<CleanerHome> {
  final AudioPlayer player = AudioPlayer();
  String status = 'Ready';
  bool playing = false;

  @override
  void initState() {
    super.initState();
    player.onPlayerComplete.listen((_) {
      if (mounted) setState(() { playing = false; status = 'Complete'; });
    });
    player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => playing = s == PlayerState.playing);
    });
  }

  Future<void> play(String asset, String label) async {
    try {
      await player.stop();
      setState(() => status = label);
      await player.play(AssetSource(asset));
    } catch (_) {
      if (mounted) setState(() => status = 'Playback error');
    }
  }

  Future<void> stop() async {
    await player.stop();
    if (mounted) setState(() { playing = false; status = 'Stopped'; });
  }

  @override
  void dispose() { player.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Speaker Cleaner Pro', style: TextStyle(fontWeight: FontWeight.bold)),
      actions: [IconButton(
        icon: const Icon(Icons.info_outline),
        onPressed: () => showAboutDialog(context: context, applicationName: 'Speaker Cleaner Pro',
          applicationVersion: '1.0.0',
          children: const [Text('Plays short tones and a frequency sweep. Audio cannot guarantee water removal.')]),
      )],
    ),
    body: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF153E46), Color(0xFF14232B)]),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFF2C676C)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.graphic_eq_rounded, size: 50, color: Color(0xFF36D6C5)),
          const SizedBox(height: 14),
          const Text('Clear sound. Simple controls.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Play a short tone or a gentle frequency sweep through your phone speaker.',
            style: TextStyle(color: Color(0xFFB9D0D4), height: 1.5)),
          const SizedBox(height: 18),
          Row(children: [
            const Icon(Icons.circle, size: 10, color: Color(0xFF36D6C5)),
            const SizedBox(width: 8),
            Expanded(child: Text(playing ? 'Playing: $status' : status, style: const TextStyle(fontWeight: FontWeight.bold))),
            if (playing) TextButton.icon(onPressed: stop, icon: const Icon(Icons.stop), label: const Text('Stop')),
          ]),
        ]),
      ),
      const SizedBox(height: 24),
      const Text('CLEANING MODES', style: TextStyle(letterSpacing: 1.8, color: Color(0xFF91AEB5), fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      modeCard(Icons.waves, 'Speaker Tone', '165 Hz · 8 seconds', 'A short steady tone at moderate level.', 'Play Tone',
        () => play('audio/tone_165.wav', 'Speaker Tone')),
      const SizedBox(height: 12),
      modeCard(Icons.multitrack_audio, 'Frequency Sweep', '120–600 Hz · 12 seconds', 'A gradual sweep across low frequencies.', 'Start Sweep',
        () => play('audio/sweep.wav', 'Frequency Sweep')),
      const SizedBox(height: 22),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF211F18), borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF65552D))),
        child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.health_and_safety_outlined, color: Color(0xFFFFD27A)),
          SizedBox(width: 12),
          Expanded(child: Text('Safety: keep volume moderate, do not wear headphones during playback, and stop if uncomfortable. If your phone got wet, follow the manufacturer’s drying guidance. Audio cannot guarantee water removal.',
            style: TextStyle(height: 1.45, color: Color(0xFFE9DDBF)))),
        ]),
      ),
      const SizedBox(height: 18),
      const Text('No water-removal guarantee', textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF71878D), fontSize: 12)),
    ])),
  );

  Widget modeCard(IconData icon, String title, String subtitle, String detail, String button, VoidCallback onTap) => Card(
    color: const Color(0xFF14232B),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: Color(0xFF263940))),
    child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF203B42), borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: const Color(0xFF36D6C5), size: 28)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Color(0xFF8FE8DD), fontWeight: FontWeight.w600)),
        ])),
      ]),
      const SizedBox(height: 14),
      Text(detail, style: const TextStyle(color: Color(0xFFB2C4C9), height: 1.4)),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: onTap,
        icon: const Icon(Icons.play_arrow_rounded), label: Text(button))),
    ])),
  );
}
