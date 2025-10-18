import 'package:mgdb/models/book_model.dart';
import 'package:mgdb/models/chapter_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:mgdb/presentation/home/books/readers/manga_reader.dart';
import '../../../providers/connectivity_provider.dart';
import './readers/web_novel_reader.dart';

import '../../../app/injectable.dart';
import 'package:mgdb/services/book_service.dart';
import 'package:mgdb/services/chapter_service.dart';
import '../../../services/favorites_service.dart';

import '../../../core/theme/widgets_themes/gridview_theme.dart';

class BookDetailsPage extends StatefulWidget {
  final String bookId;

  const BookDetailsPage({super.key, required this.bookId});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  final bookService = getIt<BookService>();
  final chapterService = getIt<ChapterService>();
  final favoritesService = getIt<FavoritesService>();
  final connectivityProvider = getIt<ConnectivityProvider>();

  late Book bookData;
  List<ChapterListItem>? chaptersData;
  bool _isFavorite = false;

  bool _loading = true;
  String _err = '';

  @override
  void initState() {
    super.initState();
    _loadBookDetails();
  }

  Future<void> _loadBookDetails() async {
    try {
      await connectivityProvider.initialized;
      final isConnected = connectivityProvider.isConnected;

      Book book;
      List<ChapterListItem>? chapters;

      if (!mounted) return;
      setState(() {
        _loading = true;
      });

      final storageBook = await bookService.getLocalTitle(widget.bookId);
      if (storageBook != null) {
        book = storageBook;
      } else {
        if (!isConnected) {
          if (!mounted) return;
          setState(() {
            _err = 'Sem conexão com a internet';
            _loading = false;
          });
          return;
        } else {
          final bookResponse = await bookService.fetchTitle(widget.bookId);
          book = bookResponse;
        }
      }

      // To-do: Offline chapters list
      if (isConnected) {
        final chaptersResponse = await chapterService.getChapters(
          widget.bookId,
        );
        chapters = chaptersResponse.chapters;
      } else {
        chapters = [];
      }

      bool isFav = await favoritesService.isFavorite(widget.bookId);

      setState(() {
        bookData = book;
        chaptersData = chapters;
        _isFavorite = isFav;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _err = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      if (_isFavorite) {
        await favoritesService.removeFavorite(widget.bookId);
      } else {
        await favoritesService.addFavorite(widget.bookId);
      }
      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao alterar os favoritos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<GridViewThemeData>()!;

    if (_loading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_err.isNotEmpty && !_loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bug_report, size: 46, color: Colors.grey),
              const SizedBox(height: 10),
              Text("Algo deu errado..."),
              const SizedBox(height: 10),
              Text(_err),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(bookData.title),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: bookData.cover != null
                        ? CachedNetworkImage(
                            imageUrl: bookData.cover!.imageUrl,
                            width: 160,
                            height: 260,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          )
                        : Container(
                            width: 160,
                            height: 260,
                            color: theme.cardBackgroundColor,
                            child: Icon(Icons.book, size: 60),
                          ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookData.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          bookData.author,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          bookData.description ?? 'Sem descrição',
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 12),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.download),
                    label: Text("Baixar"),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                    ),
                    label: Text("Favoritar"),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 13, top: 15),
              child: Text(
                'Capítulos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            if (chaptersData!.isEmpty)
              Padding(
                padding: EdgeInsets.only(left: 13, top: 5),
                child: Text(
                  'Nenhum capítulo encontrado.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: chaptersData?.length,
              itemBuilder: (context, index) {
                ChapterListItem chapter = chaptersData![index];
                final title = chapter.title;
                final number = chapter.number;
                final scanlator = chapter.scanlator?.name;

                return ListTile(
                  title: Text('Capítulo $number'),
                  subtitle: scanlator != null
                      ? Text('$title - $scanlator')
                      : Text(title),
                  onTap: () {
                    if (bookData.type == 'MANGA') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MangaReader(
                            chapterId: chapter.id,
                            titleId: bookData.id,
                          ),
                        ),
                      );
                    } else if (bookData.type == 'WEB_NOVEL') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebNovelReader(
                            chapterId: chapter.id,
                            titleId: bookData.id,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tipo de livro desconhecido'),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
