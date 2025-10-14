import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:injectable/injectable.dart';

import '../providers/api_config_provider.dart';

@injectable
class CacheManager {
  final ApiConfigProvider apiConfigProvider;
  final Dio _dio;

  static const cacheDuration = Duration(hours: 1);
  static const String allCacheKey = 'app_cache';

  CacheManager(this.apiConfigProvider) : _dio = Dio() {
    _dio.options
      ..baseUrl = 'https://${apiConfigProvider.baseUrl}'
      ..headers = {'Content-Type': 'application/json'};
  }

  Future<void> saveCache(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString(allCacheKey);
    Map<String, dynamic> allCache = {};

    if (cacheString != null) {
      allCache = json.decode(cacheString) as Map<String, dynamic>;
    }

    allCache[key] = {
      'timestamp': DateTime.now().toIso8601String(),
      'data': data,
    };

    await prefs.setString(allCacheKey, json.encode(allCache));
  }

  Future<Map<String, dynamic>?> getCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString(allCacheKey);
    if (cacheString == null) return null;

    final allCache = json.decode(cacheString) as Map<String, dynamic>;
    if (!allCache.containsKey(key)) return null;

    final cacheMap = allCache[key] as Map<String, dynamic>;
    final timestamp = DateTime.parse(cacheMap['timestamp']);
    final now = DateTime.now();

    if (now.difference(timestamp) > cacheDuration) {
      allCache.remove(key);
      await prefs.setString(allCacheKey, json.encode(allCache));
      return null;
    }

    return (cacheMap['data'] as Map).cast<String, dynamic>();
  }

  Future<void> clearAllCaches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(allCacheKey);
  }

  Future<bool> isFileCacheValid(String filePath, Duration cacheDuration) async {
    final file = File(filePath);
    if (!await file.exists()) return false;

    final stat = await file.stat();
    final now = DateTime.now();
    return now.difference(stat.modified) <= cacheDuration;
  }

  Future<File?> imageCache(String imageId, String imageUrl) async {
    if (imageUrl.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'app_cache-image-$imageId';

    final cacheEntryString = prefs.getString(cacheKey);
    Map<String, dynamic>? cacheEntry;
    if (cacheEntryString != null) {
      cacheEntry = json.decode(cacheEntryString) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cacheEntry['timestamp']);
      final now = DateTime.now();

      if (now.difference(timestamp) > cacheDuration) {
        await prefs.remove(cacheKey);
        cacheEntry = null;
      }
    }

    final dir = await getApplicationCacheDirectory();
    final filePath = '${dir.path}/$imageId.jpg';
    final file = File(filePath);

    if (cacheEntry != null && await file.exists()) {
      return file;
    } else {
      await _dio.download(imageUrl, filePath);
      final newCacheEntry = json.encode({
        'timestamp': DateTime.now().toIso8601String(),
        'filePath': filePath,
      });
      await prefs.setString(cacheKey, newCacheEntry);
      return file;
    }
  }
}
