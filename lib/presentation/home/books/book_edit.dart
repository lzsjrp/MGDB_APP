import 'package:flutter/material.dart';

class EditBookPage extends StatelessWidget {
  const EditBookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Center(child: Text("Body")),
    );
  }
}
