import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);

  // Background
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceLight = Color(0xFF2C2C2C);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textHint = Color(0xFF757575);

  // Chart Colors
  static const Color bullish = Color(0xFF26A69A);  // 상승 (초록)
  static const Color bearish = Color(0xFFEF5350);  // 하락 (빨강)
  static const Color neutral = Color(0xFF9E9E9E);

  // Score Colors
  static const Color scoreHigh = Color(0xFF4CAF50);    // 80-100
  static const Color scoreMediumHigh = Color(0xFF8BC34A); // 60-79
  static const Color scoreMedium = Color(0xFFFFEB3B);    // 40-59
  static const Color scoreMediumLow = Color(0xFFFF9800);  // 20-39
  static const Color scoreLow = Color(0xFFF44336);       // 0-19

  // UI Elements
  static const Color divider = Color(0xFF424242);
  static const Color border = Color(0xFF424242);
  static const Color error = Color(0xFFCF6679);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);

  // Chart Grid
  static const Color gridLine = Color(0xFF2C2C2C);
  static const Color crosshair = Color(0xFFFFFFFF);

  static Color getScoreColor(int score) {
    if (score >= 80) return scoreHigh;
    if (score >= 60) return scoreMediumHigh;
    if (score >= 40) return scoreMedium;
    if (score >= 20) return scoreMediumLow;
    return scoreLow;
  }
}
