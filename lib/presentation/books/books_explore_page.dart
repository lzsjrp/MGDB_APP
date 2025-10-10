import 'package:androidapp/core/theme/app_colors.dart';
import 'package:androidapp/presentation/books/books_page.dart';
import 'package:androidapp/services/books_service.dart';
import 'package:androidapp/providers/connectivity_provider.dart';
import 'package:androidapp/presentation/settings/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'widgets/books_list_widget.dart';
import 'dialogs/books_create_dialog.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  int currentPage = 1;
  dynamic booksData;
  bool _loading = true;
  String _error = '';
  bool _fetching = false;

  Future<void> fetchBooks(int page, bool isConnected) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      if (isConnected) {
        var data = await BookController.getList(page.toString());
        if (!mounted) return;
        setState(() {
          booksData = data;
          currentPage = data['page'] ?? page;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
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

  Future<void> createTitleOperation() async {
    final result = await showDialog(
      context: context,
      builder: (_) => const CreateBookDialog(),
    );
    if (result != null) {
      final bookId = result['book']['id'];
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookDetailsPage(bookId: bookId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<ConnectivityProvider>().isConnected;

    if (!isConnected && !_loading) {
      return Center(child: Text('Sem conexão com a internet'));
    }

    if (_error.isNotEmpty) {
      return Center(child: Text(_error));
    }

    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    return MaxWidthBox(
      maxWidth: 1200,
      child: ResponsiveScaledBox(
        width: 450,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Explorar'),
            actions: [
              IconButton(icon: Icon(Icons.search), onPressed: () {}),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () async {
                  createTitleOperation();
                },
              ),
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
          body: Stack(
            children: [
              BooksGridView(
                books: booksData?['data'] ?? [],
                onBookTap: (bookId) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookDetailsPage(bookId: bookId),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: currentPage > 1
                              ? () => fetchBooks(currentPage - 1, isConnected)
                              : null,
                          child: Text('Voltar'),
                        ),
                        SizedBox(width: 20),
                        Text(
                          'Página $currentPage/${booksData?['totalPages'] ?? 1}',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        SizedBox(width: 20),
                        TextButton(
                          onPressed:
                              currentPage < (booksData?['totalPages'] ?? 1)
                              ? () => fetchBooks(currentPage + 1, isConnected)
                              : null,
                          child: Text('Próximo'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
