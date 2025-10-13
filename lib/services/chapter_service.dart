import 'package:androidapp/models/chapter_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../providers/api_config_provider.dart';
import 'package:androidapp/core/constants/app_constants.dart';
import 'package:androidapp/services/session_service.dart';

@injectable
class ChapterService {
  final SessionService sessionService;
  final ApiConfigProvider apiConfigProvider;
  final Dio _dio;

  ChapterService(this.sessionService, this.apiConfigProvider) : _dio = Dio();

  Future<ChapterListResponse> getChapters(String titleId) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    final url =
        'https://${apiUrls.baseUrl}${apiUrls.apiPath}${apiUrls.titleChapters(titleId)}';

    try {
      final response = await _dio.get(url);
      return ChapterListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error ${e.response?.statusCode ?? e.message}');
    }
  }

  Future<Chapter> getChapter(String titleId, String chapterId) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    final url =
        'https://${apiUrls.baseUrl}${apiUrls.apiPath}${apiUrls.titleChapterById(titleId, chapterId)}';

    try {
      final response = await _dio.get(url);
      final data = response.data;
      final chapterJson = data['chapter'];
      final chapter = Chapter.fromJson(chapterJson);
      return chapter;
    } on DioException catch (e) {
      throw Exception('Error ${e.response?.statusCode ?? e.message}');
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
    final jwt = await sessionService.readToken();
    if (jwt == null) throw Exception('Não Autenticado');

    final url =
        'https://${apiUrls.baseUrl}${apiUrls.apiPath}${apiUrls.titleChapters(titleId)}';

    try {
      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
        ),
        data: {
          'title': titleText,
          'number': chapterNumber,
          'volume': volumeNumber,
          'volumeTitle': volumeTitle,
        },
      );
      return ChapterCreateResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error ${e.response?.statusCode ?? e.message}');
    }
  }

  Future<ChapterDefaultResponse> deleteChapter(
    String titleId,
    String chapterId,
  ) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    final jwt = await sessionService.readToken();
    if (jwt == null) throw Exception('Não Autenticado');

    final url =
        'https://${apiUrls.baseUrl}${apiUrls.apiPath}${apiUrls.titleChapterById(titleId, chapterId)}';

    try {
      final response = await _dio.delete(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
        ),
      );
      return ChapterDefaultResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error ${e.response?.statusCode ?? e.message}');
    }
  }
}
