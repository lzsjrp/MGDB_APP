import 'package:flutter/material.dart';

import './book_card.dart';

class BooksHorizontalListView extends StatelessWidget {
  final List<dynamic> books;
  final void Function(String bookId) onBookTap;
  final bool isLoading;
  final VoidCallback? onLoadMore;

  const BooksHorizontalListView({
    super.key,
    required this.books,
    required this.onBookTap,
    this.isLoading = false,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(15, 8, 15, 8),
        scrollDirection: Axis.horizontal,
        itemCount: books.length + 1,
        itemBuilder: (context, index) {
          if (index == books.length) {
            return Container(
              width: 200,
              margin: EdgeInsets.only(right: 5),
              child: Center(
                child: isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: onLoadMore,
                        child: Text('Carregar mais'),
                      ),
              ),
            );
          }
          var book = books[index];
          return Container(
            width: 180,
            margin: EdgeInsets.only(right: 5),
            child: BookCard(
              book: book,
              onTap: () {
                onBookTap(book['id']);
              },
            ),
          );
        },
      ),
    );
  }
}
