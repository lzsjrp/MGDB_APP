import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/user_provider.dart';

class RegisterDialog extends StatefulWidget {
  const RegisterDialog({super.key});

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  bool _loading = false;
  String? _err;

  Future<void> _handleRegister(
    String email,
    String name,
    String password,
  ) async {
    setState(() {
      _loading = true;
    });
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.register(email: email, name: name, password: password);

    if (!mounted) return;

    if (userProvider.errorMessage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registrado com sucesso!')));
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
    final TextEditingController nameController = TextEditingController();

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
                    const Text('Registrar', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 30),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Voltar'),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();
                            final name = nameController.text.trim();

                            if (email.isEmpty ||
                                password.isEmpty ||
                                name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Dados incompletos'),
                                ),
                              );
                              return;
                            }
                            _handleRegister(email, name, password);
                          },
                          child: const Text('Registrar'),
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
