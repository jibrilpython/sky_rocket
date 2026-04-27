import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../../models/rocket_skin.dart';
import '../../../providers/game_provider.dart';
import 'cloud_component.dart';
import 'particle_trail.dart';
import 'rocket_component.dart';

/// The main Flame game — sky, nebula, stars, shooting stars, speed lines,
/// clouds, spaceship and particles.
class SkyGame extends FlameGame {
  SkyGame({required this.rocketSkin});

  final RocketSkin rocketSkin;

  late RocketComponent _rocket;
  final List<CloudComponent> _clouds = [];
  GamePhase _currentPhase = GamePhase.waiting;

  final List<_Star> _stars = [];
  final List<_ShootingStar> _shootingStars = [];
  final List<_Nebula> _nebulas = [];
  final Random _random = Random();

  double _time = 0;

  // Screen shake state
  double _shakeTime = 0;
  static const double _shakeDuration = 0.45;
  static const double _shakeIntensity = 6.0;

  // Speed line state
  final List<_SpeedLine> _speedLines = [];
  bool _showSpeedLines = false;

  @override
  Color backgroundColor() => const Color(0xFF070D18);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Nebula patches — soft colour blobs for depth
    final nebulaColors = [
      const Color(0xFF4A148C), // deep purple
      const Color(0xFF006064), // dark teal
      const Color(0xFF1A237E), // deep indigo
    ];
    for (var i = 0; i < 4; i++) {
      _nebulas.add(_Nebula(
        x: _random.nextDouble() * size.x,
        y: _random.nextDouble() * size.y,
        radiusX: 60 + _random.nextDouble() * 80,
        radiusY: 40 + _random.nextDouble() * 60,
        color: nebulaColors[_random.nextInt(nebulaColors.length)],
        opacity: 0.06 + _random.nextDouble() * 0.09,
      ));
    }

    // Stars
    for (var i = 0; i < 80; i++) {
      _stars.add(_Star(
        x: _random.nextDouble() * size.x,
        y: _random.nextDouble() * size.y,
        radius: 0.4 + _random.nextDouble() * 1.8,
        twinkleSpeed: 0.8 + _random.nextDouble() * 3,
        phase: _random.nextDouble() * pi * 2,
        bright: _random.nextDouble() < 0.15,
      ));
    }

    // Speed lines (pre-allocate)
    for (var i = 0; i < 22; i++) {
      _speedLines.add(_SpeedLine(
        x: _random.nextDouble() * size.x,
        y: _random.nextDouble() * size.y,
        speed: 400 + _random.nextDouble() * 300,
        length: 18 + _random.nextDouble() * 40,
        opacity: 0.15 + _random.nextDouble() * 0.4,
        gameHeight: size.y,
        gameWidth: size.x,
        random: _random,
      ));
    }

    // Clouds
    for (var i = 0; i < 9; i++) {
      final cloud = CloudComponent(gameSize: size);
      _clouds.add(cloud);
      add(cloud);
    }

