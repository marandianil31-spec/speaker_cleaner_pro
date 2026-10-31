
import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/tool_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          const AppHeader(),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Clean Your Speaker',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Remove water and dust from your phone speaker.',
              style: TextStyle(color: Colors.white70),
            ),
          ),

          ToolCard(
            title: 'Water Eject',
            subtitle: 'Remove water using sound waves',
            icon: Icons.water_drop,
            onTap: () => Navigator.pushNamed(context, '/water'),
          ),

          ToolCard(
            title: 'Dust Removal',
            subtitle: 'Clean speaker using sound vibration',
            icon: Icons.air,
            onTap: () => Navigator.pushNamed(context, '/dust'),
          ),

          ToolCard(
            title: 'Speaker Test',
            subtitle: 'Check your speaker sound',
            icon: Icons.speaker,
            onTap: () => Navigator.pushNamed(context, '/test'),
          ),

          ToolCard(
            title: 'Frequency Generator',
            subtitle: 'Play different sound frequencies',
            icon: Icons.graphic_eq,
            onTap: () => Navigator.pushNamed(context, '/frequency'),
          ),
        ],
      ),
    );
  }
}

