import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../core/theme/custom/bottom_navbar_theme.dart';
import '../../presentation/home/settings/settings_page.dart';

class NavigationPage extends StatefulWidget {
  final List<Widget> pages;
  final List<GButton> tabs;
  final int initialIndex;

  const NavigationPage({
    super.key,
    required this.pages,
    required this.tabs,
    this.initialIndex = 0,
  });

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BottomNavBarThemeData>()!;
    return Scaffold(
      appBar: AppBar(
        title: Text('App'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: widget.pages[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: theme.backgroundColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: GNav(
              gap: theme.gap,
              iconSize: theme.iconSize,
              backgroundColor: Colors.transparent,
              color: theme.iconColor,
              activeColor: theme.activeIconColor,
              textStyle: theme.labelStyle,
              tabBorderRadius: theme.tabBorderRadius,
              selectedIndex: _currentIndex,
              onTabChange: _onTabChange,
              tabs: widget.tabs,
            ),
          ),
        ),
      ),
    );
  }
}
