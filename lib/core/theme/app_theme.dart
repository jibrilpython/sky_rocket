import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// App-wide dark theme for Sky Rocket.
abstract final class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkNavy,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentOrange,
        secondary: AppColors.accentGreen,
        error: AppColors.accentRed,
        surface: AppColors.surface,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkNavyLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.panelBorder, width: 1.5),
        ),
        elevation: 4,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentOrange,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 6,
          shadowColor: AppColors.shadow,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 24,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.accentOrange,
        inactiveTrackColor: AppColors.panelBorder,
        thumbColor: AppColors.accentOrange,
        overlayColor: Color(0x33FF6B35),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.panelBorder, width: 1.5),
        ),
      ),
    );
  }
}
