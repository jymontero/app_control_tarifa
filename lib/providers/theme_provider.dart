import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  // Dark por defecto — coherente con todo el diseño Dark Premium
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setDark() {
    _themeMode = ThemeMode.dark;
    notifyListeners();
  }

  void setLight() {
    _themeMode = ThemeMode.light;
    notifyListeners();
  }
}
