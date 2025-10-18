import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mgdb/providers/connectivity_provider.dart';
import 'package:mgdb/app/injectable.dart';
import 'package:mgdb/services/categories_service.dart';
import 'package:mgdb/presentation/home/widgets/horizontal_listview.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final categoriesService = getIt<CategoriesService>();
  final Map<String, List<String>> categoriesIds = {};

  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final connectivity = context.read<ConnectivityProvider>();
      final isConnected = connectivity.isConnected;
      if (isConnected == true) {
        try {
          await _fetchCategories();
          if (mounted) {
            setState(() {
              _loading = false;
            });
          }
        } catch (error) {
          if (mounted) {
            setState(() {
              _loading = false;
              _error = error.toString();
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _loading = false;
            _error = "Você está sem conexão com a internet.";
          });
        }
      }
    });
  }

  Future<void> _fetchCategories() async {
    try {
      final list = await categoriesService.getList();
      if (!mounted) return;
      setState(() {
        for (var cat in list) {
          if (cat.id == 'recently-added') {
            categoriesIds["Adicionados Recentemente"] = [];
          } else {
            categoriesIds[cat.name] = [];
          }
        }
      });
      for (var cat in list) {
        if (cat.id == 'recently-added') {
          await _fetchCategory(cat.id, "Adicionados Recentemente");
        } else {
          await _fetchCategory(cat.id, cat.name);
        }
      }
    } catch (e) {
      throw Exception('Falha ao obter as categorias ${e.toString()}');
    }
  }

  Future<void> _fetchCategory(String categoryId, String categoryName) async {
    try {
      final categoryDetail = await categoriesService.getCategory(categoryId);
      final booksIds = categoryDetail.booksIds;

      if (!mounted) return;
      setState(() {
        categoriesIds[categoryName] = booksIds;
      });
    } catch (e) {
      throw Exception(
        'Falha ao obter a categoria $categoryName: ${e.toString()}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty && !_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bug_report, size: 46, color: Colors.grey),
            const SizedBox(height: 10),
            Text("Algo deu errado..."),
            const SizedBox(height: 10),
            Text(_error),
          ],
        ),
      );
    }

    return Scaffold(
      body: ListView(
        children: categoriesIds.entries.map((entry) {
          final categoryTitle = entry.key;
          final bookIds = entry.value;
          if (bookIds.isEmpty) {
            return SizedBox.shrink();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(
                  left: 25.0,
                  bottom: 8,
                  top: 10.0,
                ),
                child: Text(
                  categoryTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ExploreListView(
                key: ValueKey('$categoryTitle-${bookIds.length}'),
                bookIds: bookIds,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
