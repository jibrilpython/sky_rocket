import 'package:flutter/material.dart';

/// Reskinnable theme configuration.
/// Swap this single file to re-theme the entire game.
class ThemeConfig {
  const ThemeConfig({
    required this.gameTitle,
    required this.tagline,
    required this.skyTopColor,
    required this.skyBottomColor,
    required this.rocketBodyColor,
    required this.rocketNoseColor,
    required this.rocketFinColor,
    required this.rocketWindowColor,
    required this.thrustColorStart,
    required this.thrustColorEnd,
    required this.bgMusicPath,
    required this.whooshPath,
    required this.explosionPath,
    required this.cashoutPath,
  });

  final String gameTitle;
  final String tagline;
  final Color skyTopColor;
  final Color skyBottomColor;
  final Color rocketBodyColor;
  final Color rocketNoseColor;
  final Color rocketFinColor;
  final Color rocketWindowColor;
  final Color thrustColorStart;
  final Color thrustColorEnd;
  final String bgMusicPath;
  final String whooshPath;
  final String explosionPath;
  final String cashoutPath;

  /// Default Sky Rocket theme.
  static const ThemeConfig defaultTheme = ThemeConfig(
    gameTitle: 'SKY ROCKET',
    tagline: 'How high can you fly?',
    skyTopColor: Color(0xFF0D1B2A),
    skyBottomColor: Color(0xFF1B3A5C),
    rocketBodyColor: Color(0xFFE0E0E0),
    rocketNoseColor: Color(0xFFE53935),
    rocketFinColor: Color(0xFFFF6B35),
    rocketWindowColor: Color(0xFF64B5F6),
    thrustColorStart: Color(0xFFFFD700),
    thrustColorEnd: Color(0xFFFF6B35),
    bgMusicPath: 'audio/bg_music.mp3',
    whooshPath: 'audio/whoosh.mp3',
    explosionPath: 'audio/explosion.mp3',
    cashoutPath: 'audio/cashout.mp3',
  );
}
