// Copyright 2026 文强哥 (Johnny520). All rights reserved.
// 企信查 Flutter 版 · 企业工商信息查询 App
import 'package:flutter/material.dart';

class Palette {
  static const primary = Color(0xFF4F7CFF);
  static const primaryDark = Color(0xFF7C5CFF);
  static const accent = Color(0xFF21D4FD);
  static const bg = Color(0xFFF4F6FB);
  static const surface = Colors.white;
  static const text = Color(0xFF1A1A1A);
  static const sub = Color(0xFF6B7280);
  static const ok = Color(0xFF2E7D32);
  static const warn = Color(0xFFEF6C00);
  static const err = Color(0xFFC62828);
  static const border = Color(0xFFE5E9F0);
}

ThemeData qxTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      color: Colors.white.withOpacity(0.72),
      elevation: 0,
      margin: EdgeInsets.zero,
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
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Palette.primary,
        side: BorderSide(color: Palette.primary.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Palette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Palette.primary, width: 1.5),
      ),
      filled: true,
      fillColor: Palette.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    dividerTheme: const DividerThemeData(color: Palette.border, thickness: 1, space: 1),
    listTileTheme: const ListTileThemeData(
      iconColor: Palette.primary,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontWeight: FontWeight.w700, color: Palette.text),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, color: Palette.text),
      bodyMedium: TextStyle(color: Palette.text, height: 1.5),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Palette.text,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white.withOpacity(0.5),
      elevation: 0,
      indicatorColor: Colors.white.withOpacity(0.55),
    ),
  );
}
