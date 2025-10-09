import 'package:flutter/material.dart';

import 'pages/explore.dart';
import 'pages/downloads.dart';
import 'pages/favorites.dart';
import 'pages/settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF111620),
          brightness: Brightness.dark,
          surface: Color(0xFF111620),
        ),
        scaffoldBackgroundColor: Color(0xFF111620),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111620),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1a2231),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
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
    ExplorePage(),
    FavoritesPage(),
    DownloadsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: "Explorar"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: "Favoritos"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_added),
              label: "Downloads"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Menu"
          )
        ],
      ),
    );
  }
}
