import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';
import 'package:install_plugin/install_plugin.dart';

import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';

import './widgets/settings_menu_widget.dart';

import 'package:mgdb/providers/connectivity_provider.dart';
import 'package:provider/provider.dart';

class SettingsUpdates extends StatefulWidget {
  const SettingsUpdates({super.key});

  @override
  State<SettingsUpdates> createState() => _SettingsUpdatesState();
}

class _SettingsUpdatesState extends State<SettingsUpdates> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> checkAndUpdate() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    final dio = Dio();
    final response = await dio.get(
      'https://api.github.com/repos/lzsjrp/MGDB_APP/releases/latest',
    );
    var latestVersion = response.data['tag_name'];

    latestVersion = latestVersion.startsWith('v')
        ? latestVersion.substring(1)
        : latestVersion;

    Version latest = Version.parse(latestVersion);
    Version current = Version.parse(currentVersion);

    if (latest > current) {
      final appTempDir = await getTemporaryDirectory();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<ConnectivityProvider>().isConnected;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!isConnected) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 40, color: Colors.grey),
            SizedBox(height: 16),
            Text('Sem internet'),
          ],
        ),
      );
    }

    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 5.0, left: 20.0),
            child: Text(
              "Atualizações",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SettingsMenu(
            onPressed: checkAndUpdate,
            buttonText: "Atualizar",
            title: "Procurar por atualizações",
            description: "Procura e instala novas atualizações do aplicativo",
          ),
        ],
      ),
    );
  }
}
