import 'package:flutter/material.dart';

class SettingsMenu extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final String title;
  final String description;

  const SettingsMenu({
    super.key,
    required this.onPressed,
    required this.buttonText,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(inherit: true),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