    // Spaceship
    _rocket = RocketComponent(skin: rocketSkin, gameSize: size);
    add(_rocket);
  }

  @override
  void render(Canvas canvas) {
    // ── Sky gradient ──────────────────────────────────────
    final skyGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF070D18),
        Color(0xFF0D1B2A),
        Color(0xFF112240),
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()
        ..shader =
            skyGradient.createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
    );

    // ── Nebula patches ────────────────────────────────────
    for (final n in _nebulas) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(n.x, n.y),
          width: n.radiusX * 2,
          height: n.radiusY * 2,
        ),
        Paint()
          ..color = n.color.withValues(alpha: n.opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
      );
    }

    // ── Stars ─────────────────────────────────────────────
    for (final star in _stars) {
      final twinkle = (sin(star.phase + _time * star.twinkleSpeed) + 1) / 2;
      final alpha = star.bright ? 0.6 + twinkle * 0.4 : 0.2 + twinkle * 0.55;
      canvas.drawCircle(
        Offset(star.x, star.y),
        star.radius,
        Paint()
          ..color = Colors.white.withValues(alpha: alpha)
          ..maskFilter = star.bright
              ? const MaskFilter.blur(BlurStyle.normal, 1.5)
              : const MaskFilter.blur(BlurStyle.normal, 0.5),
      );
    }

    // ── Shooting stars ────────────────────────────────────
    for (final ss in _shootingStars) {
      final alpha = (ss.life / ss.maxLife).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.9)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(ss.x, ss.y),
        Offset(ss.x - ss.length * cos(ss.angle),
            ss.y - ss.length * sin(ss.angle)),
        paint,
      );
    }

    // ── Speed lines (flight) ──────────────────────────────
    if (_showSpeedLines) {
      for (final sl in _speedLines) {
        canvas.drawLine(
          Offset(sl.x, sl.y),
          Offset(sl.x, sl.y + sl.length),
          Paint()
            ..color = Colors.white.withValues(alpha: sl.opacity)
            ..strokeWidth = 0.8,
        );
      }
    }

    // ── Apply screen shake ────────────────────────────────
    if (_shakeTime > 0) {
      final progress = _shakeTime / _shakeDuration;
      final magnitude = _shakeIntensity * progress;
      canvas.save();
      canvas.translate(
        (_random.nextDouble() - 0.5) * 2 * magnitude,
        (_random.nextDouble() - 0.5) * 2 * magnitude,
      );
      super.render(canvas);
      canvas.restore();
    } else {
      super.render(canvas);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    // Shooting stars — spawn occasionally
    if (_random.nextDouble() < dt * 0.4) {
      _shootingStars.add(_ShootingStar(
        x: _random.nextDouble() * size.x,
        y: _random.nextDouble() * size.y * 0.5,
        angle: pi / 4 + (_random.nextDouble() - 0.5) * 0.3,
        speed: 200 + _random.nextDouble() * 300,
        length: 30 + _random.nextDouble() * 60,
        life: 0.3 + _random.nextDouble() * 0.5,
      ));
    }
    _shootingStars.removeWhere((ss) {
      ss.x += ss.speed * cos(ss.angle) * dt;
      ss.y += ss.speed * sin(ss.angle) * dt;
      ss.life -= dt;
      return ss.life <= 0;
    });

    // Speed lines
    if (_showSpeedLines) {
      for (final sl in _speedLines) {
        sl.y += sl.speed * dt;
        if (sl.y > size.y + sl.length) {
          sl.y = -sl.length;
          sl.x = _random.nextDouble() * size.x;
        }
      }
    }

    // Screen shake countdown
    if (_shakeTime > 0) {
      _shakeTime = (_shakeTime - dt).clamp(0.0, _shakeDuration);
    }
  }

  /// Called from the Flutter widget layer on every phase tick.
  void onGamePhaseChanged(GamePhase phase, double multiplier) {
    _currentPhase = phase;

    switch (phase) {
      case GamePhase.waiting:
        _rocket.stopFlying();
        _rocket.resetPosition(size);
        _showSpeedLines = false;
        for (final cloud in _clouds) {
          cloud.stopScrolling();
        }
        break;

      case GamePhase.flying:
        _rocket.startFlying();
        _showSpeedLines = true;
        for (final cloud in _clouds) {
          cloud.startScrolling();
        }
        break;

      case GamePhase.crashed:
        _rocket.explode();
        _showSpeedLines = false;
        _shakeTime = _shakeDuration; // trigger screen shake
        for (final cloud in _clouds) {
          cloud.stopScrolling();
        }
        add(ParticleTrailComponent(
          explosionPosition: _rocket.position.clone(),
          color1: rocketSkin.flameColor,
          color2: rocketSkin.noseColor,
        ));
        break;

      case GamePhase.cashedOut:
        _showSpeedLines = false;
        break;
    }
  }

  /// Update the spaceship skin at runtime.
  void updateSkin(RocketSkin newSkin) {
    _rocket.removeFromParent();
    _rocket = RocketComponent(skin: newSkin, gameSize: size);
    add(_rocket);
    if (_currentPhase == GamePhase.flying ||
        _currentPhase == GamePhase.cashedOut) {
      _rocket.startFlying();
    }
  }
}

// ────────────────────────────────────────────────────────────
// Data classes
// ────────────────────────────────────────────────────────────

class _Star {
  final double x, y, radius, twinkleSpeed, phase;
  final bool bright;
  _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.twinkleSpeed,
    required this.phase,
    required this.bright,
  });
}

class _ShootingStar {
  double x, y, life;
  final double angle, speed, length, maxLife;
  _ShootingStar({
    required this.x,
    required this.y,
    required this.angle,
    required this.speed,
    required this.length,
    required this.life,
  }) : maxLife = life;
}

class _Nebula {
  final double x, y, radiusX, radiusY, opacity;
  final Color color;
  _Nebula({
    required this.x,
    required this.y,
    required this.radiusX,
    required this.radiusY,
    required this.color,
    required this.opacity,
  });
}

class _SpeedLine {
  double x, y;
  final double speed, length, opacity;

  _SpeedLine({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
    required this.opacity,
    required double gameHeight,
    required double gameWidth,
    required Random random,
  });
}
