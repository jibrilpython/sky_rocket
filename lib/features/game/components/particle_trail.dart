import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Enhanced explosion effect with:
///   • 80 main debris particles + 40 sparks + 30 ember particles
///   • Expanding shockwave ring that fades out
///   • Central flash burst
class ParticleTrailComponent extends PositionComponent {
  ParticleTrailComponent({
    required Vector2 explosionPosition,
    required Color color1,
    required Color color2,
  }) : super(position: explosionPosition, anchor: Anchor.center) {
    _color1 = color1;
    _color2 = color2;
    _spawnExplosion();
  }

  late final Color _color1;
  late final Color _color2;

  final List<_ExplosionParticle> _particles = [];
  final List<_EmberParticle> _embers = [];

  // Shockwave ring
  double _ringRadius = 0;
  double _ringAlpha = 0.9;
  bool _ringActive = true;

  // Central flash
  double _flashAlpha = 1.0;

  double _elapsed = 0;
  static const double _duration = 2.0;

  final Random _random = Random();

  void _spawnExplosion() {
    // Main debris (80 particles)
    for (var i = 0; i < 80; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 50 + _random.nextDouble() * 240;
      _particles.add(_ExplosionParticle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        life: 0.4 + _random.nextDouble() * 1.2,
        color: [_color1, _color2, Colors.white, Colors.orangeAccent][_random.nextInt(4)],
        size: 2 + _random.nextDouble() * 6,
      ));
    }

    // Sparks (40 — fast, thin)
    for (var i = 0; i < 40; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 120 + _random.nextDouble() * 360;
      _particles.add(_ExplosionParticle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 60,
        life: 0.2 + _random.nextDouble() * 0.55,
        color: Colors.white,
        size: 1.2 + _random.nextDouble() * 2,
      ));
    }

    // Embers — drift upward slowly with glow
    for (var i = 0; i < 30; i++) {
      _embers.add(_EmberParticle(
        x: (_random.nextDouble() - 0.5) * 30,
        y: (_random.nextDouble() - 0.5) * 20,
        vx: (_random.nextDouble() - 0.5) * 40,
        vy: -20 - _random.nextDouble() * 80,
        life: 0.8 + _random.nextDouble() * 1.0,
        color: _random.nextBool() ? _color1 : Colors.orangeAccent,
        size: 1.5 + _random.nextDouble() * 3,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    // Update debris particles
    for (final p in _particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 140 * dt; // gravity
      p.life -= dt;
      p.size *= 0.978;
    }
    _particles.removeWhere((p) => p.life <= 0);

    // Update embers
    for (final e in _embers) {
      e.x += e.vx * dt;
      e.y += e.vy * dt;
      e.vy -= 15 * dt; // slight upward drift deceleration
      e.vx *= 0.99;
      e.life -= dt;
    }
    _embers.removeWhere((e) => e.life <= 0);

    // Shockwave ring expands and fades
    if (_ringActive) {
      _ringRadius += 220 * dt;
      _ringAlpha = (_ringAlpha - dt * 2.2).clamp(0.0, 1.0);
      if (_ringAlpha <= 0) _ringActive = false;
    }

    // Central flash fades quickly
    _flashAlpha = (_flashAlpha - dt * 4.5).clamp(0.0, 1.0);

    if (_elapsed >= _duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // ── Central flash ──────────────────────────────────────
    if (_flashAlpha > 0) {
      canvas.drawCircle(
        Offset.zero,
        28,
        Paint()
          ..color = Colors.white.withValues(alpha: _flashAlpha * 0.85)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }

    // ── Shockwave ring ─────────────────────────────────────
    if (_ringActive) {
      canvas.drawCircle(
        Offset.zero,
        _ringRadius,
        Paint()
          ..color = _color1.withValues(alpha: _ringAlpha * 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      // Outer thin ring
      canvas.drawCircle(
        Offset.zero,
        _ringRadius * 1.15,
        Paint()
          ..color = Colors.white.withValues(alpha: _ringAlpha * 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    // ── Embers ────────────────────────────────────────────
    for (final e in _embers) {
      final alpha = (e.life / e.maxLife).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(e.x, e.y),
        e.size,
        Paint()
          ..color = e.color.withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
      );
    }

    // ── Debris + sparks ───────────────────────────────────
    for (final p in _particles) {
      final alpha = (p.life / p.maxLife).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(p.x, p.y),
        p.size,
        Paint()
          ..color = p.color.withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
      );
    }
  }
}

class _ExplosionParticle {
  _ExplosionParticle({
    required this.vx,
    required this.vy,
    required this.life,
    required this.color,
    required this.size,
  }) : maxLife = life;

  double x = 0, y = 0;
  double vx, vy;
  double life;
  final double maxLife;
  final Color color;
  double size;
}

class _EmberParticle {
  _EmberParticle({
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
}
