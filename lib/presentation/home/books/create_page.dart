import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/widgets_themes/gridview_theme.dart';

class EditBookPage extends StatefulWidget {
  const EditBookPage({super.key});

  @override
  State<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _statusOptions = ['Em Andamento', 'Finalizado', 'Em Pausa'];
  String? _selectedStatus;

  String? _selectedType;
  final List<String> _types = ['MANGA', 'WEB_NOVEL'];

  File? _coverImage;

  final List<String> _availableTags = ['Tags'];

  final List<String> _selectedTags = [];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _coverImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<GridViewThemeData>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar um Título'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 170,
                      height: 273,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: theme.cardBackgroundColor,
                        image: _coverImage != null
                            ? DecorationImage(
                                image: FileImage(_coverImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _coverImage == null
                          ? const Center(
                              child: Icon(
                                Icons.add_a_photo,
                                size: 36,
                                color: Colors.grey,
                              ),
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Título',
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Obrigatório'
                              : null,
                        ),
                        const SizedBox(height: 17),

                        TextFormField(
                          controller: _authorController,
                          decoration: const InputDecoration(
                            labelText: 'Autor',
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Obrigatório'
                              : null,
                        ),
                        const SizedBox(height: 17),

                        DropdownButtonFormField<String>(
                          initialValue: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Tipo',
                          ),
                          items: _types
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedType = value),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Obrigatório'
                              : null,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              Align(alignment: Alignment.centerLeft, child: Text('Tags')),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _availableTags.map((tag) {
                  final selected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: selected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              Align(alignment: Alignment.centerLeft, child: Text('Status')),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _statusOptions.map((status) {
                  final selected = _selectedStatus == status;
                  return ChoiceChip(
                    label: Text(status),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedStatus = status);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Publicar'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Função não implementada')));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
