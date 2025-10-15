import 'package:flutter/material.dart';
import 'package:mgdb/services/storage_manager.dart';
import 'package:mgdb/shared/preferences.dart';

import '../../../app/injectable.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/connectivity_provider.dart';
import './widgets/settings_menu_widget.dart';

import 'package:mgdb/providers/theme_provider.dart';
import 'package:provider/provider.dart';

import 'dialogs/change_api_dialog.dart';

class SettingsApp extends StatefulWidget {
  const SettingsApp({super.key});

  @override
  State<SettingsApp> createState() => _SettingsAppState();
}

class _SettingsAppState extends State<SettingsApp> {
  final storageManager = getIt<StorageManager>();
  final _preferences = getIt<AppPreferences>();

  @override
  void initState() {
    super.initState();
  }

  Future<void> clearAllCaches() async {
    try {
      final keysToClear = [
        AppCacheKeys.imagesCache,
        AppCacheKeys.booksCache,
        AppCacheKeys.chaptersCache,
      ];

      for (final key in keysToClear) {
        await storageManager.clearCache(key);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao limpar os caches...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isConnected = context.watch<ConnectivityProvider>().isConnected;

    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 5.0, left: 20.0),
            child: Text(
              "Customização",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SettingsMenu(
            onPressed: () {
              themeProvider.toggleTheme();
            },
            buttonText: _preferences.themeMode == 'light' ? 'Claro' : 'Escuro',
            title: "Tema",
            description: "Altere o visual para o tema claro ou escuro.",
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 5.0, left: 20.0),
            child: Text(
              "Armazenamento",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SettingsMenu(
            onPressed: clearAllCaches,
            buttonText: "Limpar",
            title: "Apagar Caches",
            description: "Apaga os dados temporários, liberando espaço.",
          ),
          SettingsMenu(
            onPressed: () {
              setState(() {
                _preferences.noCache = !_preferences.noCache;
              });
            },
            buttonText: _preferences.noCache ? "Ativar" : "Desativar",
            title: "Usar Cache",
            description:
                "Armazena dados temporários para melhorar o desempenho, algumas informações podem ficar desatualizadas.",
          ),
          if (_preferences.earlyAccess)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    bottom: 5.0,
                    left: 20.0,
                  ),
                  child: Text(
                    "Desenvolvedor",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SettingsMenu(
                  onPressed: () async {
                    if (isConnected) {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => const ChangeApiDialog(),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Você está sem conexão com a internet'),
                        ),
                      );
                    }
                  },
                  buttonText: "Alterar",
                  title: "Servidor",
                  description:
                      "Endereço para conexão de dados e sincronização.",
                ),
              ],
            ),
        ],
      ),
    );
  }
}
