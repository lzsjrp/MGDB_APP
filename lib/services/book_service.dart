import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mgdb/services/storage_manager.dart';

import '../models/book_model.dart';
import '../providers/api_config_provider.dart';
import 'package:mgdb/core/constants/app_constants.dart';
import 'package:mgdb/services/session_service.dart';

@injectable
class BookService {
  final SessionService sessionService;
  final ApiConfigProvider apiConfigProvider;
  final StorageManager storageManager;
  final Dio _dio;

  BookService(this.sessionService, this.apiConfigProvider, this.storageManager)
    : _dio = Dio() {
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

  Future<BookListResponse> getList({required String page, String? type}) async {
    final cacheKey = 'list-data_$page-$type';

    final cachedData = await storageManager.getCache(
      AppCacheKeys.booksCache,
      cacheKey,
    );
    if (cachedData != null) {
      return BookListResponse.fromJson(cachedData);
    }

    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    _dio.options.baseUrl = 'https://${apiConfigProvider.baseUrl}';
    final url = apiUrls.titleRoute;

    try {
      final response = await _dio.get(
        url,
        queryParameters: {'page': page, 'type': type},
      );
      await storageManager.saveCache(
        AppCacheKeys.booksCache,
        cacheKey,
        response.data,
      );
      return BookListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Falha ao obter a lista de títulos: ${e.response?.statusCode ?? e.message}',
      );
    }
  }

  Future<Book> getTitle(String titleId) async {
    final cacheKey = 'book-data_$titleId';

    final cachedData = await storageManager.getCache(
      AppCacheKeys.booksCache,
      cacheKey,
    );
    if (cachedData != null) {
      return Book.fromJson(cachedData);
    }

    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    _dio.options.baseUrl = 'https://${apiConfigProvider.baseUrl}';
    final url = apiUrls.titleById(titleId);

    try {
      final response = await _dio.get(url);
      final data = response.data;
      final bookJson = data['book'];
      await storageManager.saveCache(
        AppCacheKeys.booksCache,
        cacheKey,
        bookJson,
      );
      final book = Book.fromJson(bookJson);
      return book;
    } on DioException catch (e) {
      throw Exception(
        'Falha ao obter o título: ${e.response?.statusCode ?? e.message}',
      );
    }
  }

  Future<BookDefaultResponse> createTitle(
    String title,
    String author,
    String type,
  ) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    _dio.options.baseUrl = 'https://${apiConfigProvider.baseUrl}';
    final url = apiUrls.titleRoute;

    try {
      final response = await _dio.post(
        url,
        data: {'title': title, 'author': author, 'type': type},
      );
      return BookDefaultResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Falha ao criar o título: ${e.response?.statusCode ?? e.message}',
      );
    }
  }

  Future<BookDefaultResponse> deleteTitle(String titleId) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    _dio.options.baseUrl = 'https://${apiConfigProvider.baseUrl}';
    final url = apiUrls.titleById(titleId);

    try {
      final response = await _dio.delete(url);
      return BookDefaultResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Falha ao deletar o título: ${e.response?.statusCode ?? e.message}',
      );
    }
  }

  Future<Cover?> getCover(String titleId) async {
    final cacheKey = 'cover-data_$titleId';

    final cachedData = await storageManager.getCache(
      AppCacheKeys.booksCache,
      cacheKey,
    );
    if (cachedData != null) {
      return Cover.fromJson(cachedData);
    }

    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    _dio.options.baseUrl = 'https://${apiConfigProvider.baseUrl}';
    final url = apiUrls.titleCover(titleId);

    try {
      final response = await _dio.get(url);
      final data = response.data;
      final coverJson = data['cover'];
      await storageManager.saveCache(
        AppCacheKeys.booksCache,
        cacheKey,
        coverJson,
      );
      final cover = Cover.fromJson(coverJson);
      return cover;
    } on DioException {
      return null;
    }
  }
}
