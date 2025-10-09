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
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    String? token = await SessionController().readToken();

    Map<String, dynamic>? user;
    if (token != null) {
      try {
        final response = await SessionController.getUser(token);
        if (response is Map<String, dynamic>) {
          user = response;
        }
      } catch (e) {
        user = null;
      }
    }

    setState(() {
      userToken = token;
      userData = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 20),
            child: const Text(
              'Configurações',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
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
            buttonText: userToken == null ? "Login" : "Desconectar",
            title: userToken == null
                ? "Você não está logado"
                : (userData?['name'] ?? "Usuário"),
            description: userToken == null
                ? "Descrição"
                : (userData?['email'] ?? "Email"),
          ),
        ],
      ),
    );
  }
}
