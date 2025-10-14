import 'package:flutter/material.dart';
import 'package:mgdb/presentation/home/settings/settings_app.dart';
import 'package:mgdb/presentation/home/settings/settings_sync.dart';

import '../../../shared/widgets/navigation_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final pages = [
    const SettingsApp(),
    const SettingsSync()
  ];

  final tabs = const [
    GButton(icon: Icons.settings, text: 'Geral'),
    GButton(icon: Icons.sync, text: 'Sincronização'),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationPage(pages: pages, tabs: tabs);
  }
}
