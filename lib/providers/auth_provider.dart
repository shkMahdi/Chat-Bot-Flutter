import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoggedIn = false;

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('login') ?? false;
    notifyListeners();
  }

  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('login', true);
    isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('login');
    isLoggedIn = false;
    notifyListeners();
  }
}
