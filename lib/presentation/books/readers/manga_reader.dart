import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../app/injectable.dart';
import 'package:androidapp/services/chapter_service.dart';

class MangaReader extends StatefulWidget {
  final String chapterId;
  final String titleId;

  const MangaReader({
    super.key,
    required this.chapterId,
    required this.titleId,
  });

  @override
  State<MangaReader> createState() => _MangaReaderState();
}

class _MangaReaderState extends State<MangaReader> {
  final chapterService = getIt<ChapterService>();

  Map<String, dynamic>? chapterData;
  bool _loading = true;
  String _error = '';

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
        chapterData = data['chapter'];
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error.isNotEmpty) {
      return Scaffold(body: Center(child: Text('Erro: $_error')));
    }

    final images = chapterData?['images'] as List<dynamic>? ?? [];

    return Scaffold(
      body: ListView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          final image = images[index];
          return CachedNetworkImage(
            imageUrl: image['imageUrl'],
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
                const Center(child: Text('Erro ao carregar a imagem')),
            fit: BoxFit.contain,
          );
        },
      ),
    );
  }
}
