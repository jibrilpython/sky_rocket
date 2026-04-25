import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Explosion particle effect when the rocket crashes.
class ParticleTrailComponent extends PositionComponent {
  ParticleTrailComponent({
    required Vector2 explosionPosition,
    required Color color1,
    required Color color2,
  }) : super(position: explosionPosition, anchor: Anchor.center) {
    _spawnExplosion(color1, color2);
  }

  final List<_ExplosionParticle> _particles = [];
  double _elapsed = 0;
  static const double _duration = 1.5;

  void _spawnExplosion(Color color1, Color color2) {
    final random = Random();
    for (var i = 0; i < 40; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 60 + random.nextDouble() * 200;
      _particles.add(_ExplosionParticle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        life: 0.5 + random.nextDouble() * 1.0,
        color: random.nextBool() ? color1 : color2,
        size: 2 + random.nextDouble() * 5,
      ));
    }
    // Add some sparks
    for (var i = 0; i < 20; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 100 + random.nextDouble() * 300;
      _particles.add(_ExplosionParticle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 50,
        life: 0.3 + random.nextDouble() * 0.5,
        color: Colors.white,
        size: 1.5 + random.nextDouble() * 2,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    for (final p in _particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 120 * dt; // gravity
      p.life -= dt;
      p.size *= 0.98;
    }
    _particles.removeWhere((p) => p.life <= 0);

    if (_elapsed >= _duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    for (final p in _particles) {
      final alpha = (p.life / p.maxLife).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
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
