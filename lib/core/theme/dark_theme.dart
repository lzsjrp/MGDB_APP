import 'app_colors.dart';
import 'package:flutter/material.dart';

class ThemeDark implements AppColors {
  @override
  Color primary = const Color(0xFF2c3952);
  @override
  Color secondary = const Color(0xff232e42);
  @override
  Color accent = const Color(0xFFC24E60);
  @override
  Brightness brightness = Brightness.dark;
  @override
  Color surface = const Color(0xFF161D2C);
  @override
  Color selectedItem = const Color(0xFFC24E60);
  @override
  Color unselectedItem = Colors.grey;
  @override
  Color onPrimary = Colors.white;
  @override
  Color progress = const Color(0xFFC24E60);
  @override
  Color textButtonDisabled = const Color(0xFF9A2438);
  @override
  Color textButton = const Color(0xFFC55C6B);
  @override
  Color onSecondary = Colors.white70;
  @override
  Color onSurface = Colors.white;
  @override
  Color onError = Colors.red;
}