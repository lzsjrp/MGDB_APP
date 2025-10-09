import 'package:http/http.dart' as http;
import 'dart:convert';

class BookController {
  static Future<dynamic> getList(String page) async {
    final uri = Uri.https('lzsjrp-mgdb.vercel.app', '/api/title', {
      'page': page,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }
  static Future<dynamic> getTitle(String titleId) async {
    final uri = Uri.https('lzsjrp-mgdb.vercel.app', '/api/title/$titleId');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }
  static Future<dynamic> getChapters(String titleId) async {
    final uri = Uri.https(
      'lzsjrp-mgdb.vercel.app',
      '/api/title/$titleId/chapters',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }
  static Future<dynamic> getChapter(String titleId, String chapterId) async {
    final uri = Uri.https(
      'lzsjrp-mgdb.vercel.app',
      '/api/title/$titleId/chapters/$chapterId',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }
  static Future<dynamic> getCover(String titleId, String chapterId) async {
    final uri = Uri.https(
      'lzsjrp-mgdb.vercel.app',
      '/api/title/$titleId/cover',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }
}
