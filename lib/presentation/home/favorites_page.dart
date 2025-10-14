import 'dart:io';

import 'package:mgdb/models/book_model.dart';
import 'package:mgdb/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../app/injectable.dart';
import '../../services/book_service.dart';
import '../../services/cache_manager.dart';
import '../../services/favorites_service.dart';
import './books/details_page.dart';
import 'books/widgets/books_gridview_list.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPage();
}

class _FavoritesPage extends State<FavoritesPage> {
  final favoritesService = getIt<FavoritesService>();
  final cacheManager = getIt<CacheManager>();
  final bookService = getIt<BookService>();

  Set<String> favoriteBookIds = {};
  dynamic favoriteBooksData = [];
  Map<String, File?> coverFiles = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context);
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    setState(() => isLoading = true);

    final favorites = await favoritesService.getFavoritesSet(sync: false);

    List<Book> booksDataList = [];
    for (var bookId in favorites) {
      try {
        final data = await bookService.getTitle(bookId);
        booksDataList.add(data);
      } catch (_) {}
    }

    final covers = await loadCoversCached(booksDataList);

    setState(() {
      favoriteBookIds = favorites;
      favoriteBooksData = booksDataList;
      coverFiles = covers;
      isLoading = false;
    });
  }

  Future<Map<String, File?>> loadCoversCached(List<Book> books) async {
    final Map<String, File?> coverFiles = {};
    for (var book in books) {
      final cover = await bookService.getCover(book.id).catchError((_) => null);
      final file = await cacheManager.downloadCoverWithCache(book.id, cover);
      coverFiles[book.id] = file;
    }
    return coverFiles;
  }

  Future<void> removeFavorite(String bookId) async {
    await favoritesService.removeFavorite(bookId);
    await loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MaxWidthBox(
        maxWidth: 1200,
        child: ResponsiveScaledBox(
          width: 450,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : favoriteBooksData.isEmpty
              ? const Center(child: Text('Nenhum favorito encontrado'))
              : BooksGridView(
                  books: favoriteBooksData,
                  coverFiles: coverFiles,
                  onBookTap: (bookId) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookDetailsPage(bookId: bookId),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
