import 'package:flutter/material.dart';

/// 干净阅读器的主题定义：米白纸感底色 + 深灰文字，极简。
class AppTheme {
  static const Color paper = Color(0xFFF7F4ED); // 米白纸感
  static const Color ink = Color(0xFF333333); // 深灰墨色文字
  static const Color accent = Color(0xFF8A7B5D); // 低调木质/牛皮纸强调色

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        surface: paper,
        primary: ink,
      ),
      scaffoldBackgroundColor: paper,
      appBarTheme: const AppBarTheme(
        backgroundColor: paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: ink, fontSize: 17, height: 1.8),
      ),
      dividerTheme: const DividerThemeData(color: Color(0x22AC9B7D), thickness: 1),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF202020),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF202020),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: Color(0xFFC8C8C8),
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Color(0xFFC8C8C8), fontSize: 17, height: 1.8),
      ),
      dividerTheme: const DividerThemeData(color: Color(0x22FFFFFF), thickness: 1),
    );
  }
}
