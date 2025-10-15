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

  bool _loading = true;
  String _err = '';

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final _ = Provider.of<UserProvider>(context);
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      setState(() => _loading = true);

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
        _loading = false;
      });
    } catch (error) {
      _err = error.toString();
      setState(() {
        _loading = false;
      });
    }
  }

  Future<Map<String, File?>> loadCoversCached(List<Book> books) async {
    try {
      final Map<String, File?> coverFiles = {};
      for (var book in books) {
        final cover = book.cover;
        if (cover != null) {
          final file = await cacheManager.imageCache(cover.id, cover.imageUrl);
          coverFiles[book.id] = file;
        }
      }
      return coverFiles;
    } catch (error) {
      throw Exception('Error ${error.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_err.isNotEmpty && !_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bug_report, size: 46, color: Colors.grey),
            const SizedBox(height: 10),
            Text("Algo deu errado..."),
            const SizedBox(height: 10),
            Text('($_err)'),
          ],
        ),
      );
    }

    if (!_loading && favoriteBooksData.isEmpty) {
      return Center(child: Text('Nenhum favorito encontrado'));
    } else {
      return Scaffold(
        body: MaxWidthBox(
          maxWidth: 1200,
          child: ResponsiveScaledBox(
            width: 450,
            child: BooksGridView(
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
}
