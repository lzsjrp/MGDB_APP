import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../providers/api_config_provider.dart';

@injectable
class SessionService {
  final ApiConfigProvider apiConfigProvider;
  final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _keyJwt = 'user_jwt';
  static const String _keyUserData = 'user_data';

  SessionService(this.apiConfigProvider) : _dio = Dio();

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyJwt, value: token);
  }

  Future<String?> readToken() async {
    return await _secureStorage.read(key: _keyJwt);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _keyJwt);
  }

  Future<void> saveUser(String userData) async {
    await _secureStorage.write(key: _keyUserData, value: userData);
  }

  Future<String?> readUser() async {
    return await _secureStorage.read(key: _keyUserData);
  }

  Future<void> deleteUser() async {
    await _secureStorage.delete(key: _keyUserData);
  }

  Future<SessionResponse> login(String email, String password) async {
    final sessionResponse = await createSession(email, password);

    final token = sessionResponse.session.token;
    await saveToken(token);
    await saveUser(json.encode(sessionResponse.session.user.toJson()));
    return sessionResponse;
  }

  Future<SessionResponse> getSession(String jwt) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    final url =
        'https://${apiUrls.baseUrl}${apiUrls.apiPath}${apiUrls.sessionRoute}';

    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwt',
            'Content-Type': 'application/json',
          },
        ),
      );
      return SessionResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error ${e.response?.statusCode ?? e.message}');
    }
  }

  Future<SessionResponse> createSession(String email, String password) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    final url =
        'https://${apiUrls.baseUrl}${apiUrls.apiPath}${apiUrls.sessionRoute}';

    try {
      final response = await _dio.post(
        url,
        data: {'email': email, 'password': password},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return SessionResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error ${e.response?.statusCode ?? e.message}');
    }
  }

  Future<User> getUser(String jwt) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    final url =
        'https://${apiUrls.baseUrl}${apiUrls.apiPath}${apiUrls.usersRoute}';

    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwt',
            'Content-Type': 'application/json',
          },
        ),
      );
      await saveUser(json.encode(response.data));
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error ${e.response?.statusCode ?? e.message}');
    }
  }

  Future<User> createUser(String email, String name, String password) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    final url =
        'https://${apiUrls.baseUrl}${apiUrls.apiPath}${apiUrls.usersRoute}';

    try {
      final response = await _dio.post(
        url,
        data: {'email': email, 'password': password, 'name': name},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error ${e.response?.statusCode ?? e.message}');
    }
  }
}
