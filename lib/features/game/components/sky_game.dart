import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../../models/rocket_skin.dart';
import '../../../providers/game_provider.dart';
import 'cloud_component.dart';
import 'particle_trail.dart';
import 'rocket_component.dart';

/// The main Flame game that renders the sky, clouds, rocket, and particles.
class SkyGame extends FlameGame {
  SkyGame({
    required this.rocketSkin,
  });

  final RocketSkin rocketSkin;

  late RocketComponent _rocket;
  final List<CloudComponent> _clouds = [];
  GamePhase _currentPhase = GamePhase.waiting;

  // Stars for background
  final List<_Star> _stars = [];
  final Random _random = Random();

  @override
  Color backgroundColor() => const Color(0xFF0D1B2A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Generate stars
    for (var i = 0; i < 60; i++) {
      _stars.add(_Star(
        x: _random.nextDouble() * size.x,
        y: _random.nextDouble() * size.y,
        radius: 0.5 + _random.nextDouble() * 1.5,
        twinkleSpeed: 1 + _random.nextDouble() * 3,
        phase: _random.nextDouble() * 3.14159 * 2,
      ));
    }

    // Spawn clouds
    for (var i = 0; i < 8; i++) {
      final cloud = CloudComponent(gameSize: size);
      _clouds.add(cloud);
      add(cloud);
    }

    // Create rocket
    _rocket = RocketComponent(skin: rocketSkin, gameSize: size);
    add(_rocket);
  }

  @override
  void render(Canvas canvas) {
    // Draw sky gradient background
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF0D1B2A),
        const Color(0xFF1B3A5C),
        const Color(0xFF2D5F8A),
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..shader = skyGradient.createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
    );

    // Draw twinkling stars
    for (final star in _stars) {
      final twinkle =
          (sin(star.phase + _starTime * star.twinkleSpeed) + 1) / 2;
      final alpha = 0.3 + twinkle * 0.7;
      canvas.drawCircle(
        Offset(star.x, star.y),
        star.radius,
        Paint()
          ..color = Colors.white.withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5),
      );
    }

    super.render(canvas);
  }

  double _starTime = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _starTime += dt;
  }

  /// Called from the Flutter widget layer to update game phase.
  void onGamePhaseChanged(GamePhase phase, double multiplier) {
    _currentPhase = phase;

    switch (phase) {
      case GamePhase.waiting:
        _rocket.stopFlying();
        _rocket.resetPosition(size);
        for (final cloud in _clouds) {
          cloud.stopScrolling();
        }
        break;

      case GamePhase.flying:
        _rocket.startFlying();
        for (final cloud in _clouds) {
          cloud.startScrolling();
        }
        break;

      case GamePhase.crashed:
        _rocket.explode();
        for (final cloud in _clouds) {
          cloud.stopScrolling();
        }
        // Spawn explosion
        add(ParticleTrailComponent(
          explosionPosition: _rocket.position.clone(),
          color1: rocketSkin.flameColor,
          color2: rocketSkin.noseColor,
        ));
        break;

      case GamePhase.cashedOut:
        // Keep flying visually but player has cashed out
        break;
    }
  }

  /// Update the rocket skin at runtime.
  void updateSkin(RocketSkin newSkin) {
    _rocket.removeFromParent();
    _rocket = RocketComponent(skin: newSkin, gameSize: size);
    add(_rocket);
    if (_currentPhase == GamePhase.flying || _currentPhase == GamePhase.cashedOut) {
      _rocket.startFlying();
    }
  }
}

class _Star {
  final double x, y, radius, twinkleSpeed, phase;

  _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.twinkleSpeed,
    required this.phase,
  });
}
