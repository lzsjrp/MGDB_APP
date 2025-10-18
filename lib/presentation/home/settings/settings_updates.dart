import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:version/version.dart';
import 'package:install_plugin/install_plugin.dart';

import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

import '../../../app/injectable.dart';
import '../../../shared/preferences.dart';
import './widgets/settings_menu_widget.dart';

import 'package:mgdb/providers/connectivity_provider.dart';

import 'dialogs/change_api_dialog.dart';

class SettingsUpdates extends StatefulWidget {
  const SettingsUpdates({super.key});

  @override
  State<SettingsUpdates> createState() => _SettingsUpdatesState();
}

class _SettingsUpdatesState extends State<SettingsUpdates> {
  final _preferences = getIt<AppPreferences>();
  final connectivityProvider = getIt<ConnectivityProvider>();

  static bool _installPermissions = true;

  String _currentVersion = '';
  String _latestVersion = '';

  bool _loading = false;
  String _progress = '';
  String _err = '';

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      final result = await Permission.requestInstallPackages.status;
      setState(() {
        _installPermissions = result == PermissionStatus.granted;
      });
    } catch (error) {
      _err = 'Falha ao verificar as permissões do aplicativo';
    }
  }

  Future<void> _requestPermissions() async {
    try {
      await Permission.requestInstallPackages.request();

      if (!mounted) return;
      _checkPermissions();
    } catch (error) {
      _err = 'Falha ao solicitar as permissões do aplicativo';

      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> checkAndUpdate() async {
    try {
      await connectivityProvider.initialized;
      if (!connectivityProvider.isConnected) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sem conexão com a internet.')),
        );
      }

      if (!mounted) return;
      setState(() {
        _loading = true;
      });

      final releasesRepo = _preferences.releasesRepo;
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final dio = Dio();

      String latestVersion = '';
      Response? releaseResponse;

      final releaseStableResponse = await dio.get(
        'https://api.github.com/repos/$releasesRepo/releases/latest',
      );
      final latestStableVersionRaw = releaseStableResponse.data['tag_name'];
      final latestStableVersion = latestStableVersionRaw.startsWith('v')
          ? latestStableVersionRaw.substring(1)
          : latestStableVersionRaw;

      Map<String, dynamic>? earlyRelease;
      String? latestEarlyVersion;

      final releasesResponse = await dio.get(
        'https://api.github.com/repos/$releasesRepo/releases',
      );
      final releases = releasesResponse.data as List;

      final preRelease = releases.firstWhere(
        (r) => r['prerelease'] == true && r['draft'] == false,
        orElse: () => null,
      );

      if (preRelease != null) {
        latestEarlyVersion = preRelease['tag_name'];
        latestEarlyVersion = latestEarlyVersion!.startsWith('v')
            ? latestEarlyVersion.substring(1)
            : latestEarlyVersion;

        final assetsUrl = preRelease['assets_url'];
        final assetsResponse = await dio.get(assetsUrl);
        earlyRelease = {...preRelease, 'assets': assetsResponse.data};
      }

      final stable = Version.parse(latestStableVersion);
      final early = latestEarlyVersion != null
          ? Version.parse(latestEarlyVersion)
          : null;

      bool useEarly = false;
      if (_preferences.earlyAccess && early != null && early > stable) {
        useEarly = true;
      }

      latestVersion = useEarly ? latestEarlyVersion! : latestStableVersion;
      releaseResponse = useEarly
          ? Response(
              requestOptions: RequestOptions(path: ''),
              data: earlyRelease,
            )
          : releaseStableResponse;

      setState(() {
        _currentVersion = currentVersion;
        _latestVersion = latestVersion;
      });

      final latest = Version.parse(latestVersion);
      final current = Version.parse(currentVersion);

      if (latest > current) {
        final assets = releaseResponse.data['assets'] as List;
        if (assets.isEmpty) throw Exception('Nenhum arquivo encontrado.');

        final asset = assets.firstWhere(
          (a) => a['name'].endsWith('.apk'),
          orElse: () => assets.first,
        );

        final downloadUrl = asset['browser_download_url'];
        final fileName = asset['name'];

        final downloadsDir = await getDownloadsDirectory();
        final savePath = '${downloadsDir!.path}/$fileName';

        await dio.download(
          downloadUrl,
          savePath,
          onReceiveProgress: (count, total) {
            if (total != -1) {
              final progress = (count / total * 100).toStringAsFixed(0);
              if (!mounted) return;
              setState(() {
                _progress = 'Baixando atualização... $progress%';
              });
            }
          },
        );

        await InstallPlugin.installApk(savePath);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhuma atualização disponível')),
        );
      }

      setState(() {
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao verificar por atualizações')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<ConnectivityProvider>().isConnected;

    if (!_installPermissions) {
      return Scaffold(
        body: AlertDialog(
          title: const Text('Permissão necessária'),
          content: const Text(
            'Para atualizar, autorize o aplicativo a instalar pacotes nas configurações.',
          ),
          actions: [
            TextButton(
              onPressed: () => _requestPermissions(),
              child: const Text('Abrir configurações'),
            ),
          ],
        ),
      );
    }

    if (_loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              if (_progress.isNotEmpty) Text(_progress),
            ],
          ),
        ),
      );
    }

    if (_err.isNotEmpty && !_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bug_report, size: 46, color: Colors.grey),
            const SizedBox(height: 10),
            Text("Algo deu errado..."),
            const SizedBox(height: 10),
            Text('($_err)'),
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
            description: "Procura por novas atualizações e instala se disponível",
          ),
          if (_currentVersion.isNotEmpty && _latestVersion.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Versão Atual: $_currentVersion",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    "Ultima Versão: $_latestVersion",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          SizedBox(height: 10),
          SettingsMenu(
            onPressed: () {
              setState(() {
                _preferences.earlyAccess = !_preferences.earlyAccess;
              });
            },
            buttonText: !_preferences.earlyAccess ? "Ativar" : "Desativar",
            title: "Acesso Antecipado",
            description:
                "Permite atualizações de versões em testes e ativa recursos experimentais",
          ),
          if (_preferences.earlyAccess)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10.0,
                    bottom: 10.0,
                    left: 20.0,
                  ),
                  child: Text(
                    "Desenvolvimento",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SettingsMenu(
                  onPressed: () async {
                    if (isConnected) {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => const ChangeApiDialog(),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Você está sem conexão com a internet'),
                        ),
                      );
                    }
                  },
                  buttonText: "Alterar",
                  title: "Servidor",
                  description:
                      "Endereço usado para dados de títulos, autenticação e sincronização",
                ),
                SettingsMenu(
                  onPressed: () async {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Função não implementada.')),
                    );
                  },
                  buttonText: "Alterar",
                  title: "Repositório (GitHub)",
                  description:
                      "Repositório do GitHub para procurar e instalar novas atualizações",
                ),
              ],
            ),
        ],
      ),
    );
  }
}
