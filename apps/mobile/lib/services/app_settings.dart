import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  final SharedPreferences prefs;
  bool _darkMode;

  AppSettings(this.prefs) : _darkMode = prefs.getBool('dark_mode') ?? false;

  bool get darkMode => _darkMode;

  Future<void> setDarkMode(bool enabled) async {
    _darkMode = enabled;
    await prefs.setBool('dark_mode', enabled);
    notifyListeners();
  }
}
