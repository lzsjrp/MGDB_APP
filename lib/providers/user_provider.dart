import 'package:mgdb/models/user_model.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:mgdb/providers/connectivity_provider.dart';
import '../app/injectable.dart';

import 'package:mgdb/services/session_service.dart';

import '../services/favorites_service.dart';

@injectable
class UserProvider extends ChangeNotifier {
  final sessionService = getIt<SessionService>();
  final favoritesService = getIt<FavoritesService>();
  final connectivityProvider = getIt<ConnectivityProvider>();

  User? _userData;
  String? _errorMessage;
  bool _isLoading = false;

  User? get userData => _userData;

  String? get errorMessage => _errorMessage;

  bool get isLoading => _isLoading;

  bool get isLoggedIn => _userData != null;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await sessionService.login(email, password);
      _userData = user.session.user;

      try {
        await favoritesService.syncFavorites(merge: true);
      } catch (e) {
        // do nothing
      }
    } catch (e) {
      _errorMessage = e.toString();
      _userData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await sessionService.createUser(email, name, password);

      final user = await sessionService.login(email, password);

      _userData = user.session.user;
    } catch (e) {
      _errorMessage = e.toString();
      _userData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUser() async {
    await connectivityProvider.initialized;
    if (!connectivityProvider.isConnected) {
      final savedUserJson = await sessionService.readUser();
      if (savedUserJson != null) {
        _userData = User.fromJson(jsonDecode(savedUserJson));
      } else {
        _userData = null;
      }
      notifyListeners();
    } else {
      try {
        final jwt = await sessionService.readToken();
        if (jwt == null) {
          _userData = null;
          notifyListeners();
          return;
        }
        final user = await sessionService.getUser(jwt);
        _userData = user;
        await sessionService.saveUser(json.encode(user));
        notifyListeners();
      } catch (e) {
        _userData = null;
      }
    }
  }

  void clearUser() {
    _userData = null;
    notifyListeners();
  }
}
