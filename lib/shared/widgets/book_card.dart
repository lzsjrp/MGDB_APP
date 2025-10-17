import 'dart:io';

import 'package:mgdb/models/book_model.dart';
import 'package:flutter/material.dart';

import '../../core/theme/custom/gridview_theme.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final File? localCoverFile;
  final VoidCallback? onTap;

  const BookCard({
    super.key,
    required this.book,
    this.localCoverFile,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<GridViewThemeData>()!;

    Widget imageWidget;

    if (localCoverFile != null && localCoverFile!.existsSync()) {
      imageWidget = Image.file(localCoverFile!, fit: BoxFit.cover);
    } else if (book.cover?.imageUrl != null) {
      imageWidget = Image.network(
        book.cover!.imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: theme.cardBackgroundColor,
            child: Icon(
              Icons.book,
              color: theme.placeholderIconColor,
              size: 40,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: theme.cardBackgroundColor,
          child: Icon(Icons.book, color: theme.placeholderIconColor, size: 40),
        ),
      );
    } else {
      imageWidget = Container(
        color: theme.cardBackgroundColor,
        child: Icon(Icons.book, color: theme.placeholderIconColor, size: 40),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
        shadowColor: Colors.black45,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: imageWidget),
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
                      Colors.black.withValues(alpha: 0.9),
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
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.titleStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
