import 'package:androidapp/controllers/book_controller.dart';
import 'package:flutter/material.dart';

class BookDetailsPage extends StatelessWidget {
  final String bookId;

  const BookDetailsPage({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Title'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Text(bookId),
    );
  }
}
