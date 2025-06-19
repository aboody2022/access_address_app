// lib/config/theme_config.dart
import 'package:flutter/material.dart';

class ThemeConfig {
  static bool _isDarkMode = false;

  static bool get isDarkMode => _isDarkMode;

  static void setDarkMode(bool value) {
    _isDarkMode = value;
  }

  // الألوان الأساسية
  static Color get primaryColor => isDarkMode ? Colors.tealAccent : const Color(0xFF4CB8C4);
  static Color get secondaryColor => isDarkMode ? Colors.tealAccent.shade700 : const Color(0xFF3CD3AD);
  static Color get textColor => isDarkMode ? Colors.white : Colors.black;
  static Color get inputFillColor => isDarkMode ? Colors.grey[800]! : Colors.white;

  // ألوان إضافية للتصميم
  static Color get backgroundColor => isDarkMode ? Colors.grey[900]! : Colors.grey[50]!;
  static Color get cardColor => isDarkMode ? Colors.grey[850]! : Colors.white;
  static Color get borderColor => isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
}