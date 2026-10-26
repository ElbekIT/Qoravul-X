import 'package:flutter/material.dart';

enum ThemeType {
  amoledDark,
  midnightBlue,
  minimalLight,
  emeraldDark,
}

class AppPalette {
  final String name;
  final Color bgPrimary;
  final Color bgSecondary;
  final Color bgCard;
  final Color numberBg;
  final Color numberText;
  final Color operatorBg;
  final Color operatorText;
  final Color actionBg;
  final Color actionText;
  final Color equalBg;
  final Color equalText;
  final Color displayText;
  final Color displaySubText;
  final Color accent;
  final Color divider;
  final bool isDark;

  const AppPalette({
    required this.name,
    required this.bgPrimary,
    required this.bgSecondary,
    required this.bgCard,
    required this.numberBg,
    required this.numberText,
    required this.operatorBg,
    required this.operatorText,
    required this.actionBg,
    required this.actionText,
    required this.equalBg,
    required this.equalText,
    required this.displayText,
    required this.displaySubText,
    required this.accent,
    required this.divider,
    required this.isDark,
  });
}

class AppTheme {
  static const Map<ThemeType, AppPalette> palettes = {
    // 1. AMOLED Dark - Batareyani tejovchi, ko'zga juda qulay, ortiqcha neonsiz
    ThemeType.amoledDark: AppPalette(
      name: "AMOLED Qora",
      bgPrimary: Color(0xFF000000),
      bgSecondary: Color(0xFF101012),
      bgCard: Color(0xFF16161A),
      numberBg: Color(0xFF18181C),
      numberText: Color(0xFFF0F0F5),
      operatorBg: Color(0xFF262230),
      operatorText: Color(0xFFBB86FC),
      actionBg: Color(0xFF1F222A),
      actionText: Color(0xFF64B5F6),
      equalBg: Color(0xFF6200EE),
      equalText: Colors.white,
      displayText: Color(0xFFFFFFFF),
      displaySubText: Color(0xFF8E8E9F),
      accent: Color(0xFFBB86FC),
      divider: Color(0xFF202028),
      isDark: true,
    ),

    // 2. Midnight Blue - Premium sokin to'q ko'k
    ThemeType.midnightBlue: AppPalette(
      name: "Midnight Ko'k",
      bgPrimary: Color(0xFF0F172A),
      bgSecondary: Color(0xFF1E293B),
      bgCard: Color(0xFF243248),
      numberBg: Color(0xFF1E293B),
      numberText: Color(0xFFF1F5F9),
      operatorBg: Color(0xFF2A3D5D),
      operatorText: Color(0xFF38BDF8),
      actionBg: Color(0xFF1E293B),
      actionText: Color(0xFF94A3B8),
      equalBg: Color(0xFF0284C7),
      equalText: Colors.white,
      displayText: Color(0xFFF8FAFC),
      displaySubText: Color(0xFF64748B),
      accent: Color(0xFF38BDF8),
      divider: Color(0xFF334155),
      isDark: true,
    ),

    // 3. Emerald Dark - Tinchlantiruvchi zumrad-yashil
    ThemeType.emeraldDark: AppPalette(
      name: "Zumrad Qora",
      bgPrimary: Color(0xFF06140F),
      bgSecondary: Color(0xFF0F261E),
      bgCard: Color(0xFF16382C),
      numberBg: Color(0xFF10281F),
      numberText: Color(0xFFECFDF5),
      operatorBg: Color(0xFF144633),
      operatorText: Color(0xFF34D399),
      actionBg: Color(0xFF10281F),
      actionText: Color(0xFF6EE7B7),
      equalBg: Color(0xFF059669),
      equalText: Colors.white,
      displayText: Color(0xFFF0FDF4),
      displaySubText: Color(0xFF6EE7B7),
      accent: Color(0xFF10B981),
      divider: Color(0xFF1A4032),
      isDark: true,
    ),

    // 4. Minimal Light - Kunduzgi oq va toza dizayn
    ThemeType.minimalLight: AppPalette(
      name: "Minimal Oq",
      bgPrimary: Color(0xFFF8FAFC),
      bgSecondary: Color(0xFFFFFFFF),
      bgCard: Color(0xFFF1F5F9),
      numberBg: Color(0xFFF1F5F9),
      numberText: Color(0xFF0F172A),
      operatorBg: Color(0xFFE2E8F0),
      operatorText: Color(0xFF2563EB),
      actionBg: Color(0xFFE2E8F0),
      actionText: Color(0xFF475569),
      equalBg: Color(0xFF2563EB),
      equalText: Colors.white,
      displayText: Color(0xFF0F172A),
      displaySubText: Color(0xFF64748B),
      accent: Color(0xFF2563EB),
      divider: Color(0xFFCBD5E1),
      isDark: false,
    ),
  };
}
