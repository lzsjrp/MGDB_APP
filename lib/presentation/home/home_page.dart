import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:mgdb/presentation/home/explore_page.dart';
import 'package:mgdb/presentation/home/downloads_page.dart';
import 'package:mgdb/presentation/home/favorites_page.dart';
import 'package:mgdb/presentation/home/settings/settings_page.dart';
import 'package:mgdb/presentation/home/books/create_page.dart';
import 'package:mgdb/presentation/home/discuss_page.dart';

import 'package:google_nav_bar/google_nav_bar.dart';

import '../../app/injectable.dart';
import '../../shared/preferences.dart';
import '../../shared/widgets/navigation_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  final _preferences = getIt<AppPreferences>();
  static bool _storagePermission = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final result = await Permission.manageExternalStorage.status;

    if (!mounted) return;
    setState(() {
      _storagePermission = result == PermissionStatus.granted;
    });
  }

  Future<void> _requestPermissions() async {
    await Permission.manageExternalStorage.request();

    if (!mounted) return;
    _checkPermissions();
  }

  final pages = [
    const FavoritesPage(),
    const ExplorePage(),
    const DownloadsPage(),
    const DiscussPage(),
  ];

  final tabs = const [
    GButton(icon: Icons.favorite, text: 'Favoritos'),
    GButton(icon: Icons.explore, text: 'Explorar'),
    GButton(icon: Icons.download, text: 'Downloads'),
    GButton(icon: Icons.people, text: 'Forum'),
  ];

  @override
  Widget build(BuildContext context) {
    if (!_storagePermission) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Permissão necessária'),
            content: const Text(
              'Para continuar, autorize a permissão de armazenamento nas configurações.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _requestPermissions();
                },
                child: const Text('Abrir configurações'),
              ),
            ],
          ),
        );
      });
    }

    final actions = [
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          );
        },
      ),
      if (_preferences.earlyAccess)
        IconButton(
          icon: const Icon(Icons.my_library_books),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditBookPage()),
            );
          },
        ),
    ];

    return NavigationPage(
      title: 'App',
      pages: pages,
      tabs: tabs,
      actions: actions,
    );
  }
}
