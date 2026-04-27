import 'package:flutter/material.dart';

/// A spaceship skin with customizable color scheme.
class SpaceshipSkin {
  const SpaceshipSkin({
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

  /// All 6 available spaceship skins.
  static const List<SpaceshipSkin> allSkins = [
    SpaceshipSkin(
      id: 0,
      name: 'Titan',
      bodyColor: Color(0xFFCFD8DC),
      noseColor: Color(0xFFE53935),
      finColor: Color(0xFFFF6B35),
      windowColor: Color(0xFF64B5F6),
      flameColor: Color(0xFFFFD700),
    ),
    SpaceshipSkin(
      id: 1,
      name: 'Phantom',
      bodyColor: Color(0xFF37474F),
      noseColor: Color(0xFF263238),
      finColor: Color(0xFF455A64),
      windowColor: Color(0xFF00E676),
      flameColor: Color(0xFF00E5FF),
    ),
    SpaceshipSkin(
      id: 2,
      name: 'Solaris',
      bodyColor: Color(0xFFFFD700),
      noseColor: Color(0xFFFF8F00),
      finColor: Color(0xFFFFA000),
      windowColor: Color(0xFFFFFFFF),
      flameColor: Color(0xFFFF6D00),
    ),
    SpaceshipSkin(
      id: 3,
      name: 'Nebula',
      bodyColor: Color(0xFF7C4DFF),
      noseColor: Color(0xFFE040FB),
      finColor: Color(0xFF536DFE),
      windowColor: Color(0xFF18FFFF),
      flameColor: Color(0xFFFF4081),
    ),
    SpaceshipSkin(
      id: 4,
      name: 'Frost',
      bodyColor: Color(0xFFB3E5FC),
      noseColor: Color(0xFF0288D1),
      finColor: Color(0xFF03A9F4),
      windowColor: Color(0xFFFFFFFF),
      flameColor: Color(0xFF00BCD4),
    ),
    SpaceshipSkin(
      id: 5,
      name: 'Blaze',
      bodyColor: Color(0xFFBF360C),
      noseColor: Color(0xFFDD2C00),
      finColor: Color(0xFFFF3D00),
      windowColor: Color(0xFFFFAB00),
      flameColor: Color(0xFFFFD600),
    ),
  ];
}

// Backward-compat alias so we can migrate callers incrementally.
typedef RocketSkin = SpaceshipSkin;
