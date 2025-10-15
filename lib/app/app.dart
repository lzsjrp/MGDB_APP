import 'package:mgdb/presentation/home/discuss_page.dart';
import 'package:flutter/material.dart';
import 'package:mgdb/shared/preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart';

import 'package:mgdb/core/theme/app_theme.dart';
import 'package:mgdb/presentation/home/explore_page.dart';
import 'package:mgdb/presentation/home/downloads_page.dart';
import 'package:mgdb/presentation/home/favorites_page.dart';
import '../presentation/home/settings/settings_page.dart';
import '../shared/widgets/navigation_page.dart';

import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../providers/connectivity_provider.dart';
import '../providers/api_config_provider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'injectable.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();

  await AppPreferences().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(getIt<AppPreferences>()),
        ),
        ChangeNotifierProvider<UserProvider>.value(
          value: getIt<UserProvider>(),
        ),
        ChangeNotifierProvider<ConnectivityProvider>.value(
          value: getIt<ConnectivityProvider>(),
        ),
        ChangeNotifierProvider<ApiConfigProvider>.value(
          value: getIt<ApiConfigProvider>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
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
      return Scaffold(
        body: AlertDialog(
          title: const Text('Permissão necessária'),
          content: const Text(
            'Para continuar, autorize a permissão de armazenamento nas configurações.',
          ),
          actions: [
            TextButton(
              onPressed: () => _requestPermissions(),
              child: const Text('Abrir configurações'),
            ),
          ],
        ),
      );
    }

    final actions = [
      IconButton(
        icon: Icon(Icons.settings),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsPage()),
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
