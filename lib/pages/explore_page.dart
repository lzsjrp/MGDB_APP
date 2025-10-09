import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:androidapp/providers/connectivity_provider.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {

    final isConnected = context.watch<ConnectivityProvider>().isConnected;

    return Scaffold(
      body: Center(
        child: Text(
          isConnected ? 'Conectado à internet' : 'Sem conexão com a internet',
        ),
      ),
    );
  }
}
