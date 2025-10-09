import 'package:flutter/material.dart';
import 'package:androidapp/widgets/SettingsOptions.dart';
import 'package:androidapp/controllers/session_controller.dart';
import 'package:androidapp/pages/user/login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? userToken;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    String? token = await SessionController().readToken();
    setState(() {
      userToken = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configurações")),
      body: ListView(
        children: [
          SettingsOptions(
            onPressed: userToken == null
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  }
                : () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Ação')));
                  },
            buttonText: userToken == null ? "Logar" : "Deslogar",
            title: userToken == null
                ? "Você não está logado"
                : "Usuário logado",
            description: "Descrição",
          ),
          SettingsOptions(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Ação')));
            },
            buttonText: "Ação",
            title: "Configuração 2",
            description: "Descrição",
          ),
          SettingsOptions(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Ação')));
            },
            buttonText: "Ação",
            title: "Configuração 1",
            description: "Descrição",
          ),
        ],
      ),
    );
  }
}
