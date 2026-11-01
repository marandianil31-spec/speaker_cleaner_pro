import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/audio_service.dart';

enum CleaningMode {
  water,
  dust,
}

class CleaningScreen extends StatefulWidget {
  final CleaningMode initialMode;

  const CleaningScreen({
    super.key,
    this.initialMode = CleaningMode.water,
  });

  @override
  State<CleaningScreen> createState() => _CleaningScreenState();
}

class _CleaningScreenState extends State<CleaningScreen>
    with SingleTickerProviderStateMixin {

  late CleaningMode mode;
  late AnimationController controller;

  bool isRunning = false;
  bool isDone = false;

  int percentage = 1;

  static const int cleaningSeconds = 30;

  @override
  void initState() {
    super.initState();

    mode = widget.initialMode;

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: cleaningSeconds),
    );

    controller.addListener(() {
      if (!mounted) return;

      setState(() {
        percentage = 1 + (controller.value * 99).floor();
      });
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        finishCleaning();
      }
    });
  }

  Future<void> startCleaning() async {
    await AudioService.instance.stopAudio();

    if (!mounted) return;

    setState(() {
      percentage = 1;
      isRunning = true;
      isDone = false;
    });

    controller.forward(from: 0);

    try {
      await AudioService.instance.playAudio(
        mode == CleaningMode.water
            ? 'sweep.wav'
            : 'tone_165.wav',
      );
    } catch (e) {
      if (!mounted) return;
      await stopCleaning();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio could not be played.'),
        ),
      );
    }
  }

  Future<void> finishCleaning() async {
    await AudioService.instance.stopAudio();

    if (!mounted) return;

    setState(() {
      percentage = 100;
      isRunning = false;
      isDone = true;
    });
  }

  Future<void> stopCleaning() async {
    controller.stop();

    await AudioService.instance.stopAudio();

    if (!mounted) return;

    setState(() {
      isRunning = false;
      isDone = false;
      percentage = 1;
    });
  }

  void changeMode(CleaningMode newMode) {
    if (isRunning) return;

    setState(() {
      mode = newMode;
      percentage = 1;
      isDone = false;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    AudioService.instance.stopAudio();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWater = mode == CleaningMode.water;

    final Color accent = isWater
        ? const Color(0xFF00BFFF)
        : const Color(0xFF00D6B2);

    final String title = isWater
        ? 'Water Eject'
        : 'Dust Removal';

    final String subtitle = isDone
        ? 'Cleaning Completed!'
        : isRunning
            ? 'Cleaning in progress...'
            : 'Ready to clean your speaker';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Speaker Cleaner Pro'),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              const SizedBox(height: 10),

              const Text(
                'SPEAKER CLEANING',
                style: TextStyle(
                  fontSize: 13,
                  letterSpacing: 3,
                  color: Colors.white54,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              // Mode Selection

              Row(
                children: [
                  Expanded(
                    child: modeButton(
                      'Water Eject',
                      Icons.water_drop,
                      CleaningMode.water,
                      accent,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: modeButton(
                      'Dust Removal',
                      Icons.air,
                      CleaningMode.dust,
                      accent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // Animated Speaker

              AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(280, 280),
                    painter: CleaningPainter(
                      progress: controller.value,
                      isWater: isWater,
                      isRunning: isRunning,
                      isDone: isDone,
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Percentage

              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.bold,
                  color: isDone
                      ? Colors.greenAccent
                      : accent,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                isDone ? 'DONE ✓' : subtitle,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: isDone
                      ? Colors.greenAccent
                      : Colors.white70,
                ),
              ),

              const SizedBox(height: 20),

              // Progress Bar

              ClipRRect(
                borderRadius: BorderRadius.circular(20),

                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 12,
                  backgroundColor: const Color(0xFF26363C),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDone ? Colors.greenAccent : accent,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                isDone
                    ? 'Your cleaning session is complete.'
                    : isRunning
                        ? 'Please wait... $percentage%'
                        : 'Start cleaning to begin progress.',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 30),

              // Start / Stop / Again Buttons

              if (!isRunning && !isDone)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: startCleaning,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      'START CLEANING',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),

              if (isRunning)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: stopCleaning,
                    icon: const Icon(Icons.stop),
                    label: const Text('STOP CLEANING'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

              if (isDone)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: startCleaning,
                    icon: const Icon(Icons.refresh),
                    label: const Text('CLEAN AGAIN'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              const Text(
                'Use moderate volume. This timer shows animation progress, '
                'not actual water or dust removal.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget modeButton(
    String text,
    IconData icon,
    CleaningMode buttonMode,
    Color accent,
  ) {
    final bool selected = mode == buttonMode;

    return OutlinedButton.icon(
      onPressed: isRunning
          ? null
          : () => changeMode(buttonMode),

      icon: Icon(icon, size: 18),

      label: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),

      style: OutlinedButton.styleFrom(
        foregroundColor: selected ? accent : Colors.white70,
        backgroundColor: selected
            ? accent.withValues(alpha: 0.10)
            : Colors.transparent,
        side: BorderSide(
          color: selected ? accent : Colors.white24,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 5,
        ),
      ),
    );
  }
}

// CUSTOM ANIMATION PAINTER

class CleaningPainter extends CustomPainter {
  final double progress;
  final bool isWater;
  final bool isRunning;
  final bool isDone;

  CleaningPainter({
    required this.progress,
    required this.isWater,
    required this.isRunning,
    required this.isDone,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final Color color = isWater
        ? const Color(0xFF00BFFF)
        : const Color(0xFF00D6B2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = color.withValues(alpha: 0.7);

    // Animated Sound Waves

    for (int i = 0; i < 4; i++) {
      final double radius =
          65 + i * 18 + (isRunning ? progress * 15 : 0);

      paint.color = color.withValues(
        alpha: isRunning ? 0.65 - i * 0.12 : 0.25,
      );

      canvas.drawCircle(
        center,
        radius,
        paint,
      );
    }

    // Speaker Body

    final speakerPaint = Paint()
      ..color = const Color(0xFF122128)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center,
      58,
      speakerPaint,
    );

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(
      center,
      58,
      borderPaint,
    );

    canvas.drawCircle(
      center,
      35,
      borderPaint,
    );

    canvas.drawCircle(
      center,
      12,
      Paint()..color = color,
    );

    // Water Drops or Dust Particles

    if (isRunning || isDone) {
      for (int i = 0; i < 18; i++) {
        final double angle = i * (math.pi * 2 / 18);

        final double movement = isDone
            ? 1
            : (progress * 1.5 + (i % 4) * 0.12) % 1;

        final double radius = 75 + movement * 65;

        final Offset particle = Offset(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius,
        );

        final particlePaint = Paint()
          ..color = color.withValues(
            alpha: isDone ? 0.4 : 0.9,
          );

        if (isWater) {
          final path = Path();

          path.moveTo(particle.dx, particle.dy - 7);
          path.quadraticBezierTo(
            particle.dx + 8,
            particle.dy + 2,
            particle.dx,
            particle.dy + 7,
          );
          path.quadraticBezierTo(
            particle.dx - 8,
            particle.dy + 2,
            particle.dx,
            particle.dy - 7,
          );

          canvas.drawPath(path, particlePaint);
        } else {
          canvas.drawCircle(
            particle,
            2.5 + (i % 3),
            particlePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CleaningPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isWater != isWater ||
        oldDelegate.isRunning != isRunning ||
        oldDelegate.isDone != isDone;
  }
}

