import 'package:flutter/material.dart';

class MangaReader extends StatefulWidget {
  final String chapterId;

  const MangaReader({super.key, required this.chapterId});

  @override
  State<MangaReader> createState() => _MangaReader();
}

class _MangaReader extends State<MangaReader> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(widget.chapterId)),
    );
  }
}
