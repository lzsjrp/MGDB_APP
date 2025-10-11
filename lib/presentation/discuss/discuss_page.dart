import 'package:androidapp/presentation/settings/settings_page.dart';
import 'package:flutter/material.dart';

class DiscussPage extends StatelessWidget {
  const DiscussPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forum'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Center(child: Text("Não implementado")),
    );
  }
}
