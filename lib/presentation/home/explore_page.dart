import 'package:mgdb/presentation/home/books/widgets/books_horizontal_listview.dart';
import 'package:flutter/material.dart';

import 'package:mgdb/presentation/home/books/details_page.dart';
import 'package:mgdb/presentation/home/states/category.dart';

import '../../app/injectable.dart';
import 'package:mgdb/services/book_service.dart';

import 'package:provider/provider.dart';
import 'package:mgdb/providers/connectivity_provider.dart';

import '../../core/theme/custom/gridview_theme.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  Map<String, CategoryState> categories = {
    'Novos': CategoryState(),
    'Mangas': CategoryState(),
    'Light Novels': CategoryState(),
  };

  Map<String, String?> categoryType = {
    'Novos': null,
    'Mangas': 'MANGA',
    'Light Novels': 'WEB_NOVEL',
  };

  final bookService = getIt<BookService>();
  final Set<String> loadedCategories = {};

  Future<void> fetchCategory(
    String category,
    int page,
    bool isConnected,
  ) async {
    if (!mounted) return;
    setState(() {
      categories[category]!.loading = true;
      categories[category]!.error = '';
    });

    try {
      if (isConnected) {
        var type = categoryType[category];
        var bookList = await bookService.getList(
          page: page.toString(),
          type: type,
        );
        if (!mounted) return;
        setState(() {
          categories[category]!.books = bookList.data;
          categories[category]!.currentPage = bookList.page;
          categories[category]!.canLoadMore =
              bookList.totalPages > bookList.page;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        categories[category]!.error = e.toString();
      });
    }

    if (!mounted) return;
    setState(() {
      categories[category]!.loading = false;
    });
  }

  Future<void> loadMoreBooksForCategory(String category) async {
    final state = categories[category]!;
    setState(() {
      state.canLoadMore = false;
    });

    try {
      var type = categoryType[category];
      final nextPage = state.currentPage + 1;
      var bookList = await bookService.getList(
        page: nextPage.toString(),
        type: type,
      );
      if (!mounted) return;
      setState(() {
        state.books.addAll(bookList.data);
        state.currentPage = bookList.page;
        state.canLoadMore = state.currentPage < bookList.totalPages;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        state.error = e.toString();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isConnected = context.watch<ConnectivityProvider>().isConnected;
    if (isConnected) {
      categories.forEach((key, value) {
        if (value.books.isEmpty &&
            !value.loading &&
            !loadedCategories.contains(key)) {
          loadedCategories.add(key);
          fetchCategory(key, 1, isConnected);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<GridViewThemeData>()!;
    final isConnected = context.watch<ConnectivityProvider>().isConnected;

    if (!isConnected) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 40, color: Colors.grey),
            SizedBox(height: 16),
            Text('Sem internet'),
          ],
        ),
      );
    }

    return Scaffold(
      body: ListView(
        children: categories.entries.map((entry) {
          final categoryTitle = entry.key;
          final state = entry.value;

          if (state.error.isNotEmpty) {
            return Center(child: Text(state.error));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(
                  top: 10.0,
                  bottom: 10.0,
                  left: 25.0,
                ),
                child: Text(
                  categoryTitle,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              state.loading
                  ? Container(
                      width: 180,
                      height: 300,
                      margin: EdgeInsets.only(left: 15),
                      child: Card(
                        color: theme.cardBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  : BooksHorizontalListView(
                      books: state.books,
                      isLoading: state.loading,
                      onLoadMore: state.canLoadMore
                          ? () => loadMoreBooksForCategory(categoryTitle)
                          : null,
                      onBookTap: (bookId) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookDetailsPage(bookId: bookId),
                          ),
                        );
                      },
                    ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
