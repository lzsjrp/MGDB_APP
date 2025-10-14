import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:injectable/injectable.dart';

import '../models/book_model.dart';
import '../providers/api_config_provider.dart';

@injectable
class CacheManager {
  final ApiConfigProvider apiConfigProvider;
  final Dio _dio;

  static const cacheDuration = Duration(hours: 24);

  CacheManager(this.apiConfigProvider) : _dio = Dio() {
    _dio.options
      ..baseUrl = 'https://${apiConfigProvider.baseUrl}'
      ..headers = {'Content-Type': 'application/json'};
  }

  Future<void> saveCache(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheObject = json.encode({
      'timestamp': DateTime.now().toIso8601String(),
      'data': data,
    });
    await prefs.setString(key, cacheObject);
  }

  Future<Map<String, dynamic>?> getCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString(key);
    if (cacheString == null) return null;

    final cacheMap = json.decode(cacheString) as Map<String, dynamic>;
    final timestamp = DateTime.parse(cacheMap['timestamp']);
    final now = DateTime.now();

    if (now.difference(timestamp) > cacheDuration) {
      await prefs.remove(key);
      return null;
    }

    return (cacheMap['data'] as Map).cast<String, dynamic>();
  }

  Future<bool> isFileCacheValid(String filePath, Duration cacheDuration) async {
    final file = File(filePath);
    if (!await file.exists()) return false;

    final stat = await file.stat();
    final now = DateTime.now();
    return now.difference(stat.modified) <= cacheDuration;
  }

  Future<File?> downloadCoverWithCache(String titleId, Cover? cover) async {
    if (cover == null || cover.imageUrl.isEmpty) return null;

    final dir = await getApplicationCacheDirectory();
    final filePath = '${dir.path}/cover_$titleId.jpg';

    if (await isFileCacheValid(filePath, Duration(hours: 24))) {
      return File(filePath);
    } else {
      await _dio.download(cover.imageUrl, filePath);
      return File(filePath);
    }
  }
}
