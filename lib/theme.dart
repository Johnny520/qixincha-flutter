import 'package:flutter/material.dart';

class Palette {
  static const primary = Color(0xFF1565C0);
  static const primaryDark = Color(0xFF0D47A1);
  static const accent = Color(0xFF42A5F5);
  static const bg = Color(0xFFF5F7FA);
  static const card = Colors.white;
  static const text = Color(0xFF1A1A1A);
  static const sub = Color(0xFF6B7280);
  static const ok = Color(0xFF2E7D32);
  static const warn = Color(0xFFEF6C00);
  static const err = Color(0xFFC62828);
}

ThemeData qxTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Palette.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: Palette.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: Palette.card,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Palette.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}
