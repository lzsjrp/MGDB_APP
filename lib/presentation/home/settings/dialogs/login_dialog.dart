import 'package:flutter/material.dart';

import 'package:androidapp/presentation/home/settings/dialogs/register_dialog.dart';

import 'package:provider/provider.dart';

import '../../../../providers/user_provider.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  bool _loading = false;
  String? _err;

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _loading = true;
    });
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.login(email, password);

    if (!mounted) return;

    if (userProvider.errorMessage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logado com sucesso!')));
      Navigator.pop(context);
    } else {
      setState(() {
        _loading = false;
        _err = userProvider.errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _loading
                ? [Center(child: CircularProgressIndicator())]
                : [
                    const Text('Login', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 30),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Senha'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const RegisterDialog(),
                            );
                          },
                          child: const Text('Registrar'),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();

                            if (email.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Email ou senha inválidos'),
                                ),
                              );
                              return;
                            }
                            _handleLogin(email, password);
                          },
                          child: const Text('Entrar'),
                        ),
                      ],
                    ),
                    if (_err != null) ...[
                      const SizedBox(height: 12),
                      Center(child: Text(_err!)),
                    ],
                    const SizedBox(height: 20),
                  ],
          ),
        ),
      ),
    );
  }
}
