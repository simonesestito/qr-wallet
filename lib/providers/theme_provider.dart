import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode currentTheme = ThemeMode.system;

  ThemeProvider(this.currentTheme);

  // Apply a theme if is different from the current theme
  toggleTheme(ThemeMode appTheme) {
    if (appTheme != currentTheme) {
      currentTheme = appTheme;
      return notifyListeners();
    }
  }
}
