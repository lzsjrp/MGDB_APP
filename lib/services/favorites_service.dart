import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:mgdb/core/constants/app_constants.dart';
import 'package:mgdb/services/book_service.dart';
import '../providers/api_config_provider.dart';
import 'package:mgdb/services/session_service.dart';
import '../providers/connectivity_provider.dart';
import 'storage_manager.dart';

@injectable
class FavoritesService {
  final SessionService sessionService;
  final ApiConfigProvider apiConfigProvider;
  final ConnectivityProvider connectivityProvider;
  final StorageManager storageManager;
  final BookService bookService;
  final Dio _dio;

  FavoritesService(
    this.sessionService,
    this.apiConfigProvider,
    this.connectivityProvider,
    this.bookService,
    this.storageManager,
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

  Future<void> _writeFavoritesList(Set<String> favorites) async {
    await storageManager.saveStorage(
      AppStorageKeys.favoritesKey,
      'list',
      favorites.toList(),
    );
  }

  Future<Set<String>> _readFavoritesList() async {
    final favoritesData = await storageManager.getStorage(
      AppStorageKeys.favoritesKey,
      'list',
    );
    if (favoritesData == null) return <String>{};

    final List<dynamic> list = favoritesData;

    return list.map((e) => e.toString()).toSet();
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
    return await _readFavoritesList();
  }

  Future<void> addFavorite(String bookId) async {
    await connectivityProvider.initialized;
    if (await _canSync()) {
      final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
      _dio.options.baseUrl = 'https://${apiConfigProvider.baseUrl}';
      try {
        final url = apiUrls.manageFavorite(bookId);
        await _dio.post(url);
      } catch (e) {
        // Do-nothing
      }
    }
    if (connectivityProvider.isConnected) {
      await bookService.saveTitle(bookId);
    }
    final favorites = await _readFavoritesList();
    favorites.add(bookId);
    await _writeFavoritesList(favorites);
  }

  Future<void> removeFavorite(String bookId) async {
    if (await _canSync()) {
      final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
      _dio.options.baseUrl = 'https://${apiConfigProvider.baseUrl}';
      try {
        final url = apiUrls.manageFavorite(bookId);
        await _dio.delete(url);
      } catch (e) {
        // Do-nothing
      }
    }
    final favorites = await _readFavoritesList();
    favorites.remove(bookId);
    await _writeFavoritesList(favorites);
  }

  Future<bool> isFavorite(String bookId) async {
    final favorites = await _readFavoritesList();
    return favorites.contains(bookId);
  }

  Future<List<String>> getServerFavorites() async {
    if (!await _canSync()) return [];

    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    _dio.options.baseUrl = 'https://${apiConfigProvider.baseUrl}';
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
      throw Exception(
        'Falha ao obter os favoritos: ${e.response?.statusCode ?? e.message}',
      );
    }
  }

  Future<void> updateFavoritesFromServer() async {
    if (!await _canSync()) return;
    try {
      final serverFavorites = await getServerFavorites();
      final favoritesSet = serverFavorites.toSet();
      await _writeFavoritesList(favoritesSet);

      for (final bookId in favoritesSet) {
        try {
          await bookService.saveTitle(bookId);
        } catch (e) {
          // Do-nothing
        }
      }
    } catch (e) {
      throw Exception('Falha ao sincronizar os favoritos com o servidor: $e');
    }
  }

  Future<void> syncFavorites({bool merge = false}) async {
    if (!await _canSync()) return;

    try {
      final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
      _dio.options.baseUrl = 'https://${apiConfigProvider.baseUrl}';

      Set<String> favoritesToSync;

      if (merge) {
        final serverFavorites = (await getServerFavorites()).toSet();
        final localFavorites = await _readFavoritesList();
        favoritesToSync = {...serverFavorites, ...localFavorites};
      } else {
        favoritesToSync = await _readFavoritesList();
      }

      final response = await _dio.post(
        apiUrls.favoritesSyncRoute,
        data: jsonEncode({'booksIds': favoritesToSync.toList()}),
      );

      Set<String> confirmedFavorites;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map && response.data['favorites'] is List) {
          confirmedFavorites = (response.data['favorites'] as List)
              .map((e) => e.toString())
              .toSet();
        } else {
          confirmedFavorites = favoritesToSync;
        }
      } else {
        confirmedFavorites = favoritesToSync;
      }

      await _writeFavoritesList(confirmedFavorites);

      for (final bookId in confirmedFavorites) {
        try {
          await bookService.saveTitle(bookId);
        } catch (e) {
          // Do-nothing
        }
      }
    } on DioException catch (e) {
      throw Exception(
        'Falha ao sincronizar: ${e.response?.statusCode ?? e.message}',
      );
    } catch (e) {
      throw Exception('Erro na sincronização: $e');
    }
  }
}
