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
    final title = bookData?['title'];
    final author = bookData?['author'];

    if (_error.isNotEmpty) {
      return Center(child: Text(_error));
    }

    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
                            color: Colors.grey[300],
                          ),
                        ),
                        Text(
                          author,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[300],
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          (bookData!['description'] != null &&
                                  bookData!['description']
                                      .toString()
                                      .isNotEmpty)
                              ? bookData!['description']
                              : 'Sem descrição',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2c9163),
                      foregroundColor: Colors.white,
                      iconColor: Colors.white,
                      iconSize: 22,
                    ),
                    icon: Icon(Icons.download),
                    label: Text("Baixar"),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFad3448),
                      foregroundColor: Colors.white,
                      iconColor: Colors.white,
                      iconSize: 22,
                    ),
                    icon: Icon(Icons.favorite),
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
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                return ListTile(
                  title: Text('Capítulo ${chapter['number'] ?? '-'}'),
                  subtitle: Text(chapter['title'] ?? 'Sem título'),
                  onTap: () {},
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
