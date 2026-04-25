import 'package:flutter/material.dart';

/// Centralized color palette for Sky Rocket.
/// Pixel-art iGaming crash-game theme.
abstract final class AppColors {
  // ── Primary Sky ────────────────────────────────────────────
  static const Color skyBlue = Color(0xFF87CEEB);
  static const Color skyDark = Color(0xFF1B3A5C);
  static const Color skyNight = Color(0xFF0D1B2A);

  // ── UI Panels ──────────────────────────────────────────────
  static const Color darkNavy = Color(0xFF1A1A2E);
  static const Color darkNavyLight = Color(0xFF25253F);
  static const Color panelBorder = Color(0xFF3A3A5C);
  static const Color surface = Color(0xFF16162B);
  static const Color surfaceLight = Color(0xFF202040);

  // ── Accents ────────────────────────────────────────────────
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentRed = Color(0xFFE53935);
  static const Color gold = Color(0xFFFFD700);
  static const Color accentPink = Color(0xFFFF6B8A);

  // ── Multiplier Chip Colors ─────────────────────────────────
  static const Color chipRed = Color(0xFFE53935);
  static const Color chipYellow = Color(0xFFFFC107);
  static const Color chipGreen = Color(0xFF4CAF50);

  // ── Text ───────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C0);
  static const Color textMuted = Color(0xFF6A6A8A);

  // ── Misc ───────────────────────────────────────────────────
  static const Color shadow = Color(0xFF0A0A1A);
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}
