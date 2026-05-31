import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Greens
  static const Color primaryGreen = Color(0xFF1B4332);
  static const Color mediumGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFF40916C);
  static const Color surfaceGreen = Color(0xFFD8F3DC);

  // Gold / Premium Accents
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color lightGold = Color(0xFFF0C040);
  static const Color paleGold = Color(0xFFFFF8DC);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8F9FA);
  static const Color lightGray = Color(0xFFE9ECEF);
  static const Color mediumGray = Color(0xFFADB5BD);
  static const Color darkGray = Color(0xFF495057);
  static const Color charcoal = Color(0xFF343A40);
  static const Color black = Color(0xFF212529);

  // Semantic
  static const Color error = Color(0xFFDC3545);
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF17A2B8);

  // Gradient stops
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00000000), Color(0xCC000000)],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, mediumGreen],
  );
}
