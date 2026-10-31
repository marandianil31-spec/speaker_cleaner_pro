import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class SpeakerTestScreen extends StatelessWidget {
  const SpeakerTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speaker Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.speaker,
              size: 100,
              color: Color(0xFF00D6B2),
            ),
            const SizedBox(height: 25),
            const Text(
              'Test Your Speaker',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                AudioService.instance.playAudio('sweep.wav');
              },
              child: const Text('Start Test'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                AudioService.instance.stopAudio();
              },
              child: const Text('Stop Test'),
            ),
          ],
        ),
      ),
    );
  }
}
