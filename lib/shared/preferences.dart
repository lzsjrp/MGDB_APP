import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';

@injectable
class AppPreferences {
  static final AppPreferences _instance = AppPreferences._internal();
  late SharedPreferences _prefs;

  factory AppPreferences() {
    return _instance;
  }

  AppPreferences._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? getString(String key) => _prefs.getString(key);

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  bool get noCache => _prefs.getBool('no_cache') ?? DefaultPreferences.noCache;

  set noCache(bool value) => _prefs.setBool('no_cache', value);

  bool get earlyAccess => _prefs.getBool('earlyAccess') ?? false;

  set earlyAccess(bool value) => _prefs.setBool('earlyAccess', value);

  String get themeMode =>
      _prefs.getString('theme_mode') ?? DefaultPreferences.theme;

  set themeMode(String value) => _prefs.setString('theme_mode', value);

  String get apiBaseUrl =>
      _prefs.getString('api_url') ?? DefaultPreferences.apiBaseUrl;

  set apiBaseUrl(String value) => _prefs.setString('api_url', value);

  Future<void> clear() async => await _prefs.clear();
}
