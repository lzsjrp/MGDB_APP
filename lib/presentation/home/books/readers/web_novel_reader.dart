import 'package:androidapp/models/chapter_model.dart';
import 'package:flutter/material.dart';

import '../../../../app/injectable.dart';
import 'package:androidapp/services/chapter_service.dart';

class WebNovelReader extends StatefulWidget {
  final String chapterId;
  final String titleId;

  const WebNovelReader({
    super.key,
    required this.chapterId,
    required this.titleId,
  });

  @override
  State<WebNovelReader> createState() => _WebNovelReaderState();
}

class _WebNovelReaderState extends State<WebNovelReader> {
  final chapterService = getIt<ChapterService>();

  Chapter? chapterData;
  bool _loading = true;
  String _error = '';

  int? chapterNumber;
  String? content;
  List<String> lines = [''];

  bool _appBarVisible = true;

  @override
  void initState() {
    super.initState();
    _loadChapter();
  }

  Future<void> _loadChapter() async {
    try {
      final data = await chapterService.getChapter(
        widget.titleId,
        widget.chapterId,
      );
      if (!mounted) return;
      setState(() {
        chapterData = data;
        chapterNumber = chapterData?.number;
        content = chapterData?.content;
        lines = content?.split(r'\n') ?? [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _toggleAppBar() {
    setState(() {
      _appBarVisible = !_appBarVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error.isNotEmpty) {
      return Scaffold(body: Center(child: Text('Erro: $_error')));
    }

    return Scaffold(
      appBar: _appBarVisible
          ? AppBar(
              title: Text("Capítulo $chapterNumber"),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            )
          : null,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleAppBar,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: lines
                .map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      line,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
