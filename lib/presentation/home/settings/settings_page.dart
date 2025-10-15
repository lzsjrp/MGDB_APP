import 'package:flutter/material.dart';
import 'package:mgdb/presentation/home/settings/settings_app.dart';
import 'package:mgdb/presentation/home/settings/settings_reader.dart';
import 'package:mgdb/presentation/home/settings/settings_sync.dart';
import 'package:mgdb/presentation/home/settings/settings_updates.dart';

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
    const SettingsReader(),
    const SettingsSync(),
    const SettingsUpdates(),
  ];

  final tabs = const [
    GButton(icon: Icons.settings, text: 'Geral'),
    GButton(icon: Icons.book, text: 'Leitura'),
    GButton(icon: Icons.sync, text: 'Sincronização'),
    GButton(icon: Icons.update, text: 'Atualizações'),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationPage(title: 'Configurações', pages: pages, tabs: tabs);
  }
}
