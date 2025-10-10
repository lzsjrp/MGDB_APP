import 'package:androidapp/pages/books/book_page.dart';
import 'package:androidapp/controllers/book_controller.dart';
import 'package:androidapp/providers/connectivity_provider.dart';
import 'package:androidapp/pages/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  void fetchBooks(int page, bool isConnected) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      if (isConnected) {
        var data = await BookController.getList(page.toString());
        setState(() {
          booksData = data;
          currentPage = data['page'] ?? page;
        });
      }
    } catch (e) {
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
    if (isConnected) {
      fetchBooks(currentPage, isConnected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<ConnectivityProvider>().isConnected;

    if (_loading) return Center(child: CircularProgressIndicator());

    if (!isConnected) return Center(child: Text('Sem conexão com a internet'));

    if (_error.isNotEmpty) return Center(child: Text(_error));

    List<dynamic> books = booksData?['data'] ?? [];
    int totalPages = booksData?['totalPages'] ?? 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Explorar'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (books.length > 8)
            Container(
              color: Color(0xFF232A3A),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: currentPage > 1
                        ? () => fetchBooks(currentPage - 1, isConnected)
                        : null,
                    child: Text('Voltar'),
                  ),
                  SizedBox(width: 20),
                  Text('Página $currentPage/$totalPages'),
                  SizedBox(width: 20),
                  TextButton(
                    onPressed: currentPage < totalPages
                        ? () => fetchBooks(currentPage + 1, isConnected)
                        : null,
                    child: Text('Próximo'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.60,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: books.length,
              itemBuilder: (context, index) {
                var book = books[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BookDetailsPage(bookId: book['id']),
                      ),
                    );
                  },
                  child: Card(
                    color: Color(0xFF1a2231),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(10),
                          ),
                          child:
                              (book['cover'] != null &&
                                  book['cover']['imageUrl'] != null)
                              ? Container(
                                  width: double.infinity,
                                  height: 240,
                                  color: Color(0xFF232A3A),
                                  child: CachedNetworkImage(
                                    imageUrl: book['cover']['imageUrl'],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.white),
                                  ),
                                )
                              : Container(
                                  width: double.infinity,
                                  height: 240,
                                  color: Color(0xFF232A3A),
                                  child: Icon(
                                    Icons.book,
                                    color: Colors.white70,
                                    size: 40,
                                  ),
                                ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book['title'] ?? '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  book['author'] ?? '',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            color: Color(0xFF232A3A),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: currentPage > 1
                      ? () => fetchBooks(currentPage - 1, isConnected)
                      : null,
                  child: Text('Voltar'),
                ),
                SizedBox(width: 20),
                Text('Página $currentPage/$totalPages'),
                SizedBox(width: 20),
                TextButton(
                  onPressed: currentPage < totalPages
                      ? () => fetchBooks(currentPage + 1, isConnected)
                      : null,
                  child: Text('Próximo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
