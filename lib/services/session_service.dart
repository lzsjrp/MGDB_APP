import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import '../core/constants/app_constants.dart';

final storage = const FlutterSecureStorage();

class SessionController {
  Future<void> saveToken(String token) async {
    await storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> readToken() async {
    return await storage.read(key: 'jwt_token');
  }

  Future<void> deleteToken() async {
    await storage.delete(key: 'jwt_token');
  }

  Future<void> login(
    BuildContext context,
    String email,
    String password,
    VoidCallback onSuccess,
    VoidCallback onError,
  ) async {
    try {
      final response = await SessionController.createSession(email, password);
      final token = response['session']?['token'] as String?;

      if (token != null) {
        await SessionController().saveToken(token);
        await SessionController.getUser(token);

        onSuccess();
      } else {
        onError();
      }
    } catch (e) {
      onError();
    }
  }

  static Future<dynamic> getSession(String jwt) async {
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

  static Future<dynamic> createSession(String email, String password) async {
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

  static Future<dynamic> getUser(String jwt) async {
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
      await SessionController().saveUser(response.body);
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }

  static Future<dynamic> createUser(
    String email,
    String name,
    String password,
  ) async {
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
