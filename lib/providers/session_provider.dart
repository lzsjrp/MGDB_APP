import 'package:flutter/material.dart';
import 'package:androidapp/services/session_service.dart';
import 'dart:convert';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _userData;

  Map<String, dynamic>? get userData => _userData;

  bool get isLoggedIn => _userData != null;

  Future<void> loadUser() async {
    try {
      final jwt = await SessionController().readToken();
      if (jwt == null) {
        _userData = null;
        notifyListeners();
        return;
      }
      final user = await SessionController.getUser(jwt);
      _userData = user;
      await SessionController().saveUser(json.encode(user));
      notifyListeners();
    } catch (e) {
      final savedUserJson = await SessionController().readUser();
      if (savedUserJson != null) {
        _userData = json.decode(savedUserJson);
      } else {
        _userData = null;
      }
      notifyListeners();
    }
  }

  void clearUser() {
    _userData = null;
    notifyListeners();
  }
}