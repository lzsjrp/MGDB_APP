import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@injectable
class FavoritesService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _keyFavorites = 'favorite_books';

  Future<Set<String>> getFavoritesSet() async {
    final jsonString = await _secureStorage.read(key: _keyFavorites);
    if (jsonString == null) return <String>{};
    final List<dynamic> list = jsonDecode(jsonString);
    return list.map((e) => e.toString()).toSet();
  }

  Future<void> _saveFavoritesSet(Set<String> favorites) async {
    final jsonString = jsonEncode(favorites.toList());
    await _secureStorage.write(key: _keyFavorites, value: jsonString);
  }

  Future<void> addFavorite(String bookId) async {
    final favorites = await getFavoritesSet();
    favorites.add(bookId);
    await _saveFavoritesSet(favorites);
  }

  Future<void> removeFavorite(String bookId) async {
    final favorites = await getFavoritesSet();
    favorites.remove(bookId);
    await _saveFavoritesSet(favorites);
  }

  Future<bool> isFavorite(String bookId) async {
    final favorites = await getFavoritesSet();
    return favorites.contains(bookId);
  }
}
