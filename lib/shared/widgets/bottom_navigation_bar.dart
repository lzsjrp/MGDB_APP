import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../core/theme/custom/bottom_navbar_theme.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BottomNavBarThemeData>()!;
    return GNav(
      gap: theme.gap,
      iconSize: theme.iconSize,
      backgroundColor: theme.backgroundColor,
      color: theme.iconColor,
      activeColor: theme.activeIconColor,
      textStyle: theme.labelStyle,
      tabBorderRadius: theme.tabBorderRadius,
      selectedIndex: currentIndex,
      padding: theme.padding,
      onTabChange: onTap,
      tabs: const [
        GButton(icon: Icons.explore, text: 'Explorar'),
        GButton(icon: Icons.favorite, text: 'Favoritos'),
        GButton(icon: Icons.download, text: 'Downloads'),
      ],
    );
  }
}
