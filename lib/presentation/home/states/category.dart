import 'dart:io';

import '../../../models/book_model.dart';

class CategoryState {
  bool loading;
  String error;
  List<Book> books;
  int currentPage;
  bool canLoadMore;

  CategoryState({
    this.loading = false,
    this.error = '',
    this.books = const [],
    this.currentPage = 1,
    this.canLoadMore = false,
  });

  Map<String, File?>? get coversFiles => null;

  set coversFiles(Map<String, File?> coversFiles) {}
}
