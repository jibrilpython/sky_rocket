import 'package:flutter/material.dart';

/// A rocket skin with customizable color scheme.
class RocketSkin {
  const RocketSkin({
    required this.id,
    required this.name,
    required this.bodyColor,
    required this.noseColor,
    required this.finColor,
    required this.windowColor,
    required this.flameColor,
  });

  final int id;
  final String name;
  final Color bodyColor;
  final Color noseColor;
  final Color finColor;
  final Color windowColor;
  final Color flameColor;

  /// All 6 available rocket skins.
  static const List<RocketSkin> allSkins = [
    RocketSkin(
      id: 0,
      name: 'Classic',
      bodyColor: Color(0xFFE0E0E0),
      noseColor: Color(0xFFE53935),
      finColor: Color(0xFFFF6B35),
      windowColor: Color(0xFF64B5F6),
      flameColor: Color(0xFFFFD700),
    ),
    RocketSkin(
      id: 1,
      name: 'Stealth',
      bodyColor: Color(0xFF37474F),
      noseColor: Color(0xFF263238),
      finColor: Color(0xFF455A64),
      windowColor: Color(0xFF00E676),
      flameColor: Color(0xFF00E5FF),
    ),
    RocketSkin(
      id: 2,
      name: 'Golden',
      bodyColor: Color(0xFFFFD700),
      noseColor: Color(0xFFFF8F00),
      finColor: Color(0xFFFFA000),
      windowColor: Color(0xFFFFFFFF),
      flameColor: Color(0xFFFF6D00),
    ),
    RocketSkin(
      id: 3,
      name: 'Neon',
      bodyColor: Color(0xFF7C4DFF),
      noseColor: Color(0xFFE040FB),
      finColor: Color(0xFF536DFE),
      windowColor: Color(0xFF18FFFF),
      flameColor: Color(0xFFFF4081),
    ),
    RocketSkin(
      id: 4,
      name: 'Arctic',
      bodyColor: Color(0xFFB3E5FC),
      noseColor: Color(0xFF0288D1),
      finColor: Color(0xFF03A9F4),
      windowColor: Color(0xFFFFFFFF),
      flameColor: Color(0xFF00BCD4),
    ),
    RocketSkin(
      id: 5,
      name: 'Inferno',
      bodyColor: Color(0xFFBF360C),
      noseColor: Color(0xFFDD2C00),
      finColor: Color(0xFFFF3D00),
      windowColor: Color(0xFFFFAB00),
      flameColor: Color(0xFFFFD600),
    ),
  ];
}
