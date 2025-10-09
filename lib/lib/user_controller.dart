import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

final storage = const FlutterSecureStorage();

class UserController {
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
    final response = await http.get(Uri.parse('mgdb-api-sigma.vercel.app/api/users'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }
  static Future<dynamic> createUser(String email, String name,String password) async {
    final url = Uri.parse('mgdb-api-sigma.vercel.app/api/users');
    final response = await http.post(
      url,
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
