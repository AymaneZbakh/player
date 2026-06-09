import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6C63FF),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0E0E10),
      cardColor: const Color(0xFF1A1A1E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0E0E10),
        elevation: 0,
      ),
    );
  }
}
