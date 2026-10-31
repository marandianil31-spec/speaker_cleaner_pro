import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            Icons.graphic_eq,
            color: Color(0xFF00D6B2),
            size: 32,
          ),
          SizedBox(width: 12),
          Text(
            'Speaker Cleaner Pro',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
