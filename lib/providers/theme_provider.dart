import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../shared/preferences.dart';

@injectable
class ThemeProvider extends ChangeNotifier {
  final AppPreferences _preferences;

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider(this._preferences) {
    _loadThemeFromPrefs();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _preferences.themeMode = _isDarkMode ? 'dark' : 'light';
    notifyListeners();
  }

  Future<void> _loadThemeFromPrefs() async {
    _isDarkMode = _preferences.themeMode == 'dark';
    notifyListeners();
  }
}
