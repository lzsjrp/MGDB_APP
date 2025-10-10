class ApiUrls {
  static const baseUrl = "lzsjrp-mgdb.vercel.app";
  static const apiPath = "/api";
  static const versionRoute = "/";
  static const sessionRoute = "/session";
  static const usersRoute = "/users";
  static const titleRoute = "/title";

  static String userById(String userId) {
    return "$usersRoute/$userId";
  }

  static String titleById(String titleId) {
    return "$titleRoute/$titleId";
  }

  static String titleCover(String titleId) {
    return "$titleRoute/$titleId/cover";
  }
  static String titleChapters(String titleId) {
    return "$titleRoute/$titleId/chapters";
  }

  static String titleChapterById(String titleId, String chapterId) {
    return "$titleRoute/$titleId/chapters/$chapterId";
  }
}
