import 'package:flutter/material.dart';
import 'package:androidapp/presentation/settings/settings_page.dart';

import '../../../app/injectable.dart';
import '../../../services/favorites_service.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPage();
}

class _FavoritesPage extends State<FavoritesPage> {
  final favoritesService = getIt<FavoritesService>();

  Set<String> favoriteBookIds = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final favorites = await favoritesService.getFavoritesSet();
    setState(() {
      favoriteBookIds = favorites;
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
      appBar: AppBar(
        title: const Text('Favoritos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteBookIds.isEmpty
          ? const Center(child: Text('Nenhum favorito encontrado'))
          : ListView.builder(
              itemCount: favoriteBookIds.length,
              itemBuilder: (context, index) {
                final bookId = favoriteBookIds.elementAt(index);
                return ListTile(
                  title: Text(bookId),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => removeFavorite(bookId),
                  ),
                  onTap: () {},
                );
              },
            ),
    );
  }
}
