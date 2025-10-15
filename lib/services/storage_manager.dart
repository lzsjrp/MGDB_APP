import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import '../core/constants/app_constants.dart';
import '../shared/preferences.dart';

@injectable
class StorageManager {
  final AppPreferences appPreferences;
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const cacheDuration = Duration(hours: 1);

  StorageManager(this.appPreferences);

  Future<void> saveCache(
    String typeKey,
    String subKey,
    dynamic data, {
    bool expire = true,
  }) async {
    try {
      final cacheString = await _secureStorage.read(key: typeKey);
      Map<String, dynamic> typeCache = {};

      if (cacheString != null) {
        typeCache = json.decode(cacheString) as Map<String, dynamic>;
      }

      typeCache[subKey] = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': jsonDecode(jsonEncode(data)),
        'expire': expire,
      };

      await _secureStorage.write(key: typeKey, value: json.encode(typeCache));
    } catch (e) {
      return;
    }
  }

  Future<dynamic> getCache(String typeKey, String subKey) async {
    if (appPreferences.noCache) return null;

    try {
      final cacheString = await _secureStorage.read(key: typeKey);
      if (cacheString == null) return null;

      final typeCache = json.decode(cacheString) as Map<String, dynamic>;
      if (!typeCache.containsKey(subKey)) return null;

      final cacheMap = typeCache[subKey] as Map<String, dynamic>;

      if (cacheMap['expire'] == false) {
        return cacheMap['data'];
      }

      final timestamp = DateTime.parse(cacheMap['timestamp']);
      final now = DateTime.now();

      if (now.difference(timestamp) > cacheDuration) {
        typeCache.remove(subKey);
        await _secureStorage.write(key: typeKey, value: json.encode(typeCache));
        return null;
      }

      return cacheMap['data'];
    } catch (e) {
      return null;
    }
  }

  Future<void> saveStorage(String typeKey, String subKey, dynamic data) async {
    try {
      final existingData = await _secureStorage.read(key: typeKey);
      Map<String, dynamic> storageMap = {};

      if (existingData != null) {
        storageMap = json.decode(existingData) as Map<String, dynamic>;
      }

      storageMap[subKey] = jsonDecode(jsonEncode(data));

      await _secureStorage.write(key: typeKey, value: json.encode(storageMap));
    } catch (e) {
      return;
    }
  }

  Future<dynamic> getStorage(String typeKey, String subKey) async {
    try {
      final value = await _secureStorage.read(key: typeKey);
      if (value == null) return null;

      final storageMap = json.decode(value) as Map<String, dynamic>;
      if (!storageMap.containsKey(subKey)) return null;

      return storageMap[subKey];
    } catch (e) {
      return null;
    }
  }

  Future<void> clearCache(String typeKey) async {
    try {
      if (typeKey == AppCacheKeys.imagesCache) {
        final cacheMapStr = await _secureStorage.read(key: typeKey);
        if (cacheMapStr != null) {
          final imagesCache = json.decode(cacheMapStr) as Map<String, dynamic>;
          for (var entry in imagesCache.values) {
            final filePath = entry['data']?['filePath'] as String?;
            if (filePath != null) {
              final file = File(filePath);
              if (await file.exists()) {
                await file.delete();
              }
            }
          }
        }
      }

      await _secureStorage.delete(key: typeKey);
    } catch (e) {
      return;
    }
  }

  Future<bool> isFileCacheValid(String filePath, Duration cacheDuration) async {
    final file = File(filePath);
    if (!await file.exists()) return false;

    final stat = await file.stat();
    final now = DateTime.now();
    return now.difference(stat.modified) <= cacheDuration;
  }

  Future<File?> cachedImage(String imageId, String imageUrl) async {
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
      final timestamp = DateTime.parse(cacheEntry['timestamp']);
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

  Future<File?> getImage(String imageId) async {
    try {
      final storageEntry =
          await getStorage(AppStorageKeys.imagesKey, imageId)
              as Map<String, dynamic>?;

      final dir = await getDownloadsDirectory();
      final imgDir = Directory('${dir!.path}/imgs');

      if (!await imgDir.exists()) {
        await imgDir.create(recursive: true);
      }

      final filePath = '${imgDir.path}/$imageId.jpg';
      final file = File(filePath);

      if (storageEntry == null) {
        return null;
      }

      final fileExists = await file.exists();
      if (fileExists) {
        return file;
      } else {
        await saveStorage(AppStorageKeys.imagesKey, imageId, null);
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<File?> saveImage(String imageId, String imageUrl) async {
    if (imageUrl.isEmpty) return null;

    try {
      final dir = await getDownloadsDirectory();
      if (dir == null) return null;

      final imgDir = Directory('${dir.path}/imgs');
      if (!await imgDir.exists()) {
        await imgDir.create(recursive: true);
      }

      final filePath = '${imgDir.path}/$imageId.jpg';
      final file = File(filePath);

      final dio = Dio();
      await dio.download(imageUrl, filePath);

      final now = DateTime.now();
      await saveStorage(AppStorageKeys.imagesKey, imageId, {
        'timestamp': now.toIso8601String(),
        'filePath': filePath,
        'url': imageUrl,
      });

      return file;
    } catch (e) {
      return null;
    }
  }
}
