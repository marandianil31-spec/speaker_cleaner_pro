import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'screens/home_screen.dart';
import 'screens/cleaning_screen.dart';
import 'screens/speaker_test_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/frequency_screen.dart';
import 'screens/about_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await MobileAds.instance.initialize();
    debugPrint('AdMob initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('AdMob initialization error: $e');
    debugPrintStack(stackTrace: stackTrace);
  }

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
      builder: (context, child) {
        return InternetGate(
          child: child ?? const SizedBox.shrink(),
        );
      },
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
        '/water': (context) =>
            const CleaningScreen(initialMode: CleaningMode.water),
        '/dust': (context) =>
            const CleaningScreen(initialMode: CleaningMode.dust),
        '/test': (context) => const SpeakerTestScreen(),
        '/frequency': (context) => const FrequencyScreen(),
        '/about': (context) => const AboutScreen(),
      },
    );
  }
}

class InternetGate extends StatefulWidget {
  final Widget child;

  const InternetGate({
    super.key,
    required this.child,
  });

  @override
  State<InternetGate> createState() => _InternetGateState();
}

class _InternetGateState extends State<InternetGate> {
  bool? hasInternet;
  bool checking = true;

  StreamSubscription<InternetStatus>? subscription;

  @override
  void initState() {
    super.initState();
    checkInternet();

    subscription =
        InternetConnection().onStatusChange.listen((status) {
      if (!mounted) return;

      setState(() {
        hasInternet = status == InternetStatus.connected;
        checking = false;
      });
    });
  }

  Future<void> checkInternet() async {
    if (mounted) {
      setState(() {
        checking = true;
      });
    }

    try {
      final result =
          await InternetConnection().hasInternetAccess;

      if (!mounted) return;

      setState(() {
        hasInternet = result;
        checking = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        hasInternet = false;
        checking = false;
      });
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (checking || hasInternet == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF081116),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF00D6B2),
          ),
        ),
      );
    }

    if (hasInternet == false) {
      return Scaffold(
        backgroundColor: const Color(0xFF081116),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 75,
                  color: Color(0xFF00D6B2),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No Internet Connection',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please connect to the internet to use Speaker Cleaner Pro.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  onPressed: checkInternet,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D6B2),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Widget> screens = const [
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
        indicatorColor:
            const Color(0xFF00D6B2).withValues(alpha: 0.2),
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.cleaning_services_outlined),
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

