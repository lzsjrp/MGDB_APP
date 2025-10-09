import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  late final Stream<InternetStatus> _listener;

  ConnectivityProvider() {
    _init();
  }

  void _init() async {
    _isConnected = await InternetConnection().hasInternetAccess;
    notifyListeners();

    _listener = InternetConnection().onStatusChange;
    _listener.listen((status) {
      _isConnected = status == InternetStatus.connected;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _listener.drain();
    super.dispose();
  }
}
