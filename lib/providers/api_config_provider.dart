import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfigProvider extends ChangeNotifier {
  String _baseUrl = "lzsjrp-mgdb.vercel.app";

  String get baseUrl => _baseUrl;

  Future<void> loadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('api_base_url') ?? _baseUrl;
    notifyListeners();
  }

  Future<void> updateBaseUrl(String newBaseUrl) async {
    _baseUrl = newBaseUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', newBaseUrl);
    notifyListeners();
  }
}
