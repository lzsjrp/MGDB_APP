import 'package:mgdb/models/chapter_model.dart';

class ChapterCreateResponse {
  final String id;
  final String message;
  final Chapter chapter;
  final Volume updatedVolume;

  ChapterCreateResponse({
    required this.id,
    required this.message,
    required this.chapter,
    required this.updatedVolume,
  });

  factory ChapterCreateResponse.fromJson(Map<String, dynamic> json) {
    return ChapterCreateResponse(
      id: json['id'],
      message: json['message'],
      chapter: Chapter.fromJson({'chapter': json['chapter']}),
      updatedVolume: Volume.fromJson(json['updatedVolume']),
    );
  }
}

class ChapterDefaultResponse {
  final int id;
  final int message;
  final Chapter chapter;

  ChapterDefaultResponse({
    required this.id,
    required this.message,
    required this.chapter,
  });

  factory ChapterDefaultResponse.fromJson(Map<String, dynamic> json) {
    return ChapterDefaultResponse(
      id: json['id'],
      message: json['message'],
      chapter: Chapter.fromJson(json['chapter']),
    );
  }
}
