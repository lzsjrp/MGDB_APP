import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../core/constants/app_constants.dart';
import '../shared/preferences.dart';

@injectable
class ApiConfigProvider extends ChangeNotifier {
  final AppPreferences _preferences;

  String _baseUrl = DefaultPreferences.apiBaseUrl;

  String get baseUrl => _baseUrl;

  ApiConfigProvider(this._preferences) {
    loadBaseUrl();
  }

  Future<void> loadBaseUrl() async {
    _baseUrl = _preferences.apiBaseUrl;
    notifyListeners();
  }

  Future<void> updateBaseUrl(String newBaseUrl) async {
    _preferences.apiBaseUrl = newBaseUrl;
    _baseUrl = newBaseUrl;
    notifyListeners();
  }
}
