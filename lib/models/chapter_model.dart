import 'package:mgdb/models/scanlator_model.dart';

class Chapter {
  final String id;
  final String bookId;
  final String? volumeId;
  final String title;
  final int number;
  final String? content;
  final String? scanlatorId;
  final ScanlatorModel? scanlator;
  final String language;
  final String addedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChapterImage>? images;

  Chapter({
    required this.id,
    required this.bookId,
    this.volumeId,
    required this.title,
    required this.number,
    this.content,
    this.scanlator,
    this.scanlatorId,
    required this.language,
    required this.addedBy,
    required this.createdAt,
    required this.updatedAt,
    this.images,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    final chapterJson = json['chapter'] ?? json;
    return Chapter(
      id: chapterJson['id'],
      bookId: chapterJson['bookId'],
      volumeId: chapterJson['volumeId'],
      title: chapterJson['title'],
      number: chapterJson['number'],
      content: chapterJson['content'],
      language: chapterJson['language'],
      scanlator: json['scanlator'] != null
          ? ScanlatorModel.fromJson(json['scanlator'])
          : null,
      scanlatorId: chapterJson['scanlatorId'],
      addedBy: chapterJson['addedBy'],
      createdAt: DateTime.parse(chapterJson['createdAt']),
      updatedAt: DateTime.parse(chapterJson['updatedAt']),
      images: chapterJson['images'] != null
          ? (chapterJson['images'] as List)
                .map((imgJson) => ChapterImage.fromJson(imgJson))
                .toList()
          : null,
    );
  }
}

class ChapterImage {
  final String id;
  final String bookId;
  final String chapterId;
  final int pageNumber;
  final String imageUrl;
  final String addedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChapterImage({
    required this.id,
    required this.bookId,
    required this.chapterId,
    required this.pageNumber,
    required this.imageUrl,
    required this.addedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChapterImage.fromJson(Map<String, dynamic> json) => ChapterImage(
    id: json['id'],
    bookId: json['bookId'],
    chapterId: json['chapterId'],
    pageNumber: json['pageNumber'],
    imageUrl: json['imageUrl'],
    addedBy: json['addedBy'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

class ChaptersList {
  final String bookId;
  final List<ChapterListItem> chapters;

  ChaptersList({required this.bookId, required this.chapters});

  factory ChaptersList.fromJson(Map<String, dynamic> json) {
    return ChaptersList(
      bookId: json['bookId'],
      chapters: (json['chapters'] as List)
          .map((chapterJson) => ChapterListItem.fromJson(chapterJson))
          .toList(),
    );
  }
}

class ChapterListItem {
  final String id;
  final String bookId;
  final String? volumeId;
  final String title;
  final int number;
  final String addedBy;
  final ScanlatorModel? scanlator;
  final String language;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChapterListItem({
    required this.id,
    required this.bookId,
    this.volumeId,
    this.scanlator,
    required this.language,
    required this.title,
    required this.number,
    required this.addedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChapterListItem.fromJson(Map<String, dynamic> json) {
    return ChapterListItem(
      id: json['id'],
      bookId: json['bookId'],
      volumeId: json['volumeId'],
      title: json['title'],
      number: json['number'],
      addedBy: json['addedBy'],
      language: json['language'],
      scanlator: json['scanlator'] != null
          ? ScanlatorModel.fromJson(json['scanlator'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class Volume {
  final String id;
  final String bookId;
  final String title;
  final int number;
  final String addedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Volume({
    required this.id,
    required this.bookId,
    required this.title,
    required this.number,
    required this.addedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Volume.fromJson(Map<String, dynamic> json) {
    return Volume(
      id: json['id'],
      bookId: json['bookId'],
      title: json['title'],
      number: json['number'],
      addedBy: json['addedBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
