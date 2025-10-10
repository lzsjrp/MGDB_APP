import 'package:androidapp/pages/books/book_page.dart';
import 'package:androidapp/controllers/book_controller.dart';
import 'package:androidapp/providers/connectivity_provider.dart';
import 'package:androidapp/pages/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:responsive_framework/responsive_framework.dart';

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
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.fromLTRB(15, 8, 15, 80),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: booksData?['data']?.length ?? 0,
                  itemBuilder: (context, index) {
                    var book = booksData['data'][index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookDetailsPage(bookId: book['id']),
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
                                        progressIndicatorBuilder:
                                            (
                                              context,
                                              url,
                                              downloadProgress,
                                            ) => Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress,
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Icon(
                                              Icons.error,
                                              color: Colors.white,
                                            ),
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
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xCC1D263A),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black45,
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
