import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette: Blue
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color lightBlue = Color(0xFFE3F2FD);

  // Secondary Palette: Yellow
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color darkYellow = Color(0xFFFBC02D);
  static const Color lightYellow = Color(0xFFFFF8E1);

  // Dark Neutral: Black
  static const Color pitchBlack = Color(0xFF121212);
  static const Color charBlack = Color(0xFF212121);
  static const Color mutedBlack = Color(0xFF424242);

  // Light Neutral: White
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8F9FA);
  static const Color borderWhite = Color(0xFFEEEEEE);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.offWhite,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.primaryYellow,
        surface: AppColors.pureWhite,
        onPrimary: AppColors.pureWhite,
        onSecondary: AppColors.pitchBlack,
        onSurface: AppColors.pitchBlack,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.pureWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.pureWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.pureWhite,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.pureWhite,
        elevation: 2,
        shadowColor: AppColors.pitchBlack.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderWhite),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightYellow,
        selectedColor: AppColors.primaryYellow,
        secondarySelectedColor: AppColors.primaryYellow,
        labelStyle: const TextStyle(
          color: AppColors.pitchBlack,
          fontWeight: FontWeight.bold,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkYellow),
        ),
      ),
    );
  }
}
