import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';

class BooksGridView extends StatelessWidget {
  final List<dynamic> books;
  final void Function(String bookId) onBookTap;

  const BooksGridView({
    super.key,
    required this.books,
    required this.onBookTap,
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
        return GestureDetector(
          onTap: () {
            onBookTap(book['id']);
          },
          child: Card(
            color: Color(0xFF1a2231),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  child:
                      (book['cover'] != null &&
                          book['cover']['imageUrl'] != null)
                      ? Container(
                          width: double.infinity,
                          height: 240,
                          color: AppColors.secondary,
                          child: CachedNetworkImage(
                            imageUrl: book['cover']['imageUrl'],
                            fit: BoxFit.cover,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => Center(
                                  child: CircularProgressIndicator(
                                    value: downloadProgress.progress,
                                  ),
                                ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error, color: Colors.white),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 240,
                          color: AppColors.background,
                          child: Icon(
                            Icons.book,
                            color: AppColors.onPrimary,
                            size: 40,
                          ),
                        ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book['title'] ?? '',
                          style: TextStyle(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          book['author'] ?? '',
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
