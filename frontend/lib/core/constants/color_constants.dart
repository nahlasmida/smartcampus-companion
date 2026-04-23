import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF5FC2BA);      // Teal
  static const Color secondary = Color(0xFFF1895C);    // Coral
  static const Color darkNavy = Color(0xFF0B162C);     // Deepest
  static const Color navy = Color(0xFF1C2942);         // Mid navy
  static const Color mutedBlue = Color(0xFF3B556D);    // Muted blue
  static const Color white = Color(0xFFFFFFFF);

  // Gradients
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkNavy, navy, mutedBlue],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, secondary],
  );

  // Semantic
  static const Color background = white;
  static const Color textPrimary = darkNavy;
  static const Color textSecondary = mutedBlue;
  static const Color error = Colors.redAccent;
  static const Color success = primary;
}