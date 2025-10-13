import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import 'package:androidapp/core/constants/app_constants.dart';
import '../providers/api_config_provider.dart';
import 'package:androidapp/services/session_service.dart';
import '../providers/connectivity_provider.dart';

@injectable
class FavoritesService {
  final SessionService sessionService;
  final ApiConfigProvider apiConfigProvider;
  final ConnectivityProvider connectivityProvider;
  final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _keyFavorites = 'favorite_books';

  FavoritesService(
    this.sessionService,
    this.apiConfigProvider,
    this.connectivityProvider,
  ) : _dio = Dio() {
    _dio.options
      ..baseUrl = 'https://${apiConfigProvider.baseUrl}'
      ..headers = {'Content-Type': 'application/json'};

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await sessionService.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  Future<Set<String>> _readStorageFavorites() async {
    final jsonString = await _secureStorage.read(key: _keyFavorites);
    if (jsonString == null) return <String>{};
    final List<dynamic> list = jsonDecode(jsonString);
    return list.map((e) => e.toString()).toSet();
  }

  Future<void> _writeStorageFavorites(Set<String> favorites) async {
    final jsonString = jsonEncode(favorites.toList());
    await _secureStorage.write(key: _keyFavorites, value: jsonString);
  }

  Future<bool> _canSync() async {
    await connectivityProvider.initialized;
    if (!connectivityProvider.isConnected) return false;

    final token = await sessionService.readToken();
    if (token == null) return false;

    return true;
  }

  Future<Set<String>> getFavoritesSet({bool sync = false}) async {
    if (sync && await _canSync()) {
      await syncFavorites();
    }
    return await _readStorageFavorites();
  }

  Future<void> addFavorite(String bookId) async {
    if (await _canSync()) {
      final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
      try {
        final url = apiUrls.addOrRemoveFavorite(bookId);
        await _dio.post(url);
      } catch (e) {
        throw Exception('Error $e');
      }
    }

    final favorites = await _readStorageFavorites();
    favorites.add(bookId);
    await _writeStorageFavorites(favorites);
  }

  Future<void> removeFavorite(String bookId) async {
    if (await _canSync()) {
      final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
      try {
        final url = apiUrls.addOrRemoveFavorite(bookId);
        await _dio.delete(url);
      } catch (e) {
        throw Exception('Error $e');
      }
    }

    final favorites = await _readStorageFavorites();
    favorites.remove(bookId);
    await _writeStorageFavorites(favorites);
  }

  Future<bool> isFavorite(String bookId) async {
    final favorites = await _readStorageFavorites();
    return favorites.contains(bookId);
  }

  Future<List<String>> getServerFavorites() async {
    if (!await _canSync()) return [];

    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    final url = apiUrls.favoritesRoute;

    try {
      final response = await _dio.get(url);
      final data = response.data;
      final List<dynamic> favoritesDataDynamic = data['favorites'] ?? [];
      final List<String> favoritesData = favoritesDataDynamic
          .map((e) => e.toString())
          .toList();
      return favoritesData;
    } on DioException catch (e) {
      throw Exception('Error ${e.response?.statusCode ?? e.message}');
    }
  }

  Future<void> updateFavoritesFromServer() async {
    if (!await _canSync()) return;
    try {
      final serverFavorites = await getServerFavorites();
      final favoritesSet = serverFavorites.toSet();
      await _writeStorageFavorites(favoritesSet);
    } catch (e) {
      throw Exception('Erro: $e');
    }
  }

  Future<void> syncFavorites({bool merge = false}) async {
    if (!await _canSync()) return;

    try {
      final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);

      Set<String> favoritesToSync;

      if (merge) {
        final serverFavorites = (await getServerFavorites()).toSet();
        final localFavorites = await _readStorageFavorites();

        favoritesToSync = {...serverFavorites, ...localFavorites};
      } else {
        favoritesToSync = await _readStorageFavorites();
      }

      final response = await _dio.post(
        apiUrls.favoritesSyncRoute,
        data: jsonEncode({'booksIds': favoritesToSync.toList()}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map && response.data['favorites'] is List) {
          final confirmedFavorites = (response.data['favorites'] as List)
              .map((e) => e.toString())
              .toSet();
          await _writeStorageFavorites(confirmedFavorites);
        } else {
          await _writeStorageFavorites(favoritesToSync);
        }
      } else {
        await _writeStorageFavorites(favoritesToSync);
      }
    } on DioException catch (e) {
      throw Exception('Erro ${e.response?.statusCode ?? e.message}');
    } catch (e) {
      throw Exception('Erro: $e');
    }
  }
}
