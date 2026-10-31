import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class CleaningScreen extends StatefulWidget {
  const CleaningScreen({super.key});

  @override
  State<CleaningScreen> createState() => _CleaningScreenState();
}

class _CleaningScreenState extends State<CleaningScreen> {
  bool isPlaying = false;

  Future<void> startCleaning(String file) async {
    await AudioService.instance.playAudio(file);

    if (mounted) {
      setState(() => isPlaying = true);
    }
  }

  Future<void> stopCleaning() async {
    await AudioService.instance.stopAudio();

    if (mounted) {
      setState(() => isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speaker Cleaning')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.graphic_eq,
              size: 100,
              color: Color(0xFF00D6B2),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () => startCleaning('sweep.wav'),
              child: const Text('Water Eject'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => startCleaning('tone_165.wav'),
              child: const Text('Dust Removal'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: stopCleaning,
              child: const Text('Stop'),
            ),
            const SizedBox(height: 15),
            Text(isPlaying ? 'Cleaning Running' : 'Ready'),
          ],
        ),
      ),
    );
  }
}
