import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mgdb/models/book_model.dart';
import 'package:mgdb/services/book_service.dart';
import 'package:mgdb/services/storage_manager.dart';
import 'package:mgdb/app/injectable.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/custom/gridview_theme.dart';
import '../../../../providers/connectivity_provider.dart';
import '../../../../shared/widgets/book_card.dart';
import '../../books/book_page.dart';

class ExploreListView extends StatefulWidget {
  final List<String> bookIds;

  const ExploreListView({super.key, required this.bookIds});

  @override
  State<ExploreListView> createState() => _ExploreListView();
}

class _ExploreListView extends State<ExploreListView> {
  final bookService = getIt<BookService>();
  final storageManager = getIt<StorageManager>();

  final Map<String, Book> booksData = {};
  final Map<String, File?> coverFiles = {};

  List<String> _lastIds = const [];

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  @override
  void didUpdateWidget(covariant ExploreListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(_lastIds, widget.bookIds)) {
      _lastIds = List<String>.from(widget.bookIds);
      booksData.clear();
      coverFiles.clear();
      _fetchBooks();
    }
  }

  Future<void> _fetchBookData(String id) async {
    Book? book;
    try {
      final localData = await bookService.getLocalTitle(id);
      if (localData == null) {
        final fetchData = await bookService.fetchTitle(id);
        book = fetchData;
      } else {
        book = localData;
      }
      File? cover;
      if (book.cover != null) {
        final localCover = await storageManager.getImage(book.cover!.id);
        if (localCover != null) {
          cover = await storageManager.cachedImage(
            book.cover!.id,
            book.cover!.imageUrl,
          );
        } else {
          cover = localCover;
        }
      }
      if (!mounted) return;
      setState(() {
        booksData[id] = book!;
        coverFiles[id] = cover;
      });
    } catch (_) {}
  }

  Future<void> _fetchBooks() async {
    const batch = 2;
    for (var i = 0; i < widget.bookIds.length; i += batch) {
      final slice = widget.bookIds.skip(i).take(batch);
      await Future.wait(slice.map(_fetchBookData));
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<GridViewThemeData>()!;
    final isConnected = context.watch<ConnectivityProvider>().isConnected;

    return SizedBox(
      height: 300,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
        scrollDirection: Axis.horizontal,
        itemCount: widget.bookIds.length,
        itemBuilder: (context, index) {
          final id = widget.bookIds[index];
          final book = booksData[id];
          final cover = coverFiles[id];
          if (isConnected && book == null) {
            return Container(
              key: ValueKey('book-skeleton-$id'),
              width: 180,
              height: 300,
              margin: const EdgeInsets.only(right: 8),
              child: Card(
                color: theme.cardBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          } else if (book == null) {
            return Container(
              key: ValueKey('book-offline-$id'),
              width: 180,
              height: 300,
              margin: const EdgeInsets.only(right: 8),
              child: Card(
                color: theme.cardBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.signal_wifi_statusbar_connected_no_internet_4,
                    size: 30,
                    color: Colors.grey,
                  ),
                ),
              ),
            );
          }
          return Container(
            key: ValueKey('book-$id'),
            width: 180,
            margin: const EdgeInsets.only(right: 8),
            child: BookCard(
              book: book,
              localCoverFile: cover,
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookDetailsPage(bookId: id),
                  ),
                ),
              },
            ),
          );
        },
      ),
    );
  }
}
