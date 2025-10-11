import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:injectable/injectable.dart';
import '../app/injectable.dart';

import 'package:androidapp/core/constants/app_constants.dart';
import 'package:androidapp/services/session_service.dart';

@injectable
class ChapterService {
  final sessionService = getIt<SessionService>();

  Future<dynamic> getChapters(String titleId) async {
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

  Future<dynamic> getChapter(String titleId, String chapterId) async {
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

  Future<dynamic> createChapter(
    String titleId,
    String titleText,
    int chapterNumber,
    int volumeNumber,
    String? volumeTitle,
  ) async {
    final jwt = await sessionService.readToken();
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

  Future<dynamic> deleteChapter(String titleId, String chapterId) async {
    final jwt = await sessionService.readToken();
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

  Future<dynamic> getCover(String titleId) async {
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
