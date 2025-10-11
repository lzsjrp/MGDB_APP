import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/custom/gridview_theme.dart';

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
    final theme = Theme.of(context).extension<GridViewThemeData>()!;
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 6,
            shadowColor: Colors.black45,
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(
                  child:
                      (book['cover'] != null &&
                          book['cover']['imageUrl'] != null)
                      ? CachedNetworkImage(
                          imageUrl: book['cover']['imageUrl'],
                          fit: BoxFit.cover,
                          progressIndicatorBuilder: (context, url, progress) =>
                              Center(
                                child: CircularProgressIndicator(
                                  value: progress.progress,
                                ),
                              ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error, color: Colors.white),
                        )
                      : Container(
                          color: theme.cardBackgroundColor,
                          child: Icon(
                            Icons.book,
                            color: theme.placeholderIconColor,
                            size: 40,
                          ),
                        ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book['title'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.titleStyle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        book['author'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.authorStyle.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
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
