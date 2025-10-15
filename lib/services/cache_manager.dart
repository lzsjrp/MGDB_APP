import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mgdb/shared/preferences.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:injectable/injectable.dart';

import '../core/constants/app_constants.dart';

@injectable
class CacheManager {
  final Dio _dio;
  final AppPreferences appPreferences;

  static const cacheDuration = Duration(hours: 1);

  CacheManager(this.appPreferences) : _dio = Dio();

  Future<void> saveCache(String typeKey, String subKey, dynamic data) async {
    if (appPreferences.noCache) return;
    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString(typeKey);

    Map<String, dynamic> typeCache = {};

    if (cacheString != null) {
      typeCache = json.decode(cacheString) as Map<String, dynamic>;
    }

    typeCache[subKey] = {
      'timestamp': DateTime.now().toIso8601String(),
      'data': data,
    };

    await prefs.setString(typeKey, json.encode(typeCache));
  }

  Future<dynamic> getCache(String typeKey, String subKey) async {
    if (appPreferences.noCache) return null;
    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString(typeKey);
    if (cacheString == null) return null;

    final typeCache = json.decode(cacheString) as Map<String, dynamic>;
    if (!typeCache.containsKey(subKey)) return null;

    final cacheMap = typeCache[subKey] as Map<String, dynamic>;
    final timestamp = DateTime.parse(cacheMap['timestamp']);
    final now = DateTime.now();

    if (now.difference(timestamp) > cacheDuration) {
      typeCache.remove(subKey);
      await prefs.setString(typeKey, json.encode(typeCache));
      return null;
    }

    return cacheMap['data'];
  }

  Future<void> clearCache(String typeKey) async {
    final prefs = await SharedPreferences.getInstance();

    if (typeKey == AppCacheKeys.imagesCache) {
      final cacheMap = prefs.getString(typeKey);
      if (cacheMap != null) {
        final Map<String, dynamic> imagesCache = json.decode(cacheMap);
        for (var entry in imagesCache.values) {
          final filePath = entry['data']['filePath'] as String?;
          if (filePath != null) {
            final file = File(filePath);
            if (await file.exists()) {
              await file.delete();
            }
          }
        }
      }
    }

    await prefs.remove(typeKey);
  }

  Future<bool> isFileCacheValid(String filePath, Duration cacheDuration) async {
    final file = File(filePath);
    if (!await file.exists()) return false;

    final stat = await file.stat();
    final now = DateTime.now();
    return now.difference(stat.modified) <= cacheDuration;
  }

  Future<File?> imageCache(String imageId, String imageUrl) async {
    if (appPreferences.noCache) return null;
    if (imageUrl.isEmpty) return null;

    final cacheEntry =
        await getCache(AppCacheKeys.imagesCache, imageId)
            as Map<String, dynamic>?;

    final dir = await getApplicationCacheDirectory();
    final filePath = '${dir.path}/$imageId.jpg';
    final file = File(filePath);

    final now = DateTime.now();

    if (cacheEntry != null) {
      final timestamp = DateTime.parse(cacheEntry['timestamp'] as String);
      final expired = now.difference(timestamp) > cacheDuration;
      final fileExists = await file.exists();

      if (!expired && fileExists) {
        return file;
      }

      if (expired && fileExists) {
        await file.delete();
      }
    }

    await _dio.download(imageUrl, filePath);

    await saveCache(AppCacheKeys.imagesCache, imageId, {
      'timestamp': now.toIso8601String(),
      'filePath': filePath,
    });

    return file;
  }
}
