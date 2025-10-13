class ApiUrls {
  final String baseUrl;

  ApiUrls({required this.baseUrl});

  String get apiPath => "/api";

  String get versionRoute => apiPath;

  String get sessionRoute => "$apiPath/session";

  String get usersRoute => "$apiPath/users";

  String get titleRoute => "$apiPath/title";

  String get favoritesRoute => "$titleRoute/favorites";

  String get favoritesSyncRoute => "$favoritesRoute/sync";

  String userById(String userId) => "$usersRoute/$userId";

  String titleById(String titleId) => "$titleRoute/$titleId";

  String titleAddFavorite(String titleId) => "$titleRoute/$titleId/favorite";

  String titleCover(String titleId) => "$titleRoute/$titleId/cover";

  String titleChapters(String titleId) => "$titleRoute/$titleId/chapters";

  String titleChapterById(String titleId, String chapterId) =>
      "$titleRoute/$titleId/chapters/$chapterId";
}