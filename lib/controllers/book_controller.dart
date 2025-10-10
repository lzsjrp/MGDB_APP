import 'dart:ffi';
import 'package:androidapp/controllers/session_controller.dart';
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

  static Future<dynamic> createTitle(
    String title,
    String author,
    String type,
  ) async {
    final jwt = await SessionController().readToken();
    if (jwt == null) throw Exception('Não Autenticado');
    final uri = Uri.https('lzsjrp-mgdb.vercel.app', '/api/title');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: json.encode({'title': title, 'author': author, 'type': type}),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }

  static Future<dynamic> deleteTitle(String titleId) async {
    final jwt = await SessionController().readToken();
    if (jwt == null) throw Exception('Não Autenticado');
    final uri = Uri.https('lzsjrp-mgdb.vercel.app', '/api/title/$titleId');

    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
    );

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

  static Future<dynamic> createChapter(
    String titleId,
    String titleText,
    Int chapterNumber,
    Int volumeNuber,
    String? volumeTitle,
  ) async {
    final jwt = await SessionController().readToken();
    if (jwt == null) throw Exception('Não Autenticado');
    final uri = Uri.https(
      'lzsjrp-mgdb.vercel.app',
      '/api/title/$titleId/chapters',
    );

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: json.encode({
        'title': titleText,
        'number': chapterNumber,
        'volume': volumeNuber,
        'volumeTitle': volumeTitle,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }

  static Future<dynamic> deleteChapter(String titleId, String chapterId) async {
    final jwt = await SessionController().readToken();
    if (jwt == null) throw Exception('Não Autenticado');
    final uri = Uri.https(
      'lzsjrp-mgdb.vercel.app',
      '/api/title/$titleId/chapters/$chapterId',
    );

    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
    );

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
