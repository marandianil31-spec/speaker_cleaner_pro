import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class FrequencyScreen extends StatelessWidget {
  const FrequencyScreen({super.key});

  static const List<int> frequencies = [
    60, 80, 100, 165, 250, 500, 1000, 2000, 4000
  ];

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
            (frequency) => Card(
              color: const Color(0xFF122128),
              child: ListTile(
                leading: const Icon(
                  Icons.graphic_eq,
                  color: Color(0xFF00D6B2),
                ),
                title: Text('$frequency Hz'),
                trailing: const Icon(Icons.play_circle),
                onTap: () {
                  AudioService.instance.playAudio(
                    'tone_$frequency.wav',
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () {
              AudioService.instance.stopAudio();
            },
            icon: const Icon(Icons.stop),
            label: const Text('Stop Frequency'),
          ),
        ],
      ),
    );
  }
}

