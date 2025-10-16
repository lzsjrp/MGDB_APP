import 'dart:io';

import 'package:mgdb/presentation/home/books/widgets/books_horizontal_listview.dart';
import 'package:flutter/material.dart';

import 'package:mgdb/presentation/home/books/book_page.dart';
import 'package:mgdb/presentation/home/states/category.dart';
import 'package:mgdb/services/storage_manager.dart';

import '../../app/injectable.dart';
import 'package:mgdb/services/book_service.dart';

import 'package:provider/provider.dart';
import 'package:mgdb/providers/connectivity_provider.dart';

import '../../core/theme/custom/gridview_theme.dart';
import '../../models/book_model.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final bookService = getIt<BookService>();
  final storageManager = getIt<StorageManager>();
  final Set<String> loadedCategories = {};

  bool? _isConnected;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final connectivity = context.read<ConnectivityProvider>();
      _isConnected = connectivity.isConnected;
      if (_isConnected == true) {
        await _fetchAllCategories();
      }
      if (mounted) setState(() {});
    });
  }

  Future<void> _fetchAllCategories() async {
    final isConnected = _isConnected ?? false;
    for (final entry in categories.entries) {
      if (entry.value.books.isEmpty) {
        loadedCategories.add(entry.key);
        await fetchCategory(entry.key, 1, isConnected);
      }
    }
  }

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
        final type = categoryType[category];
        final bookList = await bookService.getList(
          page: page.toString(),
          type: type,
        );

        final covers = await loadCoversCached(bookList.data);

        if (!mounted) return;
        setState(() {
          categories[category]!
            ..books = bookList.data
            ..coversFiles = covers
            ..currentPage = bookList.page
            ..canLoadMore = bookList.totalPages > bookList.page;
        });
      } else {
        setState(() {
          categories[category]!.error = "Sem conexão com a internet.";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        categories[category]!.error = e.toString();
      });
    }

    if (mounted) {
      setState(() {
        categories[category]!.loading = false;
      });
    }
  }

  Future<void> loadMoreBooksForCategory(String category) async {
    final state = categories[category]!;
    setState(() {
      state.canLoadMore = false;
    });

    try {
      final type = categoryType[category];
      final nextPage = state.currentPage + 1;
      final bookList = await bookService.getList(
        page: nextPage.toString(),
        type: type,
      );

      final covers = await loadCoversCached(bookList.data);

      if (!mounted) return;
      setState(() {
        state.books.addAll(bookList.data);
        state.coversFiles = covers;
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

  Future<Map<String, File?>> loadCoversCached(List<Book> books) async {
    final Map<String, File?> coverFiles = {};
    for (final book in books) {
      final cover = book.cover;
      if (cover != null) {
        final file = await storageManager.cachedImage(cover.id, cover.imageUrl);
        coverFiles[book.id] = file;
      }
    }
    return coverFiles;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context).extension<GridViewThemeData>()!;

    if (_isConnected == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isConnected == false) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 50, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('Sem conexão com a internet.'),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
                onPressed: () async {
                  setState(
                    () => _isConnected = context
                        .read<ConnectivityProvider>()
                        .isConnected,
                  );
                  if (_isConnected == true) {
                    await _fetchAllCategories();
                  }
                  if (mounted) setState(() {});
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: ListView(
        children: categories.entries.map((entry) {
          final categoryTitle = entry.key;
          final state = entry.value;

          if (state.error.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 46,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 10),
                    Text("Falha ao carregar: $categoryTitle"),
                    const SizedBox(height: 10),
                    Text(state.error, textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () =>
                          fetchCategory(categoryTitle, 1, _isConnected!),
                      child: const Text("Recarregar"),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 25.0, bottom: 8),
                child: Text(
                  categoryTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              state.loading
                  ? Container(
                      width: 180,
                      height: 300,
                      margin: const EdgeInsets.only(left: 15),
                      child: Card(
                        color: theme.cardBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    )
                  : BooksHorizontalListView(
                      books: state.books,
                      coverFiles: state.coversFiles ?? {},
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
