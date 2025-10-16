import 'package:injectable/injectable.dart';
import 'package:mgdb/models/categories_model.dart';
import 'package:mgdb/services/session_service.dart';
import '../core/constants/app_constants.dart';
import '../providers/api_config_provider.dart';
import 'storage_manager.dart';

import 'package:dio/dio.dart';

@injectable
class CategoriesService {
  final SessionService sessionService;
  final ApiConfigProvider apiConfigProvider;
  final StorageManager storageManager;
  final Dio _dio;

  CategoriesService(
    this.sessionService,
    this.apiConfigProvider,
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

  Future<List<CategoriesListItem>> getList() async {
    final cacheKey = 'categoriesList';

    final cachedData = await storageManager.getCache(
      AppCacheKeys.defaultCache,
      cacheKey,
    );
    if (cachedData != null) {
      return (cachedData as List)
          .map((item) => CategoriesListItem.fromJson(item))
          .toList();
    }

    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    _dio.options.baseUrl = 'https://${apiConfigProvider.baseUrl}';
    final url = apiUrls.categoriesRoute;

    try {
      final response = await _dio.get(url);
      final categories = response.data['categories'];
      await storageManager.saveCache(
        AppCacheKeys.defaultCache,
        cacheKey,
        categories,
      );
      return (categories as List)
          .map((item) => CategoriesListItem.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        'Falha ao obter a lista de categorias: ${e.response?.statusCode ?? e.message}',
      );
    }
  }

  Future<Category> getCategory(String categoryId) async {
    final cacheKey = 'category-$categoryId';

    final cachedData = await storageManager.getCache(
      AppCacheKeys.defaultCache,
      cacheKey,
    );
    if (cachedData != null) {
      return Category.fromJson(cachedData);
    }

    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    _dio.options.baseUrl = 'https://${apiConfigProvider.baseUrl}';
    final url = apiUrls.categoryById(categoryId);

    try {
      final response = await _dio.get(url);
      final category = response.data['category'];
      await storageManager.saveCache(
        AppCacheKeys.defaultCache,
        cacheKey,
        category,
      );
      return Category.fromJson(category);
    } on DioException catch (e) {
      throw Exception(
        'Falha ao obter a categoria: ${e.response?.statusCode ?? e.message}',
      );
    }
  }
}
