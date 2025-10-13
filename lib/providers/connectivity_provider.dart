import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:injectable/injectable.dart';

@injectable
class ConnectivityProvider extends ChangeNotifier {
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  late final Stream<InternetStatus> _listener;

  final Completer<void> _initCompleter = Completer<void>();

  ConnectivityProvider() {
    _init();
  }

  Future<void> get initialized => _initCompleter.future;

  void _init() async {
    _isConnected = await InternetConnection().hasInternetAccess;
    notifyListeners();

    _initCompleter.complete();

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
