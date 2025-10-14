import 'package:flutter/material.dart';
import 'package:mgdb/services/cache_manager.dart';

import '../../../app/injectable.dart';
import '../../../core/constants/app_constants.dart';
import './widgets/settings_menu_widget.dart';

import 'package:mgdb/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsApp extends StatefulWidget {
  const SettingsApp({super.key});

  @override
  State<SettingsApp> createState() => _SettingsAppState();
}

class _SettingsAppState extends State<SettingsApp> {
  final cacheManager = getIt<CacheManager>();

  @override
  void initState() {
    super.initState();
  }

  Future<void> clearAllCaches() async {
    final keysToClear = [
      AppCacheKeys.imagesCache,
      AppCacheKeys.booksCache,
      AppCacheKeys.chaptersCache,
    ];

    for (final key in keysToClear) {
      await cacheManager.clearCache(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: ListView(
        children: [
          SettingsMenu(
            onPressed: () {
              themeProvider.toggleTheme();
            },
            buttonText: "Alterar",
            title: "Tema",
            description: "Altere o visual para o tema claro ou escuro.",
          ),
          SettingsMenu(
            onPressed: clearAllCaches,
            buttonText: "Limpar",
            title: "Apagar Caches",
            description:
                "Apaga os arquivos temporários que aceleram o app, liberando espaço.",
          ),
        ],
      ),
    );
  }
}
