import 'package:flutter/material.dart';

import '../../../app/injectable.dart';

import '../../../services/favorites_service.dart';
import '../books/book_page.dart';
import 'widgets/vertical_listview.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPage();
}

class _FavoritesPage extends State<FavoritesPage> {
  final favoritesService = getIt<FavoritesService>();

  Set<String> favoriteBookIds = {};
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    loadFavoriteIds();
  }

  Future<void> loadFavoriteIds() async {
    try {
      setState(() => _loading = true);
      final ids = await favoritesService.getFavoritesSet(sync: false);
      if (!mounted) return;
      setState(() {
        favoriteBookIds = ids;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty && !_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bug_report, size: 46, color: Colors.grey),
            const SizedBox(height: 10),
            Text("Algo deu errado..."),
            const SizedBox(height: 10),
            Text(_error),
          ],
        ),
      );
    }
    if (favoriteBookIds.isEmpty) {
      return const Center(child: Text('Nenhum favorito encontrado'));
    }
    return Scaffold(
      body: BooksGridView(
        bookIds: favoriteBookIds.toList(),
        onBookTap: (bookId) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BookDetailsPage(bookId: bookId)),
          );
        },
      ),
    );
  }
}
