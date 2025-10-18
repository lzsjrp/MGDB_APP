class ScanlatorModel {
  final String id;
  final String name;
  final String? website;
  final String? discord;
  final String? twitter;
  final List<String> languages;
  final DateTime createdAt;
  final DateTime updatedAt;

  ScanlatorModel({
    required this.id,
    required this.name,
    this.website,
    this.discord,
    this.twitter,
    required this.languages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ScanlatorModel.fromJson(Map<String, dynamic> json) {
    return ScanlatorModel(
      id: json['id'],
      name: json['name'],
      website: json['website'],
      discord: json['discord'],
      twitter: json['twitter'],
      languages: List<String>.from(json['languages'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
