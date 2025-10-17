import 'dart:io';

import 'package:mgdb/models/book_model.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../app/injectable.dart';
import '../../services/book_service.dart';
import '../../services/storage_manager.dart';
import './books/book_page.dart';
import 'favorites/widgets/vertical_listview.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPage();
}

class _DownloadsPage extends State<DownloadsPage> {
  final storageManager = getIt<StorageManager>();
  final bookService = getIt<BookService>();

  List<String> downloadsBooksId = [];
  Map<String, File?> coverFiles = {};
  dynamic downloadsBooksData = [];

  bool _loading = true;
  String _err = '';

  @override
  void initState() {
    super.initState();
    loadDownloads();
  }

  Future<void> loadDownloads() async {
    try {
      setState(() => _loading = true);

      final downloads = await bookService.getLocalBooksList();

      List<Book> booksDataList = [];
      for (var bookId in downloads) {
        try {
          final data = await bookService.getLocalTitle(bookId);
          if (data != null) booksDataList.add(data);
        } catch (err) {
          // Do-nothing
        }
      }

      final covers = await loadLocalCovers(booksDataList);

      setState(() {
        downloadsBooksId = downloads;
        downloadsBooksData = booksDataList;
        coverFiles = covers;
        _loading = false;
      });
    } catch (error) {
      _err = error.toString();
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<Map<String, File?>> loadLocalCovers(List<Book> books) async {
    try {
      final Map<String, File?> coverFiles = {};
      for (var book in books) {
        final cover = book.cover;
        if (cover != null) {
          final file = await storageManager.getImage(cover.id);
          coverFiles[book.id] = file;
        }
      }
      return coverFiles;
    } catch (error) {
      throw Exception('Error ${error.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_err.isNotEmpty && !_loading) {
      return Center(
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
      );
    }

    if (!_loading && downloadsBooksData.isEmpty) {
      return Center(child: Text('Nenhum download encontrado'));
    } else {
      return Scaffold(
        body: MaxWidthBox(
          maxWidth: 1200,
          child: ResponsiveScaledBox(
            width: 450,
            child: BooksGridView(
              books: downloadsBooksData,
              coverFiles: coverFiles,
              onBookTap: (bookId) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookDetailsPage(bookId: bookId),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }
  }
}
