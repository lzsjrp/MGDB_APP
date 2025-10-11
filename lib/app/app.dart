import 'package:androidapp/presentation/discuss/discuss_page.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart';

import 'package:androidapp/core/theme/app_theme.dart';
import 'package:androidapp/presentation/books/explore_page.dart';
import 'package:androidapp/presentation/books/downloads/downloads_page.dart';
import 'package:androidapp/presentation/books/favorites/favorites_page.dart';
import '../shared/widgets/bottom_navigation_bar.dart';

import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../providers/connectivity_provider.dart';
import 'injectable.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
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
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const FavoritesPage(),
    const ExplorePage(),
    const DownloadsPage(),
    const DiscussPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
