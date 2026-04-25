import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';

import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import '../../../models/rocket_skin.dart';

/// Pixel-art rocket drawn with basic shapes.
/// Sways left/right with a sine wave during flight.
class RocketComponent extends PositionComponent {
  RocketComponent({
    required this.skin,
    required Vector2 gameSize,
  }) : super(
          size: Vector2(40, 70),
          anchor: Anchor.center,
        ) {
    position = Vector2(gameSize.x / 2, gameSize.y * 0.6);
    _baseX = position.x;
    _targetY = gameSize.y * 0.4;
  }

  final RocketSkin skin;
  double _baseX = 0;
  double _targetY = 0;
  double _swayTime = 0;
  bool _isFlying = false;
  bool _hasExploded = false;

  // Thrust particle accumulator
  double _particleTimer = 0;
  final List<_ThrustParticle> _thrustParticles = [];
  final Random _random = Random();

  void startFlying() {
    _isFlying = true;
    _hasExploded = false;
    _swayTime = 0;
  }

  void stopFlying() {
    _isFlying = false;
  }

  void explode() {
    _hasExploded = true;
    _isFlying = false;
  }

  void resetPosition(Vector2 gameSize) {
    position = Vector2(gameSize.x / 2, gameSize.y * 0.6);
    _baseX = position.x;
    _targetY = gameSize.y * 0.4;
    _hasExploded = false;
    _isFlying = false;
    _thrustParticles.clear();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_hasExploded) return;

    if (_isFlying) {
      _swayTime += dt;

      // Sine wave sway
      position.x = _baseX + sin(_swayTime * 2.5) * 12;

      // Smoothly move toward target Y
      position.y = lerpDouble(position.y, _targetY, dt * 0.5)!;

      // Update thrust particles
      _particleTimer += dt;
      if (_particleTimer > 0.03) {
        _particleTimer = 0;
        _spawnThrustParticle();
      }
    }

    // Update existing thrust particles
    _thrustParticles.removeWhere((p) {
      p.update(dt);
      return p.life <= 0;
    });
  }

  void _spawnThrustParticle() {
    final px = position.x + (_random.nextDouble() - 0.5) * 14;
    final py = position.y + size.y / 2 + 2;
    _thrustParticles.add(_ThrustParticle(
      x: px,
      y: py,
      vx: (_random.nextDouble() - 0.5) * 30,
      vy: 40 + _random.nextDouble() * 60,
      life: 0.3 + _random.nextDouble() * 0.4,
      color: _random.nextBool()
          ? skin.flameColor
          : skin.flameColor.withValues(alpha: 0.6),
      size: 3 + _random.nextDouble() * 4,
    ));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_hasExploded) return;

    // Draw thrust particles first (behind rocket)
    for (final p in _thrustParticles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: (p.life / p.maxLife).clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(
        Offset(p.x - position.x + size.x / 2, p.y - position.y + size.y / 2),
        p.size,
        paint,
      );
    }

    final bodyPaint = Paint()..color = skin.bodyColor;
    final nosePaint = Paint()..color = skin.noseColor;
    final finPaint = Paint()..color = skin.finColor;
    final windowPaint = Paint()..color = skin.windowColor;
    final outlinePaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // ── Body (main rectangle) ─────────────────────────────
    final bodyRect = Rect.fromLTWH(10, 18, 20, 42);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)),
      bodyPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)),
      outlinePaint,
    );

    // ── Nose Cone (triangle-ish) ──────────────────────────
    final nosePath = Path()
      ..moveTo(20, 4)
      ..lineTo(10, 18)
      ..lineTo(30, 18)
      ..close();
    canvas.drawPath(nosePath, nosePaint);
    canvas.drawPath(nosePath, outlinePaint);

    // ── Window (circle) ───────────────────────────────────
    canvas.drawCircle(const Offset(20, 30), 5, windowPaint);
    canvas.drawCircle(const Offset(20, 30), 5, outlinePaint);

    // ── Left Fin ──────────────────────────────────────────
    final leftFin = Path()
      ..moveTo(10, 50)
      ..lineTo(2, 62)
      ..lineTo(10, 60)
      ..close();
    canvas.drawPath(leftFin, finPaint);
    canvas.drawPath(leftFin, outlinePaint);

    // ── Right Fin ─────────────────────────────────────────
    final rightFin = Path()
      ..moveTo(30, 50)
      ..lineTo(38, 62)
      ..lineTo(30, 60)
      ..close();
    canvas.drawPath(rightFin, finPaint);
    canvas.drawPath(rightFin, outlinePaint);
  }
}

/// Internal thrust particle for the rocket trail.
class _ThrustParticle {
  _ThrustParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.color,
    required this.size,
  }) : maxLife = life;

  double x, y, vx, vy;
  double life;
  final double maxLife;
  final Color color;
  double size;

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    life -= dt;
    size *= 0.97;
  }
}
