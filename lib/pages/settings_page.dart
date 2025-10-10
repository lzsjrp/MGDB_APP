import 'package:flutter/material.dart';
import 'package:androidapp/widgets/settings_menu.dart';
import 'package:androidapp/providers/session_provider.dart';
import 'package:androidapp/providers/connectivity_provider.dart';
import 'package:provider/provider.dart';
import 'package:androidapp/pages/user/login_dialog.dart';

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
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Ação')));
                  },
            buttonText: userData == null ? "Login" : "Desconectar",
            title: userData == null
                ? "Você não está logado"
                : (userData['name'] ?? "Usuário"),
            description: userData == null
                ? "Descrição"
                : (userData['email'] ?? "Email"),
          ),
        ],
      ),
    );
  }
}
