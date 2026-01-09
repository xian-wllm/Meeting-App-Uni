// ========== IMPORTS ========== //
// Flutter
import 'package:flutter/material.dart';

// ========== DARK THEME ========== //
class DarkTheme {
  static const Color _darkPrimaryColor = Color(0xFFff2483);
  static const Color _darkOnPrimaryColor = Color.fromARGB(255, 38, 38, 53);
  static const Color _darkSecondaryColor = Color.fromARGB(255, 38, 38, 53);
  static const Color _darkOnSecondaryColor = Color(0xFFc5cace);
  static const Color _darkBackgroundColor = Color.fromARGB(255, 50, 50, 70);
  static const Color _darkOnBackgroundColor = Color(0xFFc5cace);
  static const Color _darkErrorColor = Color(0xffF2B8B5);
  static const Color _darkOnErrorColor = Color(0xff601410);

  static final ThemeData data = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      primary: _darkPrimaryColor,
      secondary: _darkSecondaryColor,
      surface: _darkBackgroundColor,
      background: _darkBackgroundColor,
      error: _darkErrorColor,
      onPrimary: _darkOnPrimaryColor,
      onSecondary: _darkOnSecondaryColor,
      onSurface: _darkOnBackgroundColor,
      onBackground: _darkOnBackgroundColor,
      onError: _darkOnErrorColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}