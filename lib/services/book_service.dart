import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/book_model.dart';
import '../providers/api_config_provider.dart';
import 'package:androidapp/core/constants/app_constants.dart';
import 'package:androidapp/services/session_service.dart';

@injectable
class BookService {
  final SessionService sessionService;
  final ApiConfigProvider apiConfigProvider;
  final Dio _dio;

  BookService(this.sessionService, this.apiConfigProvider) : _dio = Dio();

  Future<BookListResponse> getList(String page) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);

    final url =
        'https://${apiUrls.baseUrl}${apiUrls.apiPath}${apiUrls.titleRoute}';

    try {
      final response = await _dio.get(url, queryParameters: {'page': page});
      return BookListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error ${e.response?.statusCode ?? e.message}');
    }
  }

  Future<Book> getTitle(String titleId) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);

    final url =
        'https://${apiUrls.baseUrl}${apiUrls.apiPath}${apiUrls.titleById(titleId)}';

    try {
      final response = await _dio.get(url);
      final data = response.data;
      final bookJson = data['book'];
      final book = Book.fromJson(bookJson);
      return book;
    } on DioException catch (e) {
      throw Exception('Error ${e.response?.statusCode ?? e.message}');
    }
  }

  Future<BookDefaultResponse> createTitle(
    String title,
    String author,
    String type,
  ) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    final jwt = await sessionService.readToken();
    if (jwt == null) throw Exception('Não Autenticado');

    final url =
        'https://${apiUrls.baseUrl}${apiUrls.apiPath}${apiUrls.titleRoute}';

    try {
      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
        ),
        data: {'title': title, 'author': author, 'type': type},
      );
      return BookDefaultResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error ${e.response?.statusCode ?? e.message}');
    }
  }

  Future<BookDefaultResponse> deleteTitle(String titleId) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    final jwt = await sessionService.readToken();
    if (jwt == null) throw Exception('Não Autenticado');

    final url =
        'https://${apiUrls.baseUrl}${apiUrls.apiPath}${apiUrls.titleById(titleId)}';

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
      return BookDefaultResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error ${e.response?.statusCode ?? e.message}');
    }
  }

  Future<Cover> getCover(String titleId) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    final url =
        'https://${apiUrls.baseUrl}${apiUrls.apiPath}${apiUrls.titleCover(titleId)}';

    try {
      final response = await _dio.get(url);
      final data = response.data;
      final coverJson = data['cover'];
      final cover = Cover.fromJson(coverJson);
      return cover;
    } on DioException catch (e) {
      throw Exception('Error ${e.response?.statusCode ?? e.message}');
    }
  }
}
