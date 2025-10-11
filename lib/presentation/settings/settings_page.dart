import 'package:flutter/material.dart';

import 'package:androidapp/shared/widgets/popup_widget.dart';
import 'package:androidapp/presentation/settings/widgets/settings_menu_widget.dart';
import 'package:androidapp/presentation/settings/dialogs/login_dialog.dart';

import 'package:androidapp/providers/user_provider.dart';
import 'package:androidapp/providers/theme_provider.dart';
import 'package:androidapp/providers/connectivity_provider.dart';
import 'package:provider/provider.dart';

import '../../providers/api_config_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic>? userData;
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isConnected = context.watch<ConnectivityProvider>().isConnected;

    final userData = userProvider.userData;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
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
            buttonText: userData == null ? "Login" : "Desconectar",
            title: userData == null
                ? "Você não está logado"
                : (userData['name'] ?? "Usuário"),
            description: userData == null
                ? "Descrição"
                : (userData['email'] ?? "Email"),
          ),
          SettingsMenu(
            onPressed: () {
              themeProvider.toggleTheme();
            },
            buttonText: "Alterar",
            title: "Tema",
            description: "Alterar o tema do aplicativo",
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
                  title: Text("Customizar Servidor"),
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
            description: "Endereço do servidor para conexão",
          ),
        ],
      ),
    );
  }
}
