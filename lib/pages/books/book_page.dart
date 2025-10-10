import 'package:androidapp/controllers/book_controller.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookDetailsPage extends StatefulWidget {
  final String bookId;

  const BookDetailsPage({super.key, required this.bookId});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  Map<String, dynamic>? bookData;
  List<dynamic> chapters = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadBookDetails();
  }

  Future<void> _loadBookDetails() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final bookResponse = await BookController.getTitle(widget.bookId);
      final chaptersResponse = await BookController.getChapters(widget.bookId);

      setState(() {
        bookData = bookResponse['book'];
        chapters = chaptersResponse['chapters'] ?? [];
      });
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
  Widget build(BuildContext context) {
    final coverUrl = bookData?['cover']?['imageUrl'] ?? '';
    final title = bookData?['title'] ?? 'Sem título';
    final author = bookData?['author'] ?? 'Sem autor';

    return Scaffold(
      appBar: AppBar(
        title: _loading ? Text('Carregando...') : Text(title),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: coverUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: coverUrl,
                                width: 160,
                                height: 260,
                                fit: BoxFit.fill,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              )
                            : Container(
                                width: 160,
                                height: 260,
                                color: Color(0xFF232A3A),
                                child: Icon(Icons.book, size: 60),
                              ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(author, style: TextStyle(fontSize: 16)),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF29638A),
                        ),
                        icon: Icon(Icons.download),
                        label: Text('Download'),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF29638A),
                        ),
                        icon: Icon(Icons.favorite),
                        label: Text('Favoritar'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 18, top: 15),
                  child: Text(
                    'Capítulos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = chapters[index];
                      return ListTile(
                        title: Text(chapter['title'] ?? 'Sem título'),
                        subtitle: Text('Capítulo ${chapter['number'] ?? '-'}'),
                        onTap: () {},
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
