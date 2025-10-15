import 'package:mgdb/models/chapter_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../providers/api_config_provider.dart';
import 'package:mgdb/core/constants/app_constants.dart';
import 'package:mgdb/services/session_service.dart';

import 'storage_manager.dart';

@injectable
class ChapterService {
  final SessionService sessionService;
  final ApiConfigProvider apiConfigProvider;
  final StorageManager storageManager;
  final Dio _dio;

  ChapterService(
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

  Future<ChapterListResponse> getChapters(String titleId) async {
    final cacheKey = 'chapters-list_$titleId';

    final cachedData = await storageManager.getCache(
      AppCacheKeys.chaptersCache,
      cacheKey,
    );
    if (cachedData != null) {
      return ChapterListResponse.fromJson(cachedData);
    }

    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    _dio.options.baseUrl = 'https://${apiConfigProvider.baseUrl}';
    final url = apiUrls.titleChapters(titleId);

    try {
      final response = await _dio.get(url);
      await storageManager.saveCache(
        AppCacheKeys.chaptersCache,
        cacheKey,
        response.data,
      );
      return ChapterListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Falha ao obter a lista de capítulos: ${e.response?.statusCode ?? e.message}',
      );
    }
  }

  Future<Chapter> getChapter(String titleId, String chapterId) async {
    final cacheKey = 'chapter-data_$titleId-$chapterId';

    final cachedData = await storageManager.getCache(
      AppCacheKeys.chaptersCache,
      cacheKey,
    );
    if (cachedData != null) {
      return Chapter.fromJson(cachedData);
    }

    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    _dio.options.baseUrl = 'https://${apiConfigProvider.baseUrl}';
    final url = apiUrls.titleChapterById(titleId, chapterId);

    try {
      final response = await _dio.get(url);
      final data = response.data;
      final chapterJson = data['chapter'];
      await storageManager.saveCache(
        AppCacheKeys.chaptersCache,
        cacheKey,
        chapterJson,
      );
      final chapter = Chapter.fromJson(chapterJson);
      return chapter;
    } on DioException catch (e) {
      throw Exception(
        'Falha ao obter o capítulo: ${e.response?.statusCode ?? e.message}',
      );
    }
  }

  Future<ChapterCreateResponse> createChapter(
    String titleId,
    String titleText,
    int chapterNumber,
    int volumeNumber,
    String? volumeTitle,
  ) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    _dio.options.baseUrl = 'https://${apiConfigProvider.baseUrl}';
    final url = apiUrls.titleChapters(titleId);

    try {
      final response = await _dio.post(
        url,
        data: {
          'title': titleText,
          'number': chapterNumber,
          'volume': volumeNumber,
          'volumeTitle': volumeTitle,
        },
      );
      return ChapterCreateResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Falha ao criar o capítulo: ${e.response?.statusCode ?? e.message}',
      );
    }
  }

  Future<ChapterDefaultResponse> deleteChapter(
    String titleId,
    String chapterId,
  ) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    _dio.options.baseUrl = 'https://${apiConfigProvider.baseUrl}';
    final url = apiUrls.titleChapterById(titleId, chapterId);

    try {
      final response = await _dio.delete(url);
      return ChapterDefaultResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Falha ao deletar o capítulo: ${e.response?.statusCode ?? e.message}',
      );
    }
  }
}
