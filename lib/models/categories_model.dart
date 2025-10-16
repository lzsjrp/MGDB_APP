class Category {
  final String id;
  final String name;
  final String createdAt;
  final List<String> booksIds;
  final String updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.booksIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'],
    name: json['name'],
    booksIds: json['booksIds'],
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'booksIds': booksIds,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

class CategoriesListItem {
  final String id;
  final String name;
  final String createdAt;
  final String updatedAt;

  CategoriesListItem({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoriesListItem.fromJson(Map<String, dynamic> json) {
    return CategoriesListItem(
      id: json['id'],
      name: json['name'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
