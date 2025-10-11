class ApiUrls {
  final String baseUrl;

  ApiUrls({required this.baseUrl});

  String get apiPath => "/api";

  String get versionRoute => "/";

  String get sessionRoute => "/session";

  String get usersRoute => "/users";

  String get titleRoute => "/title";

  String userById(String userId) => "$usersRoute/$userId";

  String titleById(String titleId) => "$titleRoute/$titleId";

  String titleCover(String titleId) => "$titleRoute/$titleId/cover";

  String titleChapters(String titleId) => "$titleRoute/$titleId/chapters";

  String titleChapterById(String titleId, String chapterId) =>
      "$titleRoute/$titleId/chapters/$chapterId";
}