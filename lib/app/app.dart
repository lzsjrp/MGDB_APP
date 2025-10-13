import 'package:androidapp/presentation/home/discuss_page.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart';

import 'package:androidapp/core/theme/app_theme.dart';
import 'package:androidapp/presentation/home/explore_page.dart';
import 'package:androidapp/presentation/home/downloads_page.dart';
import 'package:androidapp/presentation/home/favorites_page.dart';
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

  final apiConfigProvider = getIt<ApiConfigProvider>();
  await apiConfigProvider.loadBaseUrl();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<UserProvider>.value(
          value: getIt<UserProvider>(),
        ),
        ChangeNotifierProvider<ConnectivityProvider>.value(
          value: getIt<ConnectivityProvider>(),
        ),
        ChangeNotifierProvider<ApiConfigProvider>.value(
          value: apiConfigProvider,
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
    final apiConfigProvider = context.watch<ApiConfigProvider>();

    return MaterialApp(
      title: 'App',
      key: ValueKey(apiConfigProvider.baseUrl),
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
    return NavigationPage(pages: pages, tabs: tabs);
  }
}
