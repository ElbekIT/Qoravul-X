import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors
  static const Color primaryDark = Color(0xFF0A1628);
  static const Color surfaceDark = Color(0xFF111D33);
  static const Color cardDark = Color(0xFF162240);
  static const Color cardDarkAlt = Color(0xFF1A2A4A);

  // Accent colors
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentCyan = Color(0xFF00BCD4);
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentAmber = Color(0xFFFFB300);
  static const Color accentRed = Color(0xFFF44336);
  static const Color accentOrange = Color(0xFFFF5722);

  // Text colors
  static const Color textPrimary = Color(0xFFE8ECF4);
  static const Color textSecondary = Color(0xFF8A95A8);
  static const Color textMuted = Color(0xFF5A6478);

  // Neon glow colors
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonCyan = Color(0xFF00E5FF);

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: primaryDark,
    colorScheme: const ColorScheme.dark(
      primary: accentCyan,
      secondary: accentGreen,
      surface: surfaceDark,
      error: accentRed,
      onPrimary: primaryDark,
      onSecondary: primaryDark,
      onSurface: textPrimary,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryDark,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentCyan,
        foregroundColor: primaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentCyan,
      foregroundColor: primaryDark,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: accentCyan,
      unselectedItemColor: textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF1E3050),
      thickness: 1,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 28),
      headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 24),
      headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 20),
      titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
      titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500, fontSize: 16),
      titleSmall: TextStyle(color: textSecondary, fontWeight: FontWeight.w500, fontSize: 14),
      bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
      bodySmall: TextStyle(color: textMuted, fontSize: 12),
      labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
    ),
  );

  static ThemeData get lightTheme {
    return darkTheme.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0277BD),
        secondary: Color(0xFF00C853),
        surface: Colors.white,
        error: Color(0xFFD32F2F),
      ),
    );
  }
}
