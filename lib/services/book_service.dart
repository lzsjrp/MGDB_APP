import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/book_model.dart';
import '../providers/api_config_provider.dart';
import 'package:mgdb/core/constants/app_constants.dart';
import 'package:mgdb/services/session_service.dart';

@injectable
class BookService {
  final SessionService sessionService;
  final ApiConfigProvider apiConfigProvider;
  final Dio _dio;

  BookService(this.sessionService, this.apiConfigProvider) : _dio = Dio() {
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
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    final url = apiUrls.titleRoute;

    try {
      final response = await _dio.get(
        url,
        queryParameters: {'page': page, 'type': type},
      );
      return BookListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error ${e.response?.statusCode ?? e.message}');
    }
  }

  Future<Book> getTitle(String titleId) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    final url = apiUrls.titleById(titleId);

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
    final url = apiUrls.titleRoute;

    try {
      final response = await _dio.post(
        url,
        data: {'title': title, 'author': author, 'type': type},
      );
      return BookDefaultResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error ${e.response?.statusCode ?? e.message}');
    }
  }

  Future<BookDefaultResponse> deleteTitle(String titleId) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    final url = apiUrls.titleById(titleId);

    try {
      final response = await _dio.delete(url);
      return BookDefaultResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error ${e.response?.statusCode ?? e.message}');
    }
  }

  Future<Cover> getCover(String titleId) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    final url = apiUrls.titleCover(titleId);

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
