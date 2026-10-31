import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/cleaning_screen.dart';
import 'screens/speaker_test_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SpeakerCleanerApp());
}

class SpeakerCleanerApp extends StatelessWidget {
  const SpeakerCleanerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Speaker Cleaner Pro',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF081116),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00D6B2),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final screens = const [
    HomeScreen(),
    CleaningScreen(),
    SpeakerTestScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        backgroundColor: const Color(0xFF122128),
        indicatorColor: const Color(0xFF00D6B2).withOpacity(0.2),
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            label: 'Cleaning',
          ),
          NavigationDestination(
            icon: Icon(Icons.speaker_outlined),
            label: 'Test',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
