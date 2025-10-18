import 'app_colors.dart';
import 'package:flutter/material.dart';

class ThemeLight implements AppColors {
  @override
  Color primary = Colors.white;
  @override
  Color secondary = Colors.grey.shade300;
  @override
  Color accent = Colors.red;
  @override
  Brightness brightness = Brightness.light;
  @override
  Color surface = Colors.grey.shade200;
  @override
  Color selectedItem = Colors.blue.shade300;
  @override
  Color unselectedItem = Colors.grey;
  @override
  Color onPrimary = Colors.black87;
  @override
  Color progress = Colors.blue.shade300;
  @override
  Color textButtonDisabled = Colors.grey.shade400;
  @override
  Color textButton = Colors.redAccent;
  @override
  Color onSecondary = Colors.grey.shade700;
  @override
  Color onSurface = Colors.black87;
  @override
  Color onError = const Color(0xFFC24E60);
}