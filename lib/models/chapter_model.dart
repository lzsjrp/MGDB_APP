class Chapter {
  final String id;
  final String bookId;
  final String? volumeId;
  final String title;
  final int number;
  final String? content;
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

class ChapterListResponse {
  final String bookId;
  final List<ChapterListItem> chapters;

  ChapterListResponse({required this.bookId, required this.chapters});

  factory ChapterListResponse.fromJson(Map<String, dynamic> json) {
    return ChapterListResponse(
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
  final DateTime createdAt;
  final DateTime updatedAt;

  ChapterListItem({
    required this.id,
    required this.bookId,
    this.volumeId,
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
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

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
