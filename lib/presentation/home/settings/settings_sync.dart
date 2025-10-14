import 'package:mgdb/models/user_model.dart';
import 'package:flutter/material.dart';

import 'package:mgdb/shared/widgets/popup_widget.dart';
import './widgets/settings_menu_widget.dart';
import './dialogs/login_dialog.dart';

import 'package:mgdb/providers/user_provider.dart';
import 'package:mgdb/providers/connectivity_provider.dart';
import 'package:provider/provider.dart';

import '../../../providers/api_config_provider.dart';

class SettingsSync extends StatefulWidget {
  const SettingsSync({super.key});

  @override
  State<SettingsSync> createState() => _SettingsSyncState();
}

class _SettingsSyncState extends State<SettingsSync> {
  User? userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _checkUser());
  }

  Future<void> _checkUser() async {
    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    await userProvider.loadUser();

    setState(() {
      userData = userProvider.userData;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isConnected = context.watch<ConnectivityProvider>().isConnected;

    final userData = userProvider.userData;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: ListView(
        children: [
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
                    popupWidget(context, ":(", "Não implementado");
                  },
            buttonText: userData == null ? "Login" : "Sair",
            title: userData == null ? "Você não está logado" : (userData.name),
            description: userData == null
                ? "Faça login para sincronizar seus favoritos"
                : (userData.email),
          ),
          SettingsMenu(
            onPressed: () async {
              final apiConfigProvider = Provider.of<ApiConfigProvider>(
                context,
                listen: false,
              );
              final TextEditingController controller = TextEditingController(
                text: apiConfigProvider.baseUrl,
              );
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Alterar Servidor"),
                  content: TextField(
                    controller: controller,
                    decoration: InputDecoration(labelText: "URL"),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Cancelar"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          apiConfigProvider.updateBaseUrl(
                            controller.text.trim(),
                          );
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text("Salvar"),
                    ),
                  ],
                ),
              );
            },
            buttonText: "Alterar",
            title: "Servidor",
            description: "Endereço para conexão de dados e sincronização.",
          ),
        ],
      ),
    );
  }
}
