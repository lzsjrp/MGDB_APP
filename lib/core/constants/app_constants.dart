class DefaultPreferences {
  static const String apiBaseUrl = "lzsjrp-mgdb.vercel.app";
  static const String theme = 'light';
  static const bool noCache = false;
}

class ApiUrls {
  final String baseUrl;

  ApiUrls({required this.baseUrl});

  String get apiPath => "/api";

  String get versionRoute => apiPath;

  String get sessionRoute => "$apiPath/session";

  String get usersRoute => "$apiPath/users";

  String get titleRoute => "$apiPath/title";

  String get categoriesRoute => "$apiPath/categories";

  String get favoritesRoute => "$apiPath/favorites";

  String manageFavorite(String titleId) => "$favoritesRoute/book/$titleId";

  String get favoritesSyncRoute => "$favoritesRoute/sync";

  String userById(String userId) => "$usersRoute/$userId";

  String titleById(String titleId) => "$titleRoute/$titleId";

  String titleCover(String titleId) => "$titleRoute/$titleId/cover";

  String titleChapters(String titleId) => "$titleRoute/$titleId/chapters";

  String titleChapterById(String titleId, String chapterId) =>
      "$titleRoute/$titleId/chapters/$chapterId";

  String categoryById(String categoryId) => "$categoriesRoute/$categoryId";

  String categoryManageBooks(String categoryId) =>
      "$categoriesRoute/$categoryId/book";
}

class AppCacheKeys {
  static const String defaultCache = 'app_cache';
  static const String imagesCache = 'images_cache';
  static const String booksCache = 'books_cache';
  static const String chaptersCache = 'chapters_cache';
}

class AppStorageKeys {
  static const String downloadsBookKey = 'downloads_books';
  static const String downloadsChapterKey = 'downloads_chapter';
  static const String favoritesKey = 'storage_favorites';
  static const String imagesKey = 'storage_images';
}
