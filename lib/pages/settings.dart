import 'package:flutter/material.dart';
import 'package:androidapp/widgets/SettingsOptions.dart';
import 'package:androidapp/controllers/session_controller.dart';
import 'package:androidapp/providers/connectivity_provider.dart';
import 'package:provider/provider.dart';
import 'package:androidapp/pages/user/login_page.dart';
import 'dart:convert';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? userToken;
  Map<String, dynamic>? userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _checkUser());
  }

  Future<void> _checkUser() async {
    setState(() => _isLoading = true);

    final isConnected = context.read<ConnectivityProvider>().isConnected;

    String? token;
    Map<String, dynamic>? user;

    if (isConnected) {
      token = await SessionController().readToken();
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
    } else {
      final userJson = await SessionController().readUser();
      if (userJson != null) {
        final parsed = json.decode(userJson);
        if (parsed is Map<String, dynamic>) {
          user = parsed;
          token = await SessionController().readToken();
        } else {
          user = null;
        }
      }
    }

    setState(() {
      userToken = token;
      userData = user;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = context.read<ConnectivityProvider>().isConnected;
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 20, left: 20),
            child: Text(
              'Configurações',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SettingsOptions(
            onPressed: userToken == null
                ? () {
                    if (isConnected) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Você está sem conexão com a internet')));
                    }
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
