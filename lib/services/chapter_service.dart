import 'package:androidapp/services/session_service.dart';
import 'package:http/http.dart' as http;
import 'package:androidapp/core/constants/app_constants.dart';
import 'dart:convert';

class ChapterService {
  static Future<dynamic> getChapters(String titleId) async {
    final uri = Uri.https(
      ApiUrls.baseUrl,
      ApiUrls.apiPath + ApiUrls.titleChapters(titleId),
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
      ApiUrls.baseUrl,
      ApiUrls.apiPath + ApiUrls.titleChapterById(titleId, chapterId),
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
    int chapterNumber,
    int volumeNumber,
    String? volumeTitle,
  ) async {
    final jwt = await SessionController().readToken();
    if (jwt == null) throw Exception('Não Autenticado');
    final uri = Uri.https(
      ApiUrls.baseUrl,
      ApiUrls.apiPath + ApiUrls.titleChapters(titleId),
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
        'volume': volumeNumber,
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
      ApiUrls.baseUrl,
      ApiUrls.apiPath + ApiUrls.titleChapterById(titleId, chapterId),
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

  static Future<dynamic> getCover(String titleId) async {
    final uri = Uri.https(
      ApiUrls.baseUrl,
      ApiUrls.apiPath + ApiUrls.titleCover(titleId),
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }
}
