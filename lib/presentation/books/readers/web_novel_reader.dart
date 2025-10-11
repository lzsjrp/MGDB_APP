import 'package:flutter/material.dart';

class WebNovelReader extends StatefulWidget {
  final String chapterId;

  const WebNovelReader({super.key, required this.chapterId});

  @override
  State<WebNovelReader> createState() => _WebNovelReader();
}

class _WebNovelReader extends State<WebNovelReader> {

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
