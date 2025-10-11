import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import '../core/constants/app_constants.dart';

import 'package:injectable/injectable.dart';

final storage = const FlutterSecureStorage();

@injectable
class SessionService {
  Future<void> saveToken(String token) async {
    await storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> readToken() async {
    return await storage.read(key: 'jwt_token');
  }

  Future<void> deleteToken() async {
    await storage.delete(key: 'jwt_token');
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
    final uri = Uri.https(
      ApiUrls.baseUrl,
      ApiUrls.apiPath + ApiUrls.sessionRoute,
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
    final uri = Uri.https(
      ApiUrls.baseUrl,
      ApiUrls.apiPath + ApiUrls.sessionRoute,
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

  Future<void> saveUser(String token) async {
    await storage.write(key: 'user_data', value: token);
  }

  Future<String?> readUser() async {
    return await storage.read(key: 'user_data');
  }

  Future<void> deleteUser() async {
    await storage.delete(key: 'user_data');
  }

  Future<dynamic> getUser(String jwt) async {
    final uri = Uri.https(
      ApiUrls.baseUrl,
      ApiUrls.apiPath + ApiUrls.usersRoute,
    );
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      await SessionService().saveUser(response.body);
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }

  Future<dynamic> createUser(String email, String name, String password) async {
    final uri = Uri.https(
      ApiUrls.baseUrl,
      ApiUrls.apiPath + ApiUrls.usersRoute,
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
