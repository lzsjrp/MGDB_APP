import 'dart:io';

import 'package:mgdb/models/book_model.dart';
import 'package:flutter/material.dart';

import './book_card.dart';

class BooksGridView extends StatelessWidget {
  final List<Book> books;
  final Map<String, File?> coverFiles;

  final void Function(String bookId) onBookTap;

  const BooksGridView({
    super.key,
    required this.books,
    required this.onBookTap,
    required this.coverFiles,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(15, 8, 15, 80),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        var book = books[index];
        var coverFile = coverFiles[book.id];
        return BookCard(
          book: book,
          localCoverFile: coverFile,
          onTap: () {
            onBookTap(book.id);
          },
        );
      },
    );
  }
}
