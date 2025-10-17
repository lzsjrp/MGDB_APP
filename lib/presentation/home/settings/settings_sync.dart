import 'package:flutter/material.dart';
import 'package:mgdb/services/favorites_service.dart';

import '../../../app/injectable.dart';
import './widgets/settings_menu_widget.dart';
import './dialogs/login_dialog.dart';

import 'package:mgdb/providers/user_provider.dart';
import 'package:mgdb/providers/connectivity_provider.dart';
import 'package:provider/provider.dart';

class SettingsSync extends StatefulWidget {
  const SettingsSync({super.key});

  @override
  State<SettingsSync> createState() => _SettingsSyncState();
}

class _SettingsSyncState extends State<SettingsSync> {
  final favoritesService = getIt<FavoritesService>();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isConnected = context.watch<ConnectivityProvider>().isConnected;

    final userData = userProvider.userData;

    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 5.0, left: 20.0),
            child: Text(
              "Sincronização",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SettingsMenu(
            onPressed: userData == null
                ? () {
                    if (isConnected) {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => const LoginDialog(),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Você está sem conexão com a internet'),
                        ),
                      );
                    }
                  }
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Função não implementada.'),
                      ),
                    );
                  },
            buttonText: userData == null ? "Login" : "Sair",
            title: userData == null ? "Você não está logado" : (userData.name),
            description: userData == null
                ? "Faça login para sincronizar seus favoritos"
                : (userData.email),
          ),
          ?userData == null
              ? null
              : SettingsMenu(
                  onPressed: () async {
                    if (isConnected) {
                      setState(() {
                        _loading = true;
                      });
                      try {
                        await favoritesService.syncFavorites(merge: true);
                      } catch (e) {
                        // do nothing
                      }
                      setState(() {
                        _loading = false;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Você está sem conexão com a internet'),
                        ),
                      );
                    }
                  },
                  buttonText: "Sincronizar",
                  title: "Favoritos",
                  description: "Sincroniza seus favoritos com o servidor.",
                ),
        ],
      ),
    );
  }
}
