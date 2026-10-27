
import 'package:flutter/material.dart';

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
      home: const TestHomePage(),
    );
  }
}

class TestHomePage extends StatelessWidget {
  const TestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF123B40),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: const Color(0xFF00D6B2),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.speaker_rounded,
                    size: 70,
                    color: Color(0xFF00D6B2),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Speaker Cleaner Pro',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'App startup test successful!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF00D6B2),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Testing basic Flutter app startup.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
