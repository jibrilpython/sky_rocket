import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Particle effect widget for shimmer and explosion animations.
class ParticleEffect extends StatefulWidget {
  const ParticleEffect({
    super.key,
    required this.type,
    required this.position,
    required this.duration,
    this.color = Colors.white,
    this.particleCount = 12,
  });

  final ParticleType type;
  final Offset position;
  final Duration duration;
  final Color color;
  final int particleCount;

  @override
  State<ParticleEffect> createState() => _ParticleEffectState();
}

enum ParticleType {
  shimmer,
  explosion,
  popUp,
  cascade,
}

class _ParticleEffectState extends State<ParticleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..forward();

    _generateParticles();
  }

  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < widget.particleCount; i++) {
      final angle = (2 * math.pi * i) / widget.particleCount;
      final velocity = Offset(
        math.cos(angle) * (50 + random.nextDouble() * 100),
        math.sin(angle) * (50 + random.nextDouble() * 100),
      );

      _particles.add(Particle(
        position: widget.position,
        velocity: velocity,
        life: 1.0 + random.nextDouble() * 0.5,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
            type: widget.type,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

class Particle {
  final Offset position;
  final Offset velocity;
  final double life;

  Particle({
    required this.position,
    required this.velocity,
    required this.life,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final ParticleType type;
  final Color color;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.type,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final t = progress * particle.life;
      if (t > 1.0) continue;

      final x = particle.position.dx + particle.velocity.dx * t * 100;
      final y = particle.position.dy + particle.velocity.dy * t * 100;

      // Fade out
      final alpha = (1.0 - t) * 255;

      switch (type) {
        case ParticleType.shimmer:
          _drawShimmer(canvas, x, y, alpha.toInt(), t);
          break;
        case ParticleType.explosion:
          _drawExplosion(canvas, x, y, alpha.toInt(), t);
          break;
        case ParticleType.popUp:
          _drawPopUp(canvas, x, y, alpha.toInt(), t);
          break;
        case ParticleType.cascade:
          _drawCascade(canvas, x, y, alpha.toInt(), t);
          break;
      }
    }
  }

  void _drawShimmer(Canvas canvas, double x, double y, int alpha, double t) {
    final paint = Paint()
      ..color = color.withValues(alpha: alpha / 255)
      ..style = PaintingStyle.fill;

    final size = 2 + t * 4;
    canvas.drawCircle(Offset(x, y), size, paint);

    // Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: (alpha * 0.4) / 255)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3);
    canvas.drawCircle(Offset(x, y), size + 2, glowPaint);
  }

  void _drawExplosion(Canvas canvas, double x, double y, int alpha, double t) {
    final paint = Paint()
      ..color = color.withValues(alpha: alpha / 255)
      ..style = PaintingStyle.fill;

    final size = (1 - t) * 8;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(x, y), width: size, height: size),
      paint,
    );
  }

  void _drawPopUp(Canvas canvas, double x, double y, int alpha, double t) {
    final paint = Paint()
      ..color = color.withValues(alpha: alpha / 255)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final size = 3 + t * 8;
    canvas.drawCircle(Offset(x, y), size, paint);
  }

  void _drawCascade(Canvas canvas, double x, double y, int alpha, double t) {
    final paint = Paint()
      ..color = color.withValues(alpha: alpha / 255)
      ..style = PaintingStyle.fill;

    final size = math.sin(t * math.pi) * 5;
    canvas.drawCircle(Offset(x, y), size, paint);
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
