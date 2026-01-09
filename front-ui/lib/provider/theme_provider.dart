// ========== IMPORTS ========== //
// Flutter
import 'package:flutter/material.dart';

// Themes
import 'package:Spark/themes/dark_theme.dart';
import 'package:Spark/themes/light_theme.dart';

// ========== THEME PROVIDER ========== //
class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = LightTheme.data;

  ThemeData get themeData => _themeData;

  void toggleTheme() {
    if (_themeData.brightness == Brightness.dark) {
      _themeData = LightTheme.data;
    } else {
      _themeData = DarkTheme.data;
    }
    notifyListeners(); 
  }

  void setTheme(ThemeData theme) {
    _themeData = theme;
    notifyListeners(); 
  }
}