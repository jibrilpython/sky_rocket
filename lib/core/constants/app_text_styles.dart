import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized text styles for Sky Rocket.
/// Press Start 2P for pixel-style headings/multiplier.
/// Nunito for body text and UI labels.
///
/// All styles include fontFamilyFallback so text always renders
/// even if Google Fonts fails to download.
abstract final class AppTextStyles {
  /// Font family strings (resolved once).
  static final String _pixelFamily = GoogleFonts.pressStart2p().fontFamily!;
  static final String _bodyFamily = GoogleFonts.nunito().fontFamily!;

  static const List<String> _pixelFallback = ['monospace', 'Courier New'];
  static const List<String> _bodyFallback = ['sans-serif', 'Roboto', 'Helvetica'];

  // ── Pixel Font (Press Start 2P) ─────────────────────────────
  // Sizes must be multiples of 8 for clean pixel rendering.
  static TextStyle pixelLarge = TextStyle(
    fontFamily: _pixelFamily,
    fontFamilyFallback: _pixelFallback,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.gold,
  );

  static TextStyle pixelMedium = TextStyle(
    fontFamily: _pixelFamily,
    fontFamilyFallback: _pixelFallback,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle pixelSmall = TextStyle(
    fontFamily: _pixelFamily,
    fontFamilyFallback: _pixelFallback,
    fontSize: 8,
    color: AppColors.textPrimary,
  );

  static TextStyle pixelTiny = TextStyle(
    fontFamily: _pixelFamily,
    fontFamilyFallback: _pixelFallback,
    fontSize: 8,
    color: AppColors.textSecondary,
  );

  // ── Body Font (Nunito) ──────────────────────────────────────
  static TextStyle bodyLarge = TextStyle(
    fontFamily: _bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = TextStyle(
    fontFamily: _bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall = TextStyle(
    fontFamily: _bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle label = TextStyle(
    fontFamily: _bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 1.2,
  );

  static TextStyle button = TextStyle(
    fontFamily: _bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static TextStyle chipText = TextStyle(
    fontFamily: _pixelFamily,
    fontFamilyFallback: _pixelFallback,
    fontSize: 8,
    color: AppColors.textPrimary,
  );
}
