import 'package:androidapp/presentation/books/widgets/books_horizontal_listview.dart';
import 'package:flutter/material.dart';

import 'package:androidapp/presentation/books/details_page.dart';
import 'package:androidapp/presentation/settings/settings_page.dart';

import '../../app/injectable.dart';
import 'package:androidapp/services/book_service.dart';

import 'package:provider/provider.dart';
import 'package:androidapp/providers/connectivity_provider.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  bool _loading = true;
  bool _fetching = false;
  String _error = '';

  final bookService = getIt<BookService>();

  int currentPage = 1;
  bool canLoadMore = false;
  List<dynamic> newBooksList = [];

  Future<void> fetchBooks(int page, bool isConnected) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      if (isConnected) {
        var data = await bookService.getList(page.toString());
        if (!mounted) return;
        setState(() {
          newBooksList = data['data'] ?? [];
          if (data['totalPages'] > 1) {
            canLoadMore = true;
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    }

    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  Future<void> loadMoreBooks() async {
    setState(() {
      _loading = true;
    });
    try {
      final nextPage = currentPage + 1;
      var newData = await bookService.getList(nextPage.toString());
      if (!mounted) return;
      setState(() {
        currentPage = newData['page'] ?? nextPage;
        newBooksList.addAll(newData['data']);
        if (currentPage >= newData['totalPages']) {
          canLoadMore = false;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isConnected = context.watch<ConnectivityProvider>().isConnected;
    if (isConnected && !_fetching) {
      _fetching = true;
      fetchBooks(
        currentPage,
        isConnected,
      ).whenComplete(() => _fetching = false);
    } else {
      _loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<ConnectivityProvider>().isConnected;

    Map<String, List<dynamic>> categorizedBooks = {'Novos': newBooksList};

    if (!isConnected && !_loading) {
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

    if (_error.isNotEmpty) {
      return Center(child: Text(_error));
    }

    if (_loading && _fetching) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Explorar'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 16),
        children: categorizedBooks.entries.map((entry) {
          final categoryTitle = entry.key;
          final books = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0, bottom: 8.0),
                child: Text(
                  categoryTitle,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              BooksHorizontalListView(
                books: books,
                isLoading: _loading,
                onLoadMore: canLoadMore ? loadMoreBooks : null,
                onBookTap: (bookId) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookDetailsPage(bookId: bookId),
                    ),
                  );
                },
              ),
              SizedBox(height: 24),
            ],
          );
        }).toList(),
      ),
    );
  }
}
