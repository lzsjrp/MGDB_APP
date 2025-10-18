
import 'package:flutter/material.dart';
import '../../app/injectable.dart';
import '../../services/book_service.dart';
import '../../services/storage_manager.dart';
import './books/book_page.dart';
import 'widgets/vertical_listview.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPage();
}

class _DownloadsPage extends State<DownloadsPage> {
  final storageManager = getIt<StorageManager>();
  final bookService = getIt<BookService>();

  List<String> downloadsBooksId = [];

  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    loadDownloads();
  }

  Future<void> loadDownloads() async {
    try {
      setState(() => _loading = true);
      final downloads = await bookService.getLocalBooksList();
      setState(() {
        downloadsBooksId = downloads;
        _loading = false;
      });
    } catch (error) {
      _error = error.toString();
      if (!mounted) return;
      setState(() {
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
    if (downloadsBooksId.isEmpty) {
      return Center(child: Text('Nenhum download encontrado'));
    }
    return Scaffold(
      body: BooksGridView(
        bookIds: downloadsBooksId.toList(),
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
