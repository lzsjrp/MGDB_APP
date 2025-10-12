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

  int? chapterNumber;

  late PageController _pageController;
  int _currentPage = 0;
  bool _appBarVisible = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadChapter();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        chapterNumber = chapterData?['number'];
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

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextPage() {
    final images = chapterData?['images'] as List<dynamic>? ?? [];
    if (_currentPage < images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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

    final images = chapterData?['images'] as List<dynamic>? ?? [];

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
        child: PageView.builder(
          controller: _pageController,
          reverse: true,
          itemCount: images.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            final image = images[index];
            return InteractiveViewer(
              minScale: 1.0,
              maxScale: 5.0,
              child: CachedNetworkImage(
                imageUrl: image['imageUrl'],
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    const Center(child: Text('Erro ao carregar a imagem')),
                fit: BoxFit.contain,
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _appBarVisible
          ? SafeArea(
              child: SizedBox(
                height: 60,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _goToNextPage,
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text('Próximo'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _goToPreviousPage,
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text('Voltar'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
