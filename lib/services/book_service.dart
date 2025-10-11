import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:injectable/injectable.dart';
import '../app/injectable.dart';

import 'package:androidapp/core/constants/app_constants.dart';
import 'package:androidapp/services/session_service.dart';

@injectable
class BookService {
  final sessionService = getIt<SessionService>();

  Future<dynamic> getList(String page) async {
    final uri = Uri.https(
      ApiUrls.baseUrl,
      ApiUrls.apiPath + ApiUrls.titleRoute,
      {'page': page},
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }

  Future<dynamic> getTitle(String titleId) async {
    final uri = Uri.https(
      ApiUrls.baseUrl,
      ApiUrls.apiPath + ApiUrls.titleById(titleId),
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }

  Future<dynamic> createTitle(String title, String author, String type) async {
    final jwt = await sessionService.readToken();
    if (jwt == null) throw Exception('Não Autenticado');
    final uri = Uri.https(
      ApiUrls.baseUrl,
      ApiUrls.apiPath + ApiUrls.titleRoute,
    );

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

  Future<dynamic> deleteTitle(String titleId) async {
    final jwt = await sessionService.readToken();
    if (jwt == null) throw Exception('Não Autenticado');
    final uri = Uri.https(
      ApiUrls.baseUrl,
      ApiUrls.apiPath + ApiUrls.titleById(titleId),
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
}
