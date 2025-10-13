import 'package:androidapp/models/book_model.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../app/injectable.dart';
import '../../services/book_service.dart';
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
  final bookService = getIt<BookService>();

  Set<String> favoriteBookIds = {};
  dynamic favoriteBooksData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    setState(() {
      isLoading = true;
    });
    final favorites = await favoritesService.getFavoritesSet(sync: false);

    List<Book> booksDataList = [];
    for (var bookId in favorites) {
      try {
        final data = await bookService.getTitle(bookId);
        booksDataList.add(data);
      } catch (e) {
        // Do nothing
      }
    }

    setState(() {
      favoriteBookIds = favorites;
      favoriteBooksData = booksDataList;
      isLoading = false;
    });
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
