import 'package:flutter/material.dart';

class SettingsReader extends StatefulWidget {
  const SettingsReader({super.key});

  @override
  State<SettingsReader> createState() => _SettingsReaderState();
}

class _SettingsReaderState extends State<SettingsReader> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 5.0, left: 20.0),
            child: Text(
              "Leitura",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
