import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _password;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _loadPassword();
  }

  Future<void> _loadPassword() async {
    final prefs = await SharedPreferences.getInstance();
    _password = prefs.getString('password');
    notifyListeners();
  }

  Future<void> setPassword(String password) async {
    _password = password;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', password);
    notifyListeners();
  }

  bool authenticate(String password) {
    if (_password == null || _password!.isEmpty) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    _isAuthenticated = _password == password;
    notifyListeners();
    return _isAuthenticated;
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }

  bool hasPassword() {
    return _password != null && _password!.isNotEmpty;
  }
}
