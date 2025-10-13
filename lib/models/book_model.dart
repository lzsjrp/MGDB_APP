class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String type;
  final String status;
  final String addedBy;
  final List<String> genre;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Cover? cover;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.type,
    required this.status,
    required this.addedBy,
    required this.genre,
    required this.createdAt,
    required this.updatedAt,
    required this.cover,
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'],
    title: json['title'],
    author: json['author'],
    description: json['description'],
    type: json['type'],
    status: json['status'],
    addedBy: json['addedBy'],
    genre: List<String>.from(json['genre']),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    cover: json['cover'] != null ? Cover.fromJson(json['cover']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'description': description,
    'type': type,
    'status': status,
    'addedBy': addedBy,
    'genre': genre,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'cover': cover?.toJson(),
  };
}

class Cover {
  final String id;
  final String bookId;
  final String imageUrl;
  final String addedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cover({
    required this.id,
    required this.bookId,
    required this.imageUrl,
    required this.addedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cover.fromJson(Map<String, dynamic> json) => Cover(
    id: json['id'],
    bookId: json['bookId'],
    imageUrl: json['imageUrl'],
    addedBy: json['addedBy'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookId': bookId,
    'imageUrl': imageUrl,
    'addedBy': addedBy,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class BookListResponse {
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
  final List<Book> data;

  BookListResponse({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
    required this.data,
  });

  factory BookListResponse.fromJson(Map<String, dynamic> json) {
    return BookListResponse(
      page: json['page'],
      pageSize: json['pageSize'],
      total: json['total'],
      totalPages: json['totalPages'],
      data: (json['data'] as List)
          .map((bookJson) => Book.fromJson(bookJson))
          .toList(),
    );
  }
}

class BookDefaultResponse {
  final int id;
  final int message;
  final Book book;

  BookDefaultResponse({
    required this.id,
    required this.message,
    required this.book,
  });

  factory BookDefaultResponse.fromJson(Map<String, dynamic> json) {
    return BookDefaultResponse(
      id: json['id'],
      message: json['message'],
      book: Book.fromJson(json['book']),
    );
  }
}
