import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import '../core/constants/app_constants.dart';

import 'package:injectable/injectable.dart';
import '../providers/api_config_provider.dart';

@injectable
class SessionService {
  final ApiConfigProvider apiConfigProvider;

  SessionService(this.apiConfigProvider);

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _keyJwt = 'user_jwt';
  static const String _keyUserData = 'user_data';

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyJwt, value: token);
  }

  Future<String?> readToken() async {
    return await _secureStorage.read(key: _keyJwt);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _keyJwt);
  }

  Future<void> saveUser(String token) async {
    await _secureStorage.write(key: _keyUserData, value: token);
  }

  Future<String?> readUser() async {
    return await _secureStorage.read(key: _keyUserData);
  }

  Future<void> deleteUser() async {
    await _secureStorage.delete(key: _keyUserData);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await createSession(email, password);
    final token = response['session']?['token'] as String?;

    if (token == null) throw Exception('Token inválido');

    await saveToken(token);
    final userData = await getUser(token);
    await saveUser(json.encode(userData));

    return userData;
  }

  Future<dynamic> getSession(String jwt) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    final uri = Uri.https(
      apiUrls.baseUrl,
      apiUrls.apiPath + apiUrls.sessionRoute,
    );
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }

  Future<dynamic> createSession(String email, String password) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    final uri = Uri.https(
      apiUrls.baseUrl,
      apiUrls.apiPath + apiUrls.sessionRoute,
    );
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }

  Future<dynamic> getUser(String jwt) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    final uri = Uri.https(
      apiUrls.baseUrl,
      apiUrls.apiPath + apiUrls.usersRoute,
    );
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      await saveUser(response.body);
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }

  Future<dynamic> createUser(String email, String name, String password) async {
    final apiUrls = ApiUrls(baseUrl: apiConfigProvider.baseUrl);
    final uri = Uri.https(
      apiUrls.baseUrl,
      apiUrls.apiPath + apiUrls.usersRoute,
    );
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password, 'name': name}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }
}
