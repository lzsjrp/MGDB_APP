import 'package:flutter/material.dart';
import 'package:androidapp/services/books_service.dart';

class CreateBookDialog extends StatefulWidget {
  const CreateBookDialog({super.key});

  @override
  State<CreateBookDialog> createState() => _CreateBookDialogState();
}

class _CreateBookDialogState extends State<CreateBookDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  String _typeController = 'WEB_NOVEL';

  bool _loading = false;
  String _error = '';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final response = await BookController.createTitle(
        _titleController.text,
        _authorController.text,
        _typeController,
      );

      if (!mounted) return;
      Navigator.of(context).pop(response);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    return AlertDialog(
      title: Text('Criar Livro'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_error),
                ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Insira o título' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Autor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Insira o autor' : null,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tipo do Título',
                  border: OutlineInputBorder(),
                ),
                initialValue: 'WEB_NOVEL',
                items: const [
                  DropdownMenuItem(value: 'MANGA', child: Text('Manga')),
                  DropdownMenuItem(
                    value: 'WEB_NOVEL',
                    child: Text('Light Novel'),
                  ),
                ],
                onChanged: (value) {
                  _typeController = value!;
                },
                validator: (value) => value == null ? 'Selecione' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: Text('Criar'),
        ),
      ],
    );
  }
}
