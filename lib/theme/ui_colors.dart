import 'package:flutter/material.dart';

class UiColors {
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color cardLight = Colors.white;
  static const Color sidebarLight = Colors.white;
  static const Color outlineLight = Color(0xFFE2E8F0);
  static const Color accent = Color(0xFF4F46E5); // Indigo 600
  static const Color accentHover = Color(0xFF4338CA);
  static const Color danger = Color(0xFFDC2626);

  static const Color bgDark = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color sidebarDark = Color(0xFF0F172A);
  static const Color outlineDark = Color(0xFF334155);

  static Color groupColor(String c) {
    switch (c) {
      case 'blue': return Colors.blue;
      case 'pink': return Colors.pink;
      case 'amber': return Colors.amber;
      case 'green': return Colors.green;
      case 'purple': return Colors.purple;
      case 'red': return Colors.red;
      default: return Colors.grey;
    }
  }
}