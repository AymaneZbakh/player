import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0B0C0E), // Slate dark backdrop
      cardColor: const Color(0xFF13161B),              // Primary item containers
      dividerColor: const Color(0xFF1E232A),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3B82F6),                    // Tech Blue accent
        secondary: Color(0xFF10B981),                  // Emerald validation accents
        surface: Color(0xFF13161B),
        background: const Color(0xFF0B0C0E),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Color(0xFFE2E8F0), fontSize: 13),
        bodySmall: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
        titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}
