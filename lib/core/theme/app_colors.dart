import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryYellow = Color(0xFFCCF869); // #CCF869
  static const Color primaryPurple = Color(0xFF8572F8); // #8572F8
  static const Color primaryPink = Color(0xFFFF4777); // #FF4777

  // Neutral Colors
  static const Color darkGray = Color(0xFF252628); // #252628
  static const Color mediumGray = Color(0xFF4E525D); // #4E525D
  static const Color pureWhite = Color(0xFFFFFFFF); // #FFFFFF

  // Semantic Colors - Using your palette
  static const Color success = primaryYellow; // For success states
  static const Color accent = primaryPurple; // For accents
  static const Color error = primaryPink; // For errors/warnings
  static const Color warning = primaryPink; // For warnings
  static const Color info = primaryPurple; // For info

  // Background & Surface
  static const Color background = pureWhite;
  static const Color surface = pureWhite;
  static const Color surfaceDark = darkGray;

  // Text Colors
  static const Color textPrimary = darkGray;
  static const Color textSecondary = mediumGray;
  static const Color textHint = mediumGray;
  static const Color textOnPrimary = darkGray; // Text on yellow
  static const Color textOnAccent = pureWhite; // Text on purple
  static const Color textOnError = pureWhite; // Text on pink
  static const Color textOnDark = pureWhite;

  // Border & Divider
  static const Color border = mediumGray;
  static const Color divider = mediumGray;

  // Gradients (using your colors)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryYellow, primaryPurple],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, primaryPink],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryYellow, primaryPink],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkGray, mediumGray],
  );
}

// Extension for easier access (optional)
extension AppColorScheme on ColorScheme {
  Color get primaryYellow => AppColors.primaryYellow;
  Color get primaryPurple => AppColors.primaryPurple;
  Color get primaryPink => AppColors.primaryPink;
  Color get darkGray => AppColors.darkGray;
  Color get mediumGray => AppColors.mediumGray;
}
