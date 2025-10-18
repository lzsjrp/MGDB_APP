import 'package:flutter/material.dart';

class EditBookPage extends StatefulWidget {
  const EditBookPage({super.key});

  @override
  State<EditBookPage> createState() => _EditBookPage();
}

class _EditBookPage extends State<EditBookPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Scanlator'),
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
      body: Center(child: Text("Não implementado")),
    );
  }
}
