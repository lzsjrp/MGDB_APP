import 'package:flutter/material.dart';

abstract class AppColors {
  Color get primary;

  Color get secondary;

  Color get error;

  Brightness get brightness;

  Color get surface;

  Color get selectedItem;

  Color get unselectedItem;

  Color get onPrimary;

  Color get progress;

  Color get textButtonDisabled;

  Color get textButton;

  Color get onSecondary;

  Color get onSurface;

  Color get onError;
}

class AppColorsDark implements AppColors {
  @override
  Color primary = const Color(0xFF111620);
  @override
  Color secondary = const Color(0xFF1a2231);
  @override
  Color error = const Color(0xFFC24E60);
  @override
  Brightness brightness = Brightness.dark;
  @override
  Color surface = const Color(0xFF111620);
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

class AppColorsLight implements AppColors {
  @override
  Color primary = Colors.white;
  @override
  Color secondary = Colors.grey.shade200;
  @override
  Color error = Colors.red;
  @override
  Brightness brightness = Brightness.light;
  @override
  Color surface = Colors.white;
  @override
  Color selectedItem = Colors.redAccent;
  @override
  Color unselectedItem = Colors.grey;
  @override
  Color onPrimary = Colors.black87;
  @override
  Color progress = Colors.redAccent;
  @override
  Color textButtonDisabled = Colors.grey.shade400;
  @override
  Color textButton = Colors.redAccent;
  @override
  Color onSecondary = Colors.grey.shade700;
  @override
  Color onSurface = Colors.black87;
  @override
  Color onError = Colors.red;
}
