
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.graphic_eq,
                size: 90,
                color: Color(0xFF00D6B2),
              ),
              SizedBox(height: 20),
              Text(
                'Speaker Cleaner Pro',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Clean and test your phone speaker with sound tools.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text('Version 1.0.0'),
            ],
          ),
        ),
      ),
    );
  }
}

