import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
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

  SessionService(this.apiConfigProvider) : _dio = Dio() {
    _dio.options
      ..baseUrl = 'https://${apiConfigProvider.baseUrl}'
      ..headers = {'Content-Type': 'application/json'};

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await readToken();
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
    _dio.options.baseUrl = 'https://${apiConfigProvider.baseUrl}';
    final url = apiUrls.sessionRoute;

    try {
      final response = await _dio.get(url);
      return SessionResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Falha ao obter a sessão: ${e.response?.statusCode ?? e.message}',
      );
    }
  }

  Future<SessionResponse> createSession(String email, String password) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    _dio.options.baseUrl = 'https://${apiConfigProvider.baseUrl}';
    final url = apiUrls.sessionRoute;

    debugPrint(apiConfigProvider.baseUrl);

    try {
      final response = await _dio.post(
        url,
        data: {'email': email, 'password': password},
      );
      return SessionResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Falha ao criar a sessão: ${e.response?.statusCode ?? e.message}',
      );
    }
  }

  Future<User> getUser(String jwt) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    _dio.options.baseUrl = 'https://${apiConfigProvider.baseUrl}';
    final url = apiUrls.usersRoute;

    try {
      final response = await _dio.get(url);
      await saveUser(json.encode(response.data));
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Falha ao obter o usuário: ${e.response?.statusCode ?? e.message}',
      );
    }
  }

  Future<User> createUser(String email, String name, String password) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    _dio.options.baseUrl = 'https://${apiConfigProvider.baseUrl}';
    final url = apiUrls.usersRoute;

    try {
      final response = await _dio.post(
        url,
        data: {'email': email, 'password': password, 'name': name},
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Falha ao criar o usuário: ${e.response?.statusCode ?? e.message}',
      );
    }
  }
}
