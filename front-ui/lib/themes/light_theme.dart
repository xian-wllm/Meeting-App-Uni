// ========== IMPORTS ========== //
// Flutter
import 'package:flutter/material.dart';

// ========== LIGHT THEME ========== //
class LightTheme {
  static const Color _lightPrimaryColor = Color(0xFFdb005f);
  static const Color _lightOnPrimaryColor = Color(0xFFfaf9f5);
  static const Color _lightSecondaryColor = Color(0xFFfaf9f5);
  static const Color _lightOnSecondaryColor = Color(0xFF31363a);
  static const Color _lightBackgroundColor = Color(0xFFfaf9f5);
  static const Color _lightOnBackgroundColor = Color(0xFF31363a);
  static const Color _lightErrorColor = Color(0xffB3261E);
  static const Color _lightOnErrorColor = Color(0xffFFFFFF);

  static final ThemeData data = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      primary: _lightPrimaryColor,
      secondary: _lightSecondaryColor,
      surface: _lightBackgroundColor,
      background: _lightBackgroundColor,
      error: _lightErrorColor,
      onPrimary: _lightOnPrimaryColor,
      onSecondary: _lightOnSecondaryColor,
      onSurface: _lightOnBackgroundColor,
      onBackground: _lightOnBackgroundColor,
      onError: _lightOnErrorColor,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );
}